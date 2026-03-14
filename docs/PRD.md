# Taptime - Product Requirements Document

> **Version:** 1.0
> **Last Updated:** 2026-03-14
> **Status:** Draft

## 1. Overview

**Taptime** is a time management app that lets users record time effortlessly using customizable presets with a built-in Pomodoro timer. Users tap a preset to start a timer, and completed sessions are automatically logged for statistics and future Google Calendar sync.

### 1.1 Vision

Make time tracking as frictionless as a single tap — so users actually do it consistently.

### 1.2 Target Users

- **Primary:** Individuals who want to track and improve how they spend their time (students, freelancers, self-learners, productivity enthusiasts)
- **Future:** Small teams / study groups with shared tracking and rankings

### 1.3 Platform

- **Flutter** (iOS + Android, with potential web support)
- **Local-first** storage with future cloud sync capability

---

## 2. Core Concepts

### 2.1 Preset

A user-defined template for a timed activity.

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Activity label | "Study", "Exercise" |
| `duration` | Default timer duration (minutes) | 25, 60 |
| `icon` | Visual identifier | book, dumbbell |
| `color` | Category color | `#4A90D9` |
| `dailyGoal` | Optional daily target (minutes) | 120 |
| `weeklyGoal` | Optional weekly target (minutes) | 600 |

### 2.2 Session

A recorded time block created when a timer runs.

| Field | Description |
|-------|-------------|
| `presetId` | Associated preset |
| `startedAt` | Timestamp when timer started |
| `endedAt` | Timestamp when timer stopped/completed |
| `durationMinutes` | Rounded duration in minutes |
| `durationSeconds` | Precise duration in seconds (internal) |
| `status` | `completed` / `stopped` |
| `memo` | Optional one-line note (post-session) |

### 2.3 Daily Goal

Per-preset or global daily/weekly time targets. Progress is calculated from recorded sessions.

---

## 3. Feature Specification

### 3.1 Preset Management

- **Create** custom presets with name, duration, icon, color
- **Edit** existing presets
- **Delete** presets (sessions remain in history)
- **Reorder** presets on home screen via drag-and-drop
- **Default presets** provided on first launch (e.g., Study 25m, Exercise 30m, Reading 20m)

### 3.2 Timer

- Tap a preset to start a **countdown Pomodoro timer**
- Timer displays: remaining time, preset name, progress ring/bar
- Controls: **Pause**, **Resume**, **Stop**
- On completion: sound/vibration notification, auto-save session
- On manual stop: save session with actual elapsed time
- Optional: configurable break timer after completion (5m short / 15m long)
- Background timer support (continues when app is minimized)

### 3.3 Session Recording

- Sessions saved automatically on timer completion or manual stop
- Stored with second-level precision internally, displayed in minutes
- Optional post-session memo (one-line reflection)
- Manual session entry (add past sessions by hand)
- Edit/delete recorded sessions

### 3.4 Statistics & Visualization

- **Daily view:** timeline of sessions, total time per preset
- **Weekly view:** bar chart of daily totals, category breakdown
- **Monthly view:** heatmap calendar (intensity = total hours), trends
- **Goal progress:** daily/weekly goal completion percentage per preset
- **Streaks:** consecutive days meeting goals

### 3.5 Goal System

- Set daily target hours per preset (e.g., Study: 2h/day)
- Set weekly target hours per preset
- Set global daily target (total across all presets)
- Visual progress indicator on home screen
- Streak counter for consecutive goal completions

### 3.6 Motivational Effects (Post-MVP)

- Completion animation on timer finish (confetti, glow, etc.)
- Streak celebration milestones (7 days, 30 days, 100 days)
- Cumulative visualization (e.g., blocks stacking, garden growing)
- Achievement badges

### 3.7 Google Calendar Integration (Post-MVP)

- Export sessions as calendar events
- Architecture: repository pattern with calendar adapter interface
- Target: bidirectional sync (read calendar events, write sessions)
- OAuth2 authentication flow for Google API

### 3.8 Authentication (Post-MVP)

- Architecture designed for auth injection from day one
- Auth interface defined but implemented as `NoAuth` (pass-through) in MVP
- Future: email/password, Google Sign-In, Apple Sign-In
- Future: cloud sync of presets and sessions across devices

---

## 4. Design Principles

### 4.1 Visual

- **Minimal palette:** 2-3 colors maximum (primary, accent, neutral)
- **Typography-driven:** clean, readable, generous whitespace
- **Dark mode** support from the start (Flutter ThemeData)

### 4.2 UX

- Home screen = preset grid. One tap to start.
- Maximum 2 taps to reach any feature
- No onboarding walls — usable immediately with default presets
- Haptic feedback on timer start/stop

### 4.3 Suggested Color Palette

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | `#1A1A2E` (deep navy) | `#E8E8F0` (soft white) |
| Accent | `#E94560` (coral red) | `#E94560` (coral red) |
| Background | `#FAFAFA` (off-white) | `#16213E` (dark blue) |

---

## 5. Non-Functional Requirements

| Requirement | Target |
|------------|--------|
| App launch to usable | < 2 seconds |
| Timer accuracy | +/- 1 second |
| Offline capability | 100% features work offline |
| Local storage limit | Support 10,000+ sessions |
| Min platform | iOS 15+, Android 8+ (API 26) |
| Accessibility | Screen reader labels, sufficient contrast |
| Localization | Korean (primary), English (secondary) |

---

## 6. Success Metrics

| Metric | Target |
|--------|--------|
| Daily active usage | User opens app 5+ days/week |
| Session completion rate | > 70% of started timers completed |
| Goal achievement rate | > 50% of daily goals met |
| Retention (personal) | Consistent use after 30 days |

---

## 7. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Background timer killed by OS | Sessions lost | Persist timer state to local DB, restore on re-open |
| Data loss (local-only) | All history lost | Auto-backup to device storage / future cloud sync |
| Scope creep | Delayed launch | Strict MVP boundary (see MVP_SPEC.md) |
| Google Calendar API changes | Integration breaks | Repository pattern isolates external dependencies |

---

## 8. Future Roadmap

| Phase | Features |
|-------|----------|
| **MVP** | Presets, Timer, Session recording, Basic stats, Daily goals |
| **v1.1** | Weekly/monthly stats, Streaks, Break timer, Data export (CSV/JSON) |
| **v1.2** | Google Calendar sync, Motivational effects |
| **v2.0** | Authentication, Cloud sync, Multi-device |
| **v2.1** | Team features, Shared presets, Rankings |
| **v3.0** | Widgets, Watch app, Shortcuts integration |
