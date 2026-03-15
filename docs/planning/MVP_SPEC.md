# Taptime - MVP Specification

> **Version:** 1.0
> **Last Updated:** 2026-03-14
> **Scope:** Minimum Viable Product — personal use, local storage only

## 1. MVP Goal

Deliver a functional time tracking app where a user can:
1. Create presets for activities
2. Tap a preset to start a Pomodoro timer
3. View recorded sessions and basic statistics
4. Set and track daily goals

**Out of scope for MVP:** authentication, cloud sync, Google Calendar, break timers, effects/animations, streaks, weekly/monthly goals, data export, widgets.

---

## 2. MVP Features

### 2.1 Home Screen (Preset Grid)

**Priority:** P0

- Display presets in a grid layout (2 columns)
- Each preset card shows: icon, name, duration, today's progress bar
- Tap a preset card → navigate to Timer screen
- Long-press → edit preset
- FAB (floating action button) → create new preset
- Provide 3 default presets on first launch:
  - Study (25 min, book icon, blue)
  - Exercise (30 min, dumbbell icon, red)
  - Reading (20 min, glasses icon, green)

### 2.2 Preset Create/Edit Screen

**Priority:** P0

- Fields:
  - Name (required, max 20 chars)
  - Duration in minutes (required, 1-180 range, default 25)
  - Icon (pick from predefined icon set, ~20 options)
  - Color (pick from predefined palette, ~8 options)
  - Daily goal in minutes (optional, 0 = no goal)
- Save / Delete buttons
- Validation: name cannot be empty, duration must be > 0

### 2.3 Timer Screen

**Priority:** P0

- Large countdown display (MM:SS)
- Circular progress indicator
- Preset name and icon displayed
- Controls:
  - **Pause/Resume** toggle button
  - **Stop** button (with confirmation dialog)
- Timer states: `running` → `paused` → `running` / `stopped` / `completed`
- On completion:
  - Play system notification sound
  - Vibrate device
  - Show completion dialog with session summary
  - Auto-save session
- On manual stop:
  - Confirm dialog: "Stop timer? X minutes will be recorded."
  - Save session with elapsed time
- Timer persists in background (use Flutter background service / isolate)
- Timer state saved to local DB (crash recovery)

### 2.4 Session History Screen

**Priority:** P0

- List of recorded sessions grouped by date
- Each session entry shows:
  - Preset icon + name
  - Start time → End time
  - Duration
  - Status badge (completed / stopped)
- Tap session → edit memo or delete
- Pull-to-refresh (for future sync compatibility)

### 2.5 Statistics Screen

**Priority:** P1

- **Today tab:**
  - Total time recorded today
  - Per-preset breakdown (horizontal bar chart)
  - Goal progress per preset (progress bar with percentage)
- **Week tab:**
  - Daily total bar chart (Mon-Sun)
  - Per-preset pie/donut chart for the week
- Date navigation (previous/next day/week)

### 2.6 Settings Screen

**Priority:** P1

- Theme toggle (Light / Dark)
- Timer sound on/off
- Vibration on/off
- Reset all data (with confirmation)
- App version info

---

## 3. Data Model

### 3.1 Preset

```dart
class Preset {
  String id;          // UUID v4
  String name;        // e.g., "Study"
  int durationMin;    // Timer duration in minutes
  String icon;        // Icon identifier (e.g., "book")
  String color;       // Hex color (e.g., "#4A90D9")
  int dailyGoalMin;   // Daily goal in minutes (0 = no goal)
  int sortOrder;      // Position in grid
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 3.2 Session

```dart
class Session {
  String id;          // UUID v4
  String presetId;    // FK to Preset
  DateTime startedAt; // Timer start timestamp
  DateTime endedAt;   // Timer end timestamp
  int durationSeconds;// Precise duration
  String status;      // "completed" | "stopped"
  String? memo;       // Optional post-session note
  DateTime createdAt;
}
```

### 3.3 UserSettings

```dart
class UserSettings {
  String themeMode;       // "light" | "dark" | "system"
  bool soundEnabled;      // default: true
  bool vibrationEnabled;  // default: true
}
```

---

## 4. Architecture

> **Canonical source:** `.claude/rules/architecture.md` — see ADR-0002 for decision rationale.

### 4.1 Overview

**Pattern:** 2-layer MVVM + Repository (feature-first folder structure)

```
UI (presentation) → Data (repository + data source)
                  ↘ shared models/interfaces
