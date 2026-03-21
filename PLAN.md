# Taptime - Plan

> **What needs to be done.** Milestones, tasks, and priorities.
> Agents: read this first to understand what work exists and what to pick up next.

## Phase 0: Planning & Design

- [x] Product concept and feature brainstorming
- [x] Competitive analysis
- [x] Technology stack selection
- [x] PRD (`docs/PRD.md`)
- [x] MVP scope definition (`docs/MVP_SPEC.md`)
- [x] Architecture design
- [x] Design system research
- [x] Reference materials organization
- [x] System design discussion and finalization
- [x] Skills and hooks setup (`.claude/skills/`, `.claude/settings.json`)

## Phase 1: Foundation

- [x] Flutter project initialization (`flutter create`)
- [x] Folder structure setup (feature-first)
- [x] Theme configuration (light/dark, color palette, typography)
- [x] GoRouter routing setup (home, timer, preset form, history, stats, settings)
- [x] Drift DB schema definition (Preset, Session, UserSettings, ActiveTimers)
- [x] Repository interfaces (shared layer)
- [x] Local repository implementations (data layer)
- [x] Auth/Calendar service interfaces + no-op implementations
- [x] Data layer design review — 8 gaps fixed (`docs/issues/FEAT-001_data-layer-review.md`)
- [x] Riverpod provider setup
- [x] Design completeness review — safe enum parsing, model validation, error hierarchy, toMap/fromMap serialization, migration scaffold, architecture rules, ADR-0008 notifier pattern, model + repository tests

## Phase 2: Presets

- [x] Home screen with preset grid (2 columns)
- [x] Preset card widget (icon, name, duration, daily progress)
- [x] Default presets on first launch (Study, Exercise, Reading)
- [x] Preset create screen (name, duration, icon, color, daily goal)
- [x] Preset edit screen
- [x] Preset delete with confirmation
- [x] Preset reorder (drag-and-drop)

## Phase 3: Timer

- [x] Timer screen UI (countdown, progress ring, controls)
- [x] Countdown timer logic (start, pause, resume, stop)
- [x] Background timer support
- [x] Timer state persistence (crash recovery)
- [x] Session auto-save on completion
- [x] Session save on manual stop (with confirmation)
- [x] Notification sound + vibration on completion

## Phase 4: History

- [ ] Session history screen (grouped by date)
- [ ] Session list tile (icon, name, time range, duration, status)
- [ ] Edit session memo
- [ ] Delete session

## Phase 5: Statistics

- [ ] Statistics screen with tab layout (Today / Week)
- [ ] Today: total time, per-preset bar chart, goal progress bars
- [ ] Week: daily totals bar chart, category donut chart
- [ ] Date navigation (prev/next)

## Phase 6: Settings

- [ ] Settings screen
- [ ] Theme toggle (light/dark/system)
- [ ] Sound on/off
- [ ] Vibration on/off
- [ ] Reset all data (with confirmation)
- [ ] App version display

## Phase 7: Polish

- [ ] Edge case handling (empty states, error states)
- [ ] Performance optimization
- [ ] iOS + Android emulator testing
- [ ] Bug fixes

---

> Post-MVP features → [BACKLOG.md](BACKLOG.md)
