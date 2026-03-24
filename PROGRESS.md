# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** v2.1 Location-Based Auto Tracking — Phase A-D 완료, Phase E 대기
- **Last Updated:** 2026-03-24
- **Blocker:** None

## Notes for Next Agent

### Where We Are

v2.1 Location-Based Auto Tracking — Phase A-D 완료:
- **Phase A (완료):** LocationTrigger 데이터 레이어 + Supabase 동기화 통합
- **Phase B (완료):** iOS Platform Channel — GeofenceService + CLLocationManager + 로컬 알림
- **Phase C (완료):** Location Registration UI — flutter_map 피커 + 프리셋 폼 연동
- **Phase D (완료):** Orchestration — GeofenceManager, 자동 시작, 설정 토글
  - `GeofenceManager` — watchAllTriggers 구독으로 DB↔네이티브 영역 자동 동기화
  - 진입 이벤트 → 프리셋 매칭 → autoStart면 즉시 이동, 아니면 확인 다이얼로그
  - `geofenceManagerProvider` — locationTrackingEnabled 반응형 (토글 시 자동 시작/중지)
  - `_GeofenceEventHandler` — app.dart builder에서 액션 스트림 수신
  - Settings: iOS 전용 "위치 기반 자동 트래킹" SwitchListTile (Always 권한 요청 포함)
  - GeofencePlugin iOS 13 호환 수정 (authorizationStatus #available 분기)
- **Phase E (다음):** Permission flow, edge cases (20 region limit), data reset integration
- **테스트:** 155개 전체 통과

### Environment

- Flutter 3.41.4, Xcode 26.3, CocoaPods 1.16.2
- Android SDK: deferred (SDK 36 + BuildTools 28.0.3 needed later)
- iOS simulator: `flutter run --dart-define-from-file=.env`
- Supabase CLI: v2.75.0 (linked to project)

### Key Architecture Context

- `presetMapProvider` lives in `app_providers.dart` (shared across history, stats)
- `todayDurationByPresetProvider` in `preset_providers.dart` feeds PresetCard daily progress
- Timer uses timestamp-based calculation, not decrement-based
- Stopwatch mode: `durationMin == 0`, `totalSeconds == 0`, no auto-completion
- Design system: `design/대안.html` (proposed new design) vs `design/current.html` (current)
  - Decision on applying new design tokens is pending user review

### Known Non-Blocking Issues

- PRD.md header date not updated (still says 2026-03-14)
- PRD section numbering gap (3.8 → 3.10)
- Data Export/Import in PRD but not in any PLAN phase
- Manual Session Entry in PRD but not in PLAN/BACKLOG

## Recent Work

### 2026-03-24 — v2.1 Phase D: Orchestration 완료

- **GeofenceManager:** DB의 LocationTrigger ↔ 네이티브 영역 자동 동기화 (watchAllTriggers 스트림)
  - 진입 이벤트 → 트리거+프리셋 매칭 → GeofenceAction emit
  - autoStart=true → 타이머 화면 즉시 이동, false → 확인 다이얼로그
- **geofenceManagerProvider:** userSettingsStreamProvider 반응형 — 토글 시 자동 시작/중지 (Riverpod dispose 활용)
- **_GeofenceEventHandler:** MaterialApp.builder 내 위젯, 액션 스트림 수신 → 다이얼로그/네비게이션
- **Settings:** iOS 전용 "위치 기반 자동 트래킹" SwitchListTile, Always 권한 미승인 시 SnackBar 안내
- **iOS 13 호환:** GeofencePlugin.swift의 authorizationStatus 접근을 #available 분기로 수정

### 2026-03-24 — v2.1 Phase C: Location Registration UI 완료

- **지도 피커:** `LocationPickerScreen` — FlutterMap + OSM 타일, 탭으로 핀 찍기, 반경 원 표시
  - 하단 패널: 장소 이름, 반경 슬라이더(50~1000m), 알림/자동시작 토글
  - 생성/수정 모드 지원, MapController race condition 방어 (addPostFrameCallback)
  - ValueListenableBuilder로 저장 버튼만 선택적 리빌드 (지도 불필요 리빌드 방지)
- **프리셋 폼 연동:** PresetFormState + _LocationTriggerSection
  - locationTriggerId/locationTriggerName 폼 상태 추가
  - 지도 피커와 push<String>/pop(triggerId) 패턴으로 결과 교환
  - 등록/변경/해제 UI
- **라우터:** /location-picker, /location-picker/:triggerId 경로 추가
- **상수:** AppConstants에 locationNameMaxLength, locationRadiusMin/Max/Default 추가
- **의존성:** flutter_map ^8.2.2, latlong2 ^0.9.1

### 2026-03-23 — v2.1 Phase B: iOS Platform Channel 완료

- **GeofenceService 인터페이스:** GeofenceEvent, GeofencePermissionStatus 타입 + 추상 메서드 (shared/services/)
- **Dart 구현:** GeofenceServiceImpl (MethodChannel) + NoopGeofenceService (비iOS)
- **Swift 네이티브:** GeofencePlugin — CLLocationManager 지오펜스 + UNUserNotificationCenter 로컬 알림
  - 영역 등록/제거/모니터링, 권한 요청, 20개 제한 검증
  - 진입/퇴장 시 장소 이름 포함 알림 + Dart 이벤트 전달
- **iOS 설정:** Info.plist (위치 권한 설명, 백그라운드 모드), AppDelegate 플러그인 등록, pbxproj 파일 참조
- **프로바이더:** geofenceServiceProvider (Platform.isIOS 조건부)
- **테스트:** 18개 추가 (MethodChannel 모킹, 이벤트 스트림, 권한 파싱) → 총 155개 통과
- **문서:** ADR-0009, FEAT-002 Phase B 솔루션 기록

### 2026-03-23 — v2.1 Phase A: Foundation (Data Layer) 완료

- **데이터 레이어:**
  - LocationTriggers Drift 테이블 (placeName, lat/lng, radius, notify, autoStart)
  - Presets에 locationTriggerId FK 추가 (onDelete: setNull)
  - UserSettings에 locationTrackingEnabled 추가
  - DB schemaVersion 2→3 마이그레이션
  - LocationTrigger 모델 + LocationTriggerRepository 인터페이스/Drift 구현
  - Preset 모델에 locationTriggerId + clearLocationTrigger()
- **동기화 통합:**
  - SupabaseMappers: locationTrigger Row↔JSON 매퍼, preset에 location_trigger_id 포함
  - SupabaseSyncService: location_triggers push/pull/merge (FK 순서: triggers→presets→sessions)
  - SyncAwareLocationTriggerRepository 데코레이터
  - locationTriggerRepositoryProvider (조건부 SyncAware 래핑)
  - Supabase SQL 마이그레이션 (`002_location_triggers.sql` + RLS)
- FEAT-002 이슈 파일 생성

### 2026-03-22 — Phase 7: iOS 시뮬레이터 테스팅

- iPhone 17 Pro 시뮬레이터에서 빌드 + 실행 성공
- 핵심 플로우 확인: 홈 → 프리셋 생성 → 타이머 실행 → 히스토리 → 설정
- Android는 SDK 미설치로 보류 (SDK 36 + BuildTools 필요)

### 2026-03-22 — v2.0 E2E Testing + SyncRemoteDataSource 리팩토링

- **Testability refactoring:** `SyncRemoteDataSource` 인터페이스 추출
  - `SupabaseSyncService`의 `SupabaseClient` 직접 의존 → `SyncRemoteDataSource` 인터페이스로 교체
  - `SupabaseRemoteDataSource` — production 구현체 (SupabaseClient 래핑)
  - `FakeSyncRemoteDataSource` — 테스트용 인메모리 구현체
- **76개 테스트 추가** (기존 61 → 총 137개, 전체 통과):
  - `supabase_mappers_test` (10): Row↔JSON 변환, safe enum fallback
  - `connectivity_monitor_test` (7): 온/오프라인 감지, 스트림 변환
  - `sync_aware_preset_repository_test` (8): 위임 + syncNow 트리거
  - `sync_aware_session_repository_test` (9): 위임 + syncNow 트리거
  - `supabase_auth_service_test` (11): Google 로그인, signOut, auth 상태
  - `supabase_sync_service_test` (25): push/pull, 충돌 해결, 소프트 삭제, 가드, 상태
  - `sync_metadata_test` (6): SharedPreferences round-trip
- **Mock 인프라:** MockSyncService, MockConnectivityMonitor 등 8개 mock 추가

### 2026-03-22 — v2.0 Supabase Project Setup + Security

- **Supabase project:** created `taptime` (ref: stsltytrnxosxhmziogp, Tokyo region)
- **Migration:** `001_initial_schema.sql` applied via `supabase db push`
- **Security refactor:** credentials moved from hardcoded → `.env` + `--dart-define-from-file`
  - `SupabaseConfig` now uses `String.fromEnvironment` for all values
  - `.gitignore` updated: `.env`, `google-services.json`, `GoogleService-Info.plist`, keystores
  - pitfalls.md: 2 security rules added (no credentials in git, no secrets in output)
- **Google OAuth:** iOS + Web client IDs created in Google Cloud Console
  - `SupabaseAuthService` updated to accept clientId/serverClientId from config
  - Supabase Dashboard Google provider configured with Web client ID/secret
- **iOS:** `Runner.entitlements` created with Sign in with Apple capability
- **Guide:** `docs/guides/SUPABASE_SETUP.md` — full setup instructions

### 2026-03-22 — v2.0 Phase E: Sync Status UI

- Created `SyncStatusWidget` — cloud icon in AppBar (idle/syncing/synced/error states)
- Syncing state uses rotating animation (`_SyncingIcon` with `RotationTransition`)
- Added `syncStatusProvider` (StreamProvider) and `lastSyncTimeProvider` (FutureProvider)
- Settings account section shows last sync time with relative formatting ("5분 전")
- Extracted `TimeFormatter.relativeTime()` to `core/utils/date_utils.dart`

### 2026-03-22 — v2.0 Phase C+D: Sync Engine + Provider Rewiring

- **Phase C (Sync Engine):**
  - Created `SyncService` interface with `SyncStatus` enum (idle/syncing/synced/error)
  - Created `SupabaseMappers` — camelCase ↔ snake_case conversion (row-to-JSON + JSON-to-model)
  - Created `SyncMetadata` — lastPullTimestamp + lastSyncTime in SharedPreferences
  - Created `ConnectivityMonitor` — wraps connectivity_plus for online/offline detection
  - Created `SupabaseSyncService` — bidirectional push/pull with last-write-wins conflict resolution
  - Fixed pull timestamp bug: capture lastPull once before both table pulls
- **Phase D (Provider Rewiring):**
  - Extracted `SyncStatusDb` constants to `core/database/sync_constants.dart`
  - Modified `PresetRepositoryImpl` — soft delete, `deletedAt IS NULL` on reads, `syncStatus='pending'` on writes
  - Modified `SessionRepositoryImpl` — same soft delete + filter treatment
  - Created `SyncAwarePresetRepository` decorator — triggers `syncNow()` after writes
  - Created `SyncAwareSessionRepository` decorator — same pattern
  - Added `syncServiceProvider` to `app_providers.dart` — lifecycle tied to login state
  - Modified repo providers for conditional decorator wrapping
  - Updated cascade delete test for soft delete behavior
  - Added `formatter: page_width: 120` to `analysis_options.yaml`

### 2026-03-21 — v2.0 Phase A+B: Foundation + Auth

- **Phase A (Foundation):**
  - Added `supabase_flutter`, `google_sign_in`, `sign_in_with_apple`, `connectivity_plus`, `crypto` to pubspec
  - Created `SupabaseConfig` with placeholder values and conditional init in `main.dart`
  - Drift schema v2: added `updatedAt`, `deletedAt`, `syncStatus`, `lastSyncedAt` columns
  - Created `supabase/migrations/001_initial_schema.sql` with RLS + Realtime
- **Phase B (Auth):**
  - Created `AuthUser` model and `AuthService` interface in `shared/`
  - Implemented `SupabaseAuthService` — Google (`signInWithIdToken` + `google_sign_in`) and Apple (nonce + SHA-256 + `sign_in_with_apple`)
  - Fixed `AuthUser` name collision with supabase_flutter via `hide` directive
  - Created `auth_providers.dart` — `authServiceProvider`, `authStateProvider`, `isLoggedInProvider`
  - Created `LoginScreen` with Google/Apple buttons, loading state, error handling
  - Added account section to `SettingsScreen` — login/logout with profile display
  - Added `/login` route to `app_router.dart`

### 2026-03-21 — UX Polish: Heatmap, Timer Navigation, Home Status

- **Heatmap → GitHub contribution graph:** Rewrote `heatmap_calendar.dart` from calendar grid to horizontal 7-row layout (Mon-Sun rows × week columns), ~10px cells, English month/day labels
- **Heatmap sort order:** Preset heatmaps in monthly stats now follow home screen `sortOrder`
- **Drag reorder fix:** Wrapped drag handle with `ReorderableDragStartListener` for reliable drag-and-drop
- **Timer navigation overhaul:** Removed X/home buttons and PopScope; swipe/back gesture navigates freely while timer persists via ActiveTimer DB
- **Active timer on preset cards:** Home screen shows running/paused badge with mm:ss elapsed time on the active preset card
- **Timer layout fix:** Rebalanced Spacer ratios (2:1:1:2) after top bar removal

### 2026-03-21 — v1.1 Motivation & Extended Stats + Per-Preset Refactoring

- **Heatmap calendar:** GitHub-style monthly grid via CustomPaint, 4 intensity levels, tap → Today stats
- **Break timer:** Lightweight notifier (no DB), 5m/15m options in completion dialog, teal-themed screen
- **Monthly stats tab:** 3rd tab in Stats screen with month navigator, total time, category donut, goal progress
- **Weekly/monthly goals:** Extracted GoalProgressBar widget, added to week (×7) and month (×daysInMonth) views
- **Per-preset refactoring:** Replaced global heatmap/streak with per-preset versions
  - Added `getDailyTotalsForPreset` to session repository (interface + impl)
  - Replaced `monthDailyTotalsProvider`/`currentStreakProvider` with family providers keyed by presetId
  - Month stats: each preset with sessions gets its own colored heatmap + inline streak badge
  - Removed home screen streak badge and deleted `streak_card.dart`
  - HeatmapCalendar: added `activeColor` and `showCard` params for embedded use
- Data layer: added `watchSessionsByMonth`, `getDailyTotalsForRange`, date_utils extensions

### Earlier — Phases 0-7 (MVP) + v1.1

- See git log for details
