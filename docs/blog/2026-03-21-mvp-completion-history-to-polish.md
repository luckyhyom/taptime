# MVP 완성기: 히스토리부터 폴리시까지 하루에 4개 Phase 끝내기

> 2026-03-21 | Taptime v1.0 Phase 4-7

## 배경

Phase 2(프리셋)와 Phase 3(타이머)에서 핵심 데이터 모델과 로직을 충분히 다졌더니, Phase 4(히스토리)부터 Phase 7(폴리시)까지 하루 만에 완성할 수 있었다. 설계 리뷰에서 미리 준비한 Repository 메서드들(`watchSessionsByDateRange`, `getDailyDurationByPreset`, `deleteAllPresets` 등)이 그대로 사용되었기 때문이다.

## 핵심 결정

### 1. SQL GROUP BY 대신 Dart 집계

히스토리와 통계 화면에서는 "날짜별 프리셋별 총 시간"이 필요하다. SQL의 GROUP BY로 DB 레벨에서 집계할 수도 있었지만, Dart 코드로 처리하기로 했다:

```dart
// lib/features/history/data/session_repository_impl.dart
@override
Future<Map<String, int>> getDailyDurationByPreset(DateTime date) async {
  final sessions = await getSessionsByDate(date);
  final result = <String, int>{};
  for (final s in sessions) {
    result[s.presetId] = (result[s.presetId] ?? 0) + s.durationSeconds;
  }
  return result;
}
```

이유: 하루치 세션은 수십 건 이하다. 이 규모에서 SQL GROUP BY는 복잡도만 올리고 성능 이득이 없다. Dart에서 집계하면 디버깅이 쉽고 테스트도 단순하다.

### 2. StreamProvider로 실시간 갱신

통계 화면이 열려 있는 동안 타이머가 완료되면 즉시 반영되어야 한다. Drift의 `watch()`와 Riverpod의 `StreamProvider`를 결합했다:

```dart
// 홈 화면의 프리셋별 오늘 진행 시간
final todayDurationByPresetProvider = StreamProvider<Map<String, int>>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return sessionRepo.watchDailyDurationByPreset(DateTime.now());
});
```

타이머가 세션을 저장하면 → Drift가 sessions 테이블 변경을 감지 → `watch()` 스트림이 새 값을 emit → StreamProvider가 UI를 갱신. 수동으로 "새로고침"을 구현할 필요가 없다.

### 3. Phase 7 폴리시: 사소하지만 중요한 것들

MVP를 "사용 가능한" 수준으로 만드는 Phase 7에서 처리한 주요 항목:

**빈 상태 처리:** 프리셋이 없을 때, 세션 히스토리가 없을 때 각각 안내 메시지를 보여준다. 빈 화면은 앱이 고장난 것처럼 보인다.

**presetMapProvider 공유:** 히스토리와 통계에서 프리셋 이름/아이콘이 필요하다. 각 화면이 독립적으로 프리셋을 조회하면 중복이다. `app_providers.dart`에 공유 프로바이더를 만들었다:

```dart
// lib/core/providers/app_providers.dart
/// 프리셋 ID → Preset 매핑. 히스토리, 통계 등에서 공유.
final presetMapProvider = StreamProvider<Map<String, Preset>>((ref) {
  return ref.watch(presetRepositoryProvider).watchAllPresets().map(
    (presets) => {for (final p in presets) p.id: p},
  );
});
```

## 코드 워크스루: 세션 히스토리의 날짜별 그룹핑

히스토리 화면은 세션을 날짜별로 그룹핑해서 보여준다. Drift의 reactive stream 위에 Dart의 `groupBy` 로직을 얹었다:

```dart
// 날짜별로 묶인 세션 리스트를 실시간 감시
final historyProvider = StreamProvider.family<Map<DateTime, List<Session>>, DateRange>(
  (ref, range) {
    return ref.watch(sessionRepositoryProvider)
        .watchSessionsByDateRange(range.start, range.end)
        .map(_groupByDate);
  },
);
```

DB에 세션이 추가/삭제되면 stream이 자동 갱신되고, UI의 날짜 섹션도 실시간으로 업데이트된다.

## 배운 점

- **데이터 레이어를 미리 설계하면 UI 구현이 빨라진다.** Phase 1에서 리뷰한 8개 갭을 미리 메워두니 Phase 4-7에서는 "이미 있는 메서드를 화면에 연결"하는 수준이었다.
- **Drift의 `watch()` + Riverpod의 `StreamProvider`는 실시간 UI의 기본 패턴이다.** 수동 갱신 코드를 작성할 필요가 거의 없다.
- **소규모 데이터는 Dart 집계가 SQL보다 유지보수하기 쉽다.** 성능이 문제될 때 SQL로 옮기면 되지만, 대부분의 경우 그 시점은 오지 않는다.
