# FEAT-001: Data Layer Design Review

- **Type:** tech-debt
- **Priority:** high
- **Status:** resolved
- **Created:** 2026-03-17
- **Resolved:** 2026-03-17
- **Related:** 0cccfe9, 8eafb70, d68b717

## Context

Phase 1 Foundation이 거의 완료된 시점에서 Phase 2~6의 기능 요구사항을 역추적하여 데이터 레이어의 설계 갭을 점검했다. 8개의 누락/개선점을 발견하여 Phase 2 진입 전에 일괄 해결.

## Technical Analysis

- **Affected layer:** data
- **Affected feature:** timer, preset, history, stats, settings
- **Root cause:** 초기 설계 시 이후 Phase의 구체적 요구사항을 충분히 반영하지 못함
- **Affected files:**
  - `lib/shared/models/active_timer.dart` (NEW)
  - `lib/shared/models/session.dart`
  - `lib/shared/repositories/active_timer_repository.dart` (NEW)
  - `lib/shared/repositories/session_repository.dart`
  - `lib/shared/repositories/preset_repository.dart`
  - `lib/core/database/tables.dart`
  - `lib/core/database/app_database.dart`
  - `lib/core/database/preset_seeder.dart` (NEW)
  - `lib/features/timer/data/active_timer_repository_impl.dart` (NEW)
  - `lib/features/preset/data/preset_repository_impl.dart`
  - `lib/features/history/data/session_repository_impl.dart`

## Solution

### Issue 1: 크래시 복구 수단 없음 (Phase 3 — Timer)

MVP 요구사항에 타이머 상태 유지가 있으나 저장 수단이 없었다.

**결정:** ActiveTimer 모델 + 테이블 + 리포지토리 신규 생성. 단일행 패턴(id = 'singleton')으로 구현.

**대안 검토:**
- SharedPreferences → 구조화된 데이터 저장에 부적합
- 메모리만 사용 → 앱 종료 시 유실
- 별도 JSON 파일 → Drift와 트랜잭션 일관성 유지 불가

### Issue 2: Sessions 복합 인덱스 누락

`presetId` 단일 인덱스와 `startedAt` 단일 인덱스만 존재. 프리셋별 날짜 범위 조회 시 최적 인덱스 없음.

**해결:** `(presetId, startedAt)` 복합 인덱스 추가.

### Issue 3: 프리셋별 일일 집계 쿼리 없음 (Phase 2 — Home)

홈 화면의 프리셋별 진행률 표시에 필요한 쿼리 부재.

**결정:** `getDailyDurationByPreset()` 추가. 기존 `getSessionsByDate()`를 재사용하여 Dart에서 집계.

**대안 검토:**
- SQL GROUP BY → 하루치 세션은 소량(수십 건)이라 성능 차이 없고, Dart 코드가 더 읽기 쉬움

### Issue 4: 날짜 범위 reactive 스트림 없음 (Phase 5 — Stats)

주간 통계 화면에서 날짜 범위를 실시간 관찰할 수단 부재.

**해결:** `watchSessionsByDateRange()` 추가. 기존 `_queryByDateRange()` 헬퍼 재사용.

### Issue 5: copyWith로 memo를 null로 설정 불가 (Phase 4 — History)

`copyWith(memo: null)`이 `??` 연산자에 의해 "변경 없음"으로 처리됨.

**결정:** `Session.clearMemo()` 별도 메서드 추가. 같은 패턴으로 `ActiveTimer.clearPausedAt()`도 생성.

**대안 검토:**
- freezed 패키지 도입 → sentinel 패턴으로 자동 해결되지만, 현재 수동 모델로 일관성 유지 중이므로 과도한 변경

### Issue 6: SessionRepositoryImpl 위치 (timer에서도 사용)

`features/history/data/`에 위치하나 Timer 기능에서도 사용.

**결정:** 현행 유지. Riverpod provider로 접근하므로 파일 위치는 조직적 의미만 있음. `shared/data/` 신규 컨벤션 도입은 불필요.

### Issue 7: deleteAllPresets 없음 (Phase 6 — Settings)

설정 > 데이터 초기화에 필요한 메서드 부재.

**해결:** `PresetRepository.deleteAllPresets()` 추가. FK CASCADE로 관련 세션과 활성 타이머도 연쇄 삭제.

### Issue 8: 초기 데이터 없음 (Phase 2 — Presets)

앱 최초 실행 시 프리셋이 비어있어 사용 불가.

**해결:** `PresetSeeder` 생성. 프리셋이 0개일 때 AppConstants.defaultPresets 기반으로 3개 자동 생성.

## Test

- **Test added:** not needed
- **Test type:** —
- **How to verify:** `flutter analyze` 통과 확인. 리포지토리 테스트는 Phase 1 마무리 시 통합 작성 예정.

## Takeaway

- **설계 리뷰 타이밍:** 기능 구현 전에 이후 Phase의 요구사항을 역추적하면 나중에 돌아오는 비용을 줄일 수 있다.
- **copyWith null 함정:** Dart의 nullable 필드 + `??` 연산자 조합은 null 설정을 막는다. freezed 없이는 `clearX()` 패턴이 필요하다.
- **과도한 이동보다 현행 유지:** DI로 추상화된 상태에서 파일 위치 변경은 실질적 이점 없이 import 변경 비용만 발생한다.
