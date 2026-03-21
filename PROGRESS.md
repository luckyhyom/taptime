# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** v1.1 complete (including per-preset refactoring). Next: v2.0 (Cloud Backup) or other Post-MVP.
- **Last Updated:** 2026-03-21
- **Blocker:** None

## Notes for Next Agent

### Where We Are

MVP + v1.1 features are implemented:
- Phases 0-7 (MVP): fully complete
- v1.1: heatmap calendar, per-preset streak tracking, break timer, weekly/monthly goals, monthly stats — all done
- Per-preset refactoring: global heatmap/streak replaced with per-preset versions, home streak badge removed
- 61 tests passing, 0 analyzer issues
- Remaining: user-side emulator testing (manual)

### Environment

- Flutter 3.41.4, Xcode 26.3, CocoaPods 1.16.2
- Android SDK: deferred (SDK 36 + BuildTools 28.0.3 needed later)
- iOS simulator: `flutter run` (physical device needs Xcode code signing)

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

### 2026-03-21 — Phases 4-7 (previous session)

- **Phase 4 (History):** date navigator, session list tiles, memo edit bottom sheet, swipe-to-delete
- **Phase 5 (Stats):** Today/Week tabs, per-preset bar charts, goal progress, 7-day bar chart, donut chart
- **Phase 6 (Settings):** theme toggle, sound/vibration switches, data reset with cascade + re-seed
- **Phase 7 (Polish):** connected daily progress to PresetCard, fixed DonutPainter repaint, stopwatch clamp, settings reset await
- Refactored `presetMapProvider` to `app_providers.dart` for cross-feature use
- Merged BACKLOG.md into PLAN.md Post-MVP section (v1.1 ~ v2.3)