```

- UI layer depends on shared models and repository interfaces — never on data implementations
- Data layer implements repository interfaces — never imports from UI
- Add a Domain layer inside a feature only when business logic grows complex

### 4.2 Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | **2-layer MVVM + Repository** | Full Clean Architecture creates excessive boilerplate for this app's complexity (ADR-0002) |
| State management | **Riverpod** | Type-safe, testable, no BuildContext dependency (ADR-0003) |
| Local database | **Drift** | Type-safe SQLite, reactive streams, actively maintained (ADR-0007) |
| Routing | **GoRouter** | Declarative, deep link ready |
| DI | **Riverpod providers** | Built-in with state management; wires interface to implementation |

### 4.3 Repository Pattern (Swappable Data Layer)

```dart
// shared/repositories/ - abstract interface
abstract class SessionRepository {
  Future<List<Session>> getSessionsByDate(DateTime date);
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end);
  Future<void> saveSession(Session session);
  Future<void> deleteSession(String id);
  Future<void> updateSession(Session session);
}

// features/history/data/ - local implementation (MVP)
class SessionRepositoryImpl implements SessionRepository {
  // Uses Drift (SQLite)
}
```

```dart
// shared/services/ - calendar interface (for future Google Calendar)
abstract class CalendarService {
  Future<void> exportSession(Session session);
  Future<void> exportSessions(List<Session> sessions);
  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end);
}

// No-op implementation (MVP) — placeholder for future integration
class NoOpCalendarService implements CalendarService { ... }
```

### 4.4 Folder Structure

```
lib/
├── main.dart
├── app.dart                     # MaterialApp, theme, router
├── core/                        # Shared utilities
│   ├── theme/                   # Light/dark theme, colors, typography
│   ├── constants/               # App-wide constants, default presets
│   ├── utils/                   # Date, duration helpers
│   └── router/                  # GoRouter configuration
├── features/
│   ├── preset/
│   │   ├── data/                # Repository impl, data source
│   │   └── ui/                  # Screen, widgets, view model
│   ├── timer/
│   │   ├── data/
│   │   └── ui/
│   ├── home/
│   │   └── ui/                  # Home has no own data, uses preset/session repos
│   ├── history/
│   │   ├── data/
│   │   └── ui/
│   ├── stats/
│   │   ├── data/
│   │   └── ui/
│   └── settings/
│       ├── data/
│       └── ui/
└── shared/                      # Cross-feature shared code
    ├── models/                  # Preset, Session, UserSettings entities
    ├── repositories/            # Abstract repository interfaces
    └── services/                # Abstract service interfaces (calendar, auth)
```

---

## 5. Screen Flow

```
┌──────────┐     tap preset    ┌─────────────┐
│          │ ───────────────►  │             │
│   Home   │                   │    Timer    │
│  Screen  │  ◄─────────────── │   Screen    │
│          │   complete/stop   │             │
├──────────┤                   └─────────────┘
│ [+] FAB  │──► Preset Form
├──────────┤
│ Nav Bar  │
│ ┌──┬──┬──┤
│ │H │St│Se│
│ │o │at│tt│
│ │me│s │ng│
└─┴──┴──┴──┘
      │   │
      ▼   ▼
  ┌──────┐ ┌──────────┐
  │Stats │ │ Settings │
  │Screen│ │  Screen  │
  └──────┘ └──────────┘

  History: accessible from Home (icon button in app bar)
```

---

## 6. Navigation

- **Bottom Navigation Bar** with 3 tabs: Home, Statistics, Settings
- **History** accessible via icon button in Home app bar
- **Timer** is a full-screen push route (no bottom nav)
- **Preset Form** is a push route from Home

---

## 7. MVP Milestones

| # | Milestone | Features | Est. Screens |
|---|-----------|----------|-------------|
| 1 | **Foundation** | Project setup, theme, routing, DB schema, repository interfaces | 0 |
| 2 | **Presets** | Home screen, preset CRUD, default presets | 2 |
| 3 | **Timer** | Timer screen, countdown logic, background persistence, session save | 1 |
| 4 | **History** | Session list, grouped by date, edit memo, delete | 1 |
| 5 | **Statistics** | Daily/weekly charts, goal progress | 1 |
| 6 | **Settings** | Theme toggle, sound/vibration, reset data | 1 |
| 7 | **Polish** | Animations, edge cases, testing, performance | 0 |

---

## 8. Dependencies (Flutter Packages)

| Package | Purpose | Version Strategy |
|---------|---------|-----------------|
| `flutter_riverpod` | State management | Latest stable |
| `drift` + `drift_flutter` | Local database | Latest stable |
| `go_router` | Navigation/routing | Latest stable |
| `fl_chart` | Charts for statistics | Latest stable |
| `uuid` | Generate unique IDs | Latest stable |
| `flutter_local_notifications` | Timer completion alerts | Latest stable |
| `vibration` | Haptic feedback | Latest stable |
| `audioplayers` | Timer completion sound | Latest stable |

---

## 9. Quality Checklist (MVP Exit Criteria)

- [ ] All P0 features functional
- [ ] Timer works correctly in background
- [ ] Timer state survives app restart
- [ ] Sessions saved with correct timestamps
- [ ] Statistics display accurate data
- [ ] Light and dark themes work
- [ ] No crashes on basic user flows
- [ ] Tested on iOS and Android emulators
