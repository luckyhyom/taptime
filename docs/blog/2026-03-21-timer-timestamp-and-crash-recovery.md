# 타임스탬프 기반 타이머: 1초도 빠뜨리지 않는 카운트다운 설계

> 2026-03-21 | Taptime v1.0 Phase 2-3

## 배경

뽀모도로 타이머의 핵심은 정확한 카운트다운이다. 25분 타이머를 시작했는데 앱이 백그라운드로 갔다가 돌아왔을 때 시간이 맞지 않으면 신뢰를 잃는다. 앱 크래시 후에도 진행 중이던 타이머를 복구할 수 있어야 한다. 이 두 가지 요구사항이 타이머 설계를 결정했다.

## 핵심 결정

### 1. 매초 감소(decrement) 대신 타임스탬프 기반 계산

가장 직관적인 타이머 구현은 `Timer.periodic`으로 매초 `remaining--`를 하는 것이다:

```dart
// 단순하지만 부정확한 접근
Timer.periodic(Duration(seconds: 1), (_) {
  remaining--;  // 백그라운드에서 이 콜백이 멈추면?
});
```

문제는 iOS/Android 모두 백그라운드에서 타이머 콜백을 보장하지 않는다는 것이다. 앱이 30초간 백그라운드에 있었다면, 그 동안 `remaining`은 변하지 않고 30초가 남아 있는 것처럼 보인다.

Taptime은 **시작 시각(`startedAt`)과 누적 일시정지 시간(`pausedDurationSeconds`)으로부터 남은 시간을 매 틱마다 계산**한다:

```dart
// lib/features/timer/ui/timer_notifier.dart

/// 타임스탬프 기반으로 경과 시간을 계산한다.
int _calculateElapsed() {
  if (_startedAt == null) return 0;
  final referenceTime = _pausedAt ?? DateTime.now();
  return (referenceTime.difference(_startedAt!).inSeconds
      - _pausedDurationSeconds).clamp(0, 999999);
}

/// 타임스탬프 기반으로 남은 시간을 계산한다.
int _calculateRemaining(int totalSeconds) {
  if (_startedAt == null) return totalSeconds;
  return (totalSeconds - _calculateElapsed()).clamp(0, totalSeconds);
}
```

`Timer.periodic`은 UI 갱신 트리거일 뿐이다. 실제 시간 계산은 항상 벽시계(wall clock)를 기준으로 한다. 30초간 백그라운드에 있었다가 돌아오면:

```dart
void onAppResumed() {
  if (state.status != TimerStatus.running) return;

  final remaining = _calculateRemaining(state.totalSeconds);
  if (remaining <= 0) {
    _ticker?.cancel();
    _completeTimer();  // 백그라운드에서 만료됨
  } else {
    state = state.copyWith(remainingSeconds: remaining);
    _startTicking();   // 남은 시간부터 재개
  }
}
```

앱이 돌아온 순간 `DateTime.now() - startedAt - pausedDuration`으로 정확한 남은 시간을 복원한다. 백그라운드에서 이미 만료되었다면 자동 완료 처리한다.

### 2. ActiveTimer 싱글턴으로 크래시 복구

타이머가 돌아가는 중에 앱이 강제 종료되면? `Notifier`의 메모리 상태는 사라진다. 이를 위해 `ActiveTimer` 테이블을 만들었다:

```dart
// 타이머 상태가 변할 때마다 DB에 저장
Future<void> _persistActiveTimer() async {
  await ref.read(activeTimerRepositoryProvider).saveActiveTimer(
    ActiveTimer(
      id: ActiveTimer.singletonId,  // 항상 'singleton' — 테이블에 1행만
      presetId: _preset!.id,
      startedAt: _startedAt!,
      isPaused: _pausedAt != null,
      pausedAt: _pausedAt,
      pausedDurationSeconds: _pausedDurationSeconds,
      remainingSeconds: _calculateRemaining(state.totalSeconds),
      createdAt: _startedAt!,
    ),
  );
}
```

`singletonId`를 쓰는 이유: 동시에 실행 가능한 타이머는 항상 1개다. INSERT OR REPLACE로 이전 행을 덮어쓰면 복잡한 조회 로직 없이 "현재 활성 타이머"를 즉시 알 수 있다.

앱 재시작 시 복구 흐름:

```dart
Future<void> _initialize(String presetId) async {
  final activeTimer = await activeTimerRepo.getActiveTimer();

  if (activeTimer != null && activeTimer.presetId == presetId) {
    await _restoreTimer(activeTimer, presetRepo);  // 같은 프리셋 → 복구
  } else {
    if (activeTimer != null) {
      await _saveStoppedSession(activeTimer, presetRepo);  // 다른 프리셋 → stopped 세션 저장
      await activeTimerRepo.deleteActiveTimer();
    }
    await _startNewTimer(presetId, presetRepo, activeTimerRepo);
  }
}
```

복구 시에도 타임스탬프 기반 계산이 핵심이다. `startedAt`과 `pausedDurationSeconds`가 DB에 있으므로, 앱이 10분 후 재시작되어도 정확한 남은 시간을 계산할 수 있다. 이미 만료되었다면 `_completeTimer()`를 호출한다.

### 3. 스톱워치 모드: durationMin == 0

카운트다운 외에 "시간 제한 없이 측정만 하고 싶다"는 요구사항이 있었다. 별도의 Notifier를 만들 수도 있었지만, 동일한 로직에 분기를 추가하는 것이 더 간결했다:

```dart
/// durationMin이 0인 프리셋 = 스톱워치(무제한) 모드
bool get isStopwatch => totalSeconds == 0;

void _tick() {
  if (state.isStopwatch) {
    // 스톱워치 모드: 경과 시간만 갱신, 자동 완료 없음
    state = state.copyWith(elapsedSeconds: _calculateElapsed());
    return;
  }

  // 카운트다운 모드
  final remaining = _calculateRemaining(state.totalSeconds);
  if (remaining <= 0) {
    _ticker?.cancel();
    _completeTimer();
  } else {
    state = state.copyWith(remainingSeconds: remaining);
  }
}
```

`totalSeconds == 0`이 스톱워치 모드의 조건이다. 새로운 모델이나 테이블 없이 기존 구조를 그대로 활용한다. 크래시 복구도 동일한 `ActiveTimer` 메커니즘으로 동작한다.

## 코드 워크스루: Notifier 상태 관리 패턴

타이머 Notifier는 ADR-0008의 패턴을 따른다. 인터랙티브 상태(시작, 일시정지, 재개, 정지)에는 `Notifier`를, 읽기 전용 데이터(프리셋 목록, 세션 히스토리)에는 `StreamProvider`를 사용한다.

```dart
// AutoDispose: 화면 이탈 시 자동 정리
// Family(String): presetId별로 독립적인 타이머 인스턴스
class TimerNotifier extends AutoDisposeFamilyNotifier<TimerState, String> {
  Timer? _ticker;
  DateTime? _startedAt;       // 시작 시각
  DateTime? _pausedAt;        // 일시정지 시각
  int _pausedDurationSeconds = 0;  // 누적 일시정지 시간
  Preset? _preset;

  @override
  TimerState build(String presetId) {
    ref.onDispose(_onDispose);
    Future.microtask(() => _initialize(presetId));
    return const TimerState();  // 초기: loading 상태
  }
}
```

`AutoDisposeFamilyNotifier`를 사용한 이유:
- **AutoDispose:** 타이머 화면에서 나가면 Ticker를 자동 정리한다.
- **Family:** 같은 Notifier 코드가 프리셋마다 독립 인스턴스를 갖는다.

`_onDispose`에서는 실행/일시정지 중이면 `_persistActiveTimer()`를 호출한다. 사용자가 뒤로가기를 해도 타이머 상태가 DB에 남아서 다시 돌아왔을 때 복구된다.

## 배운 점

- **모바일 타이머에서 `Timer.periodic`은 트리거일 뿐이다.** 실제 시간 계산은 반드시 시스템 시계 기반이어야 한다. 백그라운드, 저전력 모드, 앱 일시정지 등 콜백이 멈추는 상황이 많다.
- **"활성 상태" 테이블은 단순하지만 강력하다.** Singleton 패턴의 DB 행 하나로 크래시 복구, 다른-프리셋-전환, 앱 재시작을 모두 처리할 수 있다.
- **분기(flag)로 모드를 나누는 것이 별도 클래스보다 나을 수 있다.** 스톱워치와 카운트다운의 차이는 "완료 조건 유무"뿐이므로, `isStopwatch` 하나로 충분했다.
