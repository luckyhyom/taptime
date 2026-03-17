# 기능 구현 전에 데이터 레이어를 점검한 이유

> 2026-03-17 | Taptime 프로젝트 — Phase 1 Foundation 마무리 단계

## 배경

Taptime은 프리셋 기반 포모도로 타이머 앱입니다. Phase 1(Foundation)에서 Drift DB 스키마, 모델, 리포지토리를 만들어두었고, 이제 Phase 2(Presets)로 넘어가기 직전이었습니다.

그런데 한 가지 걱정이 있었습니다:

> "지금 만든 데이터 레이어가 이후 기능에서 부족하지 않을까?"

Phase 2~6까지의 기능 요구사항을 역으로 훑으면서 데이터 레이어에 빠진 게 없는지 점검했습니다. 결과적으로 **8개의 설계 갭**을 발견했고, Phase 2 진입 전에 모두 해결했습니다.

---

## 발견한 문제들과 해결

### 1. 크래시 복구 — ActiveTimer

**문제:** MVP 요구사항에 "앱이 종료되어도 타이머 상태가 유지되어야 한다"가 있었지만, 이를 저장할 테이블이 없었습니다.

**해결:** ActiveTimer라는 새 모델/테이블/리포지토리를 만들었습니다.

핵심은 **단일행 패턴(singleton pattern)**입니다:

```dart
/// 항상 'singleton' — 테이블에 하나의 행만 존재하도록 한다.
final String id;

static const singletonId = 'singleton';
```

타이머는 동시에 하나만 실행되므로, 테이블에 항상 0개(타이머 꺼짐) 또는 1개(타이머 켜짐)의 행만 있으면 됩니다. id를 고정값으로 쓰면 INSERT OR REPLACE로 간단하게 upsert할 수 있습니다.

이 패턴은 UserSettings 테이블(id = 1 고정)에서 이미 사용 중이었기 때문에, 프로젝트 내에서 일관된 패턴입니다.

### 2. copyWith의 null 문제 — clearMemo()

**문제:** Session의 메모를 삭제하고 싶을 때 `copyWith(memo: null)`을 호출하면 "변경 없음"으로 처리됩니다.

```dart
// copyWith 내부
memo: memo ?? this.memo,  // null이면 기존 값 유지 → 삭제 불가!
```

Dart의 `??` 연산자는 null과 "미지정"을 구분하지 못합니다. `freezed` 패키지를 쓰면 sentinel 패턴으로 해결할 수 있지만, 이 프로젝트에서는 수동으로 모델을 만들고 있었습니다.

**해결:** 별도의 `clearMemo()` 메서드를 추가했습니다.

```dart
Session clearMemo() {
  return Session(
    id: id,
    presetId: presetId,
    // ... 다른 필드들 ...
    // memo 파라미터를 아예 넘기지 않음 → null로 초기화
  );
}
```

같은 문제가 ActiveTimer의 `pausedAt` 필드에도 있어서, 동일한 패턴으로 `clearPausedAt()`도 만들었습니다.

### 3. 인덱스 부족

**문제:** Sessions 테이블에 `presetId` 단일 인덱스와 `startedAt` 단일 인덱스는 있었지만, 홈 화면에서 "특정 프리셋의 오늘 세션"을 조회할 때 최적의 인덱스가 없었습니다.

**해결:** 복합 인덱스를 추가했습니다.

```dart
@TableIndex(name: 'idx_sessions_preset_started', columns: {#presetId, #startedAt})
```

복합 인덱스는 `WHERE presetId = ? AND startedAt BETWEEN ? AND ?` 같은 쿼리에서 두 조건을 한번에 해결합니다. 단일 인덱스 두 개로는 하나만 사용하고 나머지는 풀스캔하게 됩니다.

### 4. 쿼리 메서드 부족

**문제:** 홈 화면의 프리셋별 진행률과 통계 화면의 주간 데이터에 필요한 쿼리가 없었습니다.

**해결:** 두 가지 메서드를 SessionRepository에 추가했습니다:

