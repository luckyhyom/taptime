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
- [ ] GoRouter routing setup (home, timer, preset form, history, stats, settings)
- [x] Drift DB schema definition (Preset, Session, UserSettings)
- [x] Repository interfaces (domain layer)
- [x] Local repository implementations (infrastructure layer)
- [x] Auth/Calendar service interfaces + no-op implementations
- [ ] Riverpod provider setup

## Phase 2: Presets

- [ ] Home screen with preset grid (2 columns)
- [ ] Preset card widget (icon, name, duration, daily progress)
- [ ] Default presets on first launch (Study, Exercise, Reading)
- [ ] Preset create screen (name, duration, icon, color, daily goal)
- [ ] Preset edit screen
- [ ] Preset delete with confirmation
- [ ] Preset reorder (drag-and-drop)

## Phase 3: Timer

- [ ] Timer screen UI (countdown, progress ring, controls)
- [ ] Countdown timer logic (start, pause, resume, stop)
- [ ] Background timer support
- [ ] Timer state persistence (crash recovery)
- [ ] Session auto-save on completion
- [ ] Session save on manual stop (with confirmation)
- [ ] Notification sound + vibration on completion

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

## Backlog (Post-MVP)

### v1.1 — Motivation & Extended Stats
- [ ] Heatmap calendar (GitHub-style activity visualization)
- [ ] Streak tracking (consecutive days meeting goals)
- [ ] Streak milestone celebrations (7, 30, 100 days)
- [ ] Break timer (5m short / 15m long)
- [ ] Weekly/monthly goals
- [ ] Monthly statistics view

### v1.2 — Google Calendar & Effects
- [ ] Google Calendar integration (client-side OAuth)
- [ ] Motivational effects (completion animations)
- [ ] Achievement badges

### v2.0 — Cloud Backup
- [ ] Supabase integration
- [ ] Google/Apple social login (backup-only, no custom accounts)
- [ ] Cloud backup/restore

### v2.1 — Platform Extensions
- [ ] Home screen widget
- [ ] Apple Watch / Wear OS support
