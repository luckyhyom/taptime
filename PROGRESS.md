# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** v2.0 Cloud Backup — Supabase project live, E2E testing next
- **Last Updated:** 2026-03-22
- **Blocker:** None

## Notes for Next Agent

### Where We Are

v2.0 Cloud Backup — Supabase project created and configured:
- **Phases A-E:** done (Foundation, Auth, Sync Engine, Provider Rewiring, UI)
- **Supabase project:** live at `stsltytrnxosxhmziogp` (Tokyo region), migration applied
- **Google OAuth:** iOS + Web client IDs created, Supabase Google provider enabled
- **Credentials:** managed via `.env` + `--dart-define-from-file` (not hardcoded)
- **Next:** E2E testing (Google auth flow, sync push/pull, conflict resolution)
- Apple Sign-In deferred until app store deployment
- Android setup deferred until app store deployment

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
