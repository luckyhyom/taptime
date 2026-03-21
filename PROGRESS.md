# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** Phase 4 (History) — Phase 3 complete
- **Last Updated:** 2026-03-21
- **Blocker:** None

## Notes for Next Agent

### Immediate Next Task

Phase 4: History screen. Start with:
1. Session history screen (grouped by date) using `SessionRepository.watchSessionsByDate`
2. Session list tile (preset icon, name, time range, duration, status badge)
3. Edit session memo / delete session

### Environment

- Flutter 3.41.4, Xcode 26.3, CocoaPods 1.16.2
- Android SDK: deferred (SDK 36 + BuildTools 28.0.3 needed later)
- iOS simulator: use `flutter run` (physical device needs Xcode code signing)

### Key Context

- All documents indexed in `docs/INDEX.md`
- Development rules: `.claude/rules/` (project) + `~/.claude/rules/` (universal)
- ADR-0008: Use `Notifier` for interactive state (forms, timer), `StreamProvider` for read-only reactive data
- Design system: user has `design/대안.html` (new design) and `design/current.html` (current Flutter design)
  - Decision on applying new design tokens is pending user review

### Phase 3 Architecture Notes

- `TimerNotifier` (`AutoDisposeFamilyNotifier<TimerState, String>`) manages countdown
  - Timestamp-based remaining calculation (not decrement-based) — accurate across background/foreground
  - `Timer.periodic(1s)` is only for UI refresh; actual time from `_startedAt` + `_pausedDurationSeconds`
  - Crash recovery: loads `ActiveTimer` from DB on build, restores or auto-completes
  - Old ActiveTimer for different preset is auto-saved as stopped session
  - `onAppResumed()` recalculates remaining when app returns to foreground
- `ProgressRing` widget: CustomPainter-based circular progress, 12시 방향 시작
- Timer screen: `ConsumerStatefulWidget` with `WidgetsBindingObserver` for lifecycle
  - `PopScope` prevents back during active timer, shows stop confirmation
  - Completion: `SystemSound.play` + `HapticFeedback.heavyImpact` respecting UserSettings
- Sound/vibration uses Flutter built-in APIs (no extra packages)
  - `audioplayers` + `flutter_local_notifications` can be added later for custom sounds + background notifications
- All 56 tests still passing

### Planning Review Notes (from this session)

Document inconsistencies found — not blocking, can fix separately:
- PRD.md header date not updated (still says 2026-03-14)
- PRD section numbering gap (3.8 → 3.10)
- Data Export/Import in PRD but not in any PLAN phase
- Manual Session Entry in PRD but not in PLAN/BACKLOG
- v2.1 GPS: user decided multiple sessions can start simultaneously at same location

## Recent Work

### 2026-03-21 — Phase 3: Timer Implementation

- `timer_notifier.dart`: `TimerStatus` enum, `TimerState` class, `TimerNotifier` with full countdown logic
  - start/pause/resume/stop, crash recovery from `ActiveTimer`, session auto-save
  - Timestamp-based remaining calculation, app lifecycle handling
- `widgets/progress_ring.dart`: `CustomPainter` circular progress ring
- `timer_screen.dart`: full UI — preset info, countdown display, progress ring, controls
  - Completion dialog, stop confirmation, `PopScope` back prevention
  - Sound + vibration on completion (UserSettings-aware)

### 2026-03-21 — Planning Refinement + Phase 2 UI

- **Planning**: Redefined Taptime as automatic time management assistant (GPS opt-out, MacBook detection)
- **Phase 2 UI**: Home screen reorder mode + preset form (create/edit/delete)
- **Design comparison**: created `design/current.html` vs `design/대안.html`
