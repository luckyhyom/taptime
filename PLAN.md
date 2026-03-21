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
- [x] Stopwatch mode (durationMin=0, unlimited time tracking)

## Phase 4: History

- [x] Session history screen (grouped by date)
- [x] Session list tile (icon, name, time range, duration, status)
- [x] Edit session memo
- [x] Delete session

## Phase 5: Statistics

- [x] Statistics screen with tab layout (Today / Week)
- [x] Today: total time, per-preset bar chart, goal progress bars
- [x] Week: daily totals bar chart, category donut chart
- [x] Date navigation (prev/next)

## Phase 6: Settings

- [x] Settings screen
- [x] Theme toggle (light/dark/system)
- [x] Sound on/off
- [x] Vibration on/off
- [x] Reset all data (with confirmation)
- [x] App version display

## Phase 7: Polish

- [x] Edge case handling (empty states, error states)
- [x] Performance optimization
- [ ] iOS + Android emulator testing
- [x] Bug fixes

---

## Post-MVP

### v1.1 — Motivation & Extended Stats

- [ ] Heatmap calendar (GitHub-style activity visualization)
- [ ] Streak tracking (consecutive days meeting goals)
- [ ] Break timer (5m short / 15m long)
- [ ] Weekly/monthly goals
- [ ] Monthly statistics view

### v1.2 — Google Calendar Statistics (Read-Only)

> View Google Calendar events inside Taptime for context — not sync or export.

- [ ] Google Calendar read-only integration (OAuth, view events)
- [ ] Calendar context view alongside Taptime sessions

### v2.0 — Cloud Backup

> Prerequisite for v2.1+ features that require cross-device data sharing.

- [ ] Supabase integration
- [ ] Google/Apple social login (backup-only, no custom accounts)
- [ ] Cloud backup/restore

### v2.1 — Location-Based Auto Tracking (iOS)

> Auto-detect arrival at registered places and prompt to start a timer.
> Depends on: v2.0 (Supabase).

- [ ] Add `LocationTrigger` model (placeName, lat/lng, radius)
- [ ] Add optional location field to Preset
- [ ] Location registration UI (map or current location)
- [ ] Geofence monitoring service (Platform Channel or package)
- [ ] Entry/exit notification handling
- [ ] Auto-start option (skip confirmation)
- [ ] Settings: enable/disable location tracking globally

### v2.2 — macOS Activity Monitor (Companion App)

> Separate native Swift menu bar app. Shares data via Supabase.
> Depends on: v2.0 (Supabase).

- [ ] Swift project setup (menu bar app, SPM)
- [ ] App switch tracker (NSWorkspace notifications)
- [ ] Browser URL tracker (AppleScript for Chrome/Safari)
- [ ] Idle detection (CGEventSource, 5-min threshold)
- [ ] Rule-based classifier with JSON config
- [ ] Filter engine (blocklist/allowlist)
- [ ] Local SQLite storage
- [ ] Supabase sync (periodic upload)
- [ ] Settings UI (SwiftUI): categories, rules, filters
- [ ] Launch at login (SMAppService)
- [ ] Core ML text classifier (after data accumulation)
- [ ] Local LLM integration (experimental, MLX embedded)

### v2.3 — Life Pattern Dashboard

> Unified analytics combining iOS + macOS data.
> Depends on: v2.1 + v2.2.

- [ ] Daily timeline — hour-by-hour visualization
- [ ] Category time distribution — donut chart
- [ ] Day-of-week patterns
- [ ] Device comparison — Mac vs Mobile time breakdown
- [ ] Location insights — time spent per registered place
- [ ] Productive vs unproductive ratio

---

> Post-MVP details and technical notes → [BACKLOG.md](BACKLOG.md)