```dart
// 홈 화면: 프리셋별 오늘 총 시간
Future<Map<String, int>> getDailyDurationByPreset(DateTime date);

// 통계 화면: 날짜 범위의 세션을 실시간 관찰
Stream<List<Session>> watchSessionsByDateRange(DateTime start, DateTime end);
```

`getDailyDurationByPreset`은 SQL GROUP BY 대신 Dart에서 집계합니다. 하루치 세션은 수십 건 이하라 성능 차이가 없고, 코드가 훨씬 읽기 쉬워집니다.

### 5. 초기 데이터 — PresetSeeder

**문제:** 앱을 처음 설치하면 프리셋이 비어있어서, 사용자가 직접 만들기 전에는 아무것도 할 수 없습니다.

**해결:** PresetSeeder를 만들어서 앱 시작 시 프리셋이 비어있으면 기본 3개(Study, Exercise, Reading)를 자동 생성합니다.

```dart
Future<void> seedIfEmpty() async {
  final existing = await _repository.getAllPresets();
  if (existing.isNotEmpty) return;  // 이미 있으면 아무것도 안 함
  // ... 기본 프리셋 생성
}
```

### 6. SessionRepositoryImpl 위치 논의

SessionRepositoryImpl이 `features/history/data/`에 있는데, Timer 기능에서도 사용합니다. `shared/data/`로 옮겨야 하나 고민했지만, **코드 변경 없음**으로 결정했습니다.

이유: Riverpod provider로 접근하므로 파일 위치는 조직적 의미만 있고, 새로운 `shared/data/` 컨벤션을 도입하면 오히려 혼란을 줄 수 있습니다. 나중에 정말 필요할 때 옮겨도 늦지 않습니다.

### 7~8. deleteAllPresets

설정 화면의 "데이터 초기화" 기능에 필요한 `deleteAllPresets()`를 추가했습니다. FK CASCADE 덕분에 프리셋을 삭제하면 관련 세션과 활성 타이머도 자동으로 삭제됩니다.

---

## 배운 것들

### 1. 기능 구현 전에 데이터 레이어를 점검하는 게 효율적이다

Phase 2에서 프리셋 카드를 만들다가 "프리셋별 진행률 쿼리가 없네?" 하고 돌아오는 것보다, 미리 확인하고 한번에 처리하는 게 훨씬 낫습니다. build_runner도 한 번만 돌리면 되고, 관련된 변경을 모아서 커밋할 수 있습니다.

### 2. copyWith의 null 함정은 Dart에서 흔한 문제다

nullable 필드를 가진 immutable 클래스에서 `copyWith`로 null을 설정할 수 없는 건 Dart의 잘 알려진 한계입니다. `freezed` 패키지를 쓰면 자동으로 해결되지만, 수동으로 모델을 만들 때는 `clearX()` 같은 명시적 메서드가 필요합니다.

### 3. 과도한 최적화보다 가독성을 선택하라

`getDailyDurationByPreset`에서 SQL GROUP BY 대신 Dart 집계를 선택한 건 의도적입니다. 하루 세션이 수백 건이 되는 일은 현실적으로 없고, Dart 코드가 SQL보다 읽기 쉽고 테스트하기 쉽습니다.

### 4. "나중에 옮기면 된다"가 항상 나쁜 건 아니다

SessionRepositoryImpl의 위치를 지금 당장 바꾸지 않은 건 게으름이 아닙니다. 파일 위치 변경은 import 수정, 커밋 히스토리 오염 등 비용이 있고, Riverpod이 추상화를 제공하므로 위치가 실제 동작에 영향을 주지 않습니다.

---

## 오늘의 커밋 요약

| # | 커밋 | 변경 파일 |
|---|------|----------|
| 1 | `feat(data): add ActiveTimer model, table, and repository` | 6개 (모델, 테이블, DB, 리포지토리 인터페이스+구현) |
| 2 | `feat(data): add per-preset aggregate queries and reactive stream` | 2개 (인터페이스+구현) |
| 3 | `fix(data): add clearMemo, deleteAllPresets, and preset seeder` | 4개 (모델, 인터페이스, 구현, 시더) |

다음은 Phase 1의 마지막 커밋 — GoRouter, Riverpod providers, 앱 진입점 연결입니다.
