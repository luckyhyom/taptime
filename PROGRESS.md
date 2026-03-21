# Taptime - Progress

> **Current state and handoff context for the next agent.**
> Agents: read PLAN.md first, then this file.
> Older history is in git log — this file only keeps recent work.

## Current Status

- **Active Phase:** Phase 3 (Timer) — Phase 2 complete
- **Last Updated:** 2026-03-21
- **Blocker:** None

## Notes for Next Agent

### Immediate Next Task

Phase 3: Timer screen. Start with:
1. Timer screen UI (countdown display, progress ring, start/pause/stop controls)
2. Countdown timer logic in `TimerNotifier` (Notifier per ADR-0008)
3. Session auto-save on completion

### Environment

- Flutter 3.41.4, Xcode 26.3, CocoaPods 1.16.2
- Android SDK: deferred (SDK 36 + BuildTools 28.0.3 needed later)
- iOS simulator: use `flutter run` (physical device needs Xcode code signing)

### Key Context

- All documents indexed in `docs/INDEX.md`
- Development rules: `.claude/rules/` (project) + `~/.claude/rules/` (universal)
- ADR-0008: Use `Notifier` for interactive state (forms, timer), `StreamProvider` for read-only reactive data
- Design system: user has `design/base.html` (new design) and `design/current.html` (current Flutter design)
  - Decision on applying new design (`design/base.html` tokens) is pending user review
  - New design uses Manrope + Inter fonts, primary `#00000b`, secondary `#b71d3f`
  - Tab bar structure stays as-is (Home/Stats/Settings per existing plan)

### Phase 2 Architecture Notes

- `PresetFormNotifier` (`AutoDisposeFamilyNotifier<PresetFormState, String?>`) handles create/edit
  - `null` arg = create mode, non-null arg = edit mode (loads from DB via microtask)
- Home screen: `ConsumerStatefulWidget` with `_isReordering` local state
  - Normal mode: 2-col GridView; edit mode: ReorderableListView
  - Reorder saves via `presetRepositoryProvider.updateSortOrder(Map<String,int>)`
- All 56 tests still passing

## Recent Work

### 2026-03-21 — Planning Refinement + Phase 2 UI

- **Planning**: Redefined Taptime as automatic time management assistant (GPS opt-out, MacBook detection)
  - GPS: auto-starts timer on geofence entry, sends notification, user can cancel to delete record
  - Removed Google Calendar export; kept future read-only stats view in backlog
  - Removed v1.1 streak milestones, replaced v1.2 with Google Calendar read-only stats
  - Removed v2.4 widgets/Watch from backlog
  - Updated PRD.md, BACKLOG.md, CHANGELOG_PLANNING.md
- **Phase 2 UI**: Home screen reorder mode + preset form (create/edit/delete)
  - `preset_form_notifier.dart`: `PresetFormState` + `PresetFormNotifier` + `presetFormProvider`
  - `preset_form_screen.dart`: full form UI with icon picker, color picker, daily goal stepper
  - `home_screen.dart`: upgraded to `ConsumerStatefulWidget`, added reorder mode, history button
- **Design comparison**: created `design/current.html` (current Flutter) vs `design/base.html` (new design)

### 2026-03-19 — Design Completeness Review

- Safe enum parsing, model constructor assertions, `AppException` hierarchy, `toMap()`/`fromMap()`
- DB migration scaffold, ADR-0008 Notifier pattern, testing rules
- 56 tests — model validation, repository CRUD, cascade delete, enum fallback
