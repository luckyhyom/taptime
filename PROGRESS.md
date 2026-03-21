# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** MVP complete (Phases 0-7). Post-MVP planning available.
- **Last Updated:** 2026-03-21
- **Blocker:** None

## Notes for Next Agent

### Where We Are

All MVP features are implemented and code-level polish is done:
- Phases 0-6: fully complete (planning, foundation, presets, timer, history, stats, settings)
- Phase 7: code fixes done, iOS simulator build confirmed (no build errors)
- 57 tests passing, 0 analyzer issues
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

### 2026-03-21 — Phases 4-7 (this session)

- **Phase 4 (History):** date navigator, session list tiles, memo edit bottom sheet, swipe-to-delete
- **Phase 5 (Stats):** Today/Week tabs, per-preset bar charts, goal progress, 7-day bar chart, donut chart
- **Phase 6 (Settings):** theme toggle, sound/vibration switches, data reset with cascade + re-seed
- **Phase 7 (Polish):** connected daily progress to PresetCard, fixed DonutPainter repaint, stopwatch clamp, settings reset await
- Refactored `presetMapProvider` to `app_providers.dart` for cross-feature use
- Merged BACKLOG.md into PLAN.md Post-MVP section (v1.1 ~ v2.3)
