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

### 4.1 Overview

```
┌─────────────────────────────────────────────┐
│                    UI Layer                  │
│         (Screens, Widgets, Theme)           │
├─────────────────────────────────────────────┤
│               State Management              │
│              (Riverpod / Bloc)              │
├─────────────────────────────────────────────┤
│                 Domain Layer                │
│     (Use Cases, Entities, Interfaces)       │
├─────────────────────────────────────────────┤
│            Infrastructure Layer             │
│  ┌──────────┐ ┌──────────┐ ┌─────────────┐ │
│  │  Local DB │ │ Calendar │ │    Auth      │ │
│  │  (Isar)  │ │ Adapter  │ │  (NoAuth)    │ │
│  └──────────┘ └──────────┘ └─────────────┘ │
└─────────────────────────────────────────────┘
```

### 4.2 Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | **Riverpod** | Type-safe, testable, no BuildContext dependency |
| Local database | **Isar** | Fast, Flutter-native, supports complex queries |
| Architecture | **Clean Architecture** | Separation of concerns, easy to swap infra layer |
| Routing | **GoRouter** | Declarative, deep link ready |
| DI | **Riverpod providers** | Built-in with state management choice |

### 4.3 Repository Pattern (Swappable Infrastructure)

```dart
// Domain layer - abstract interface
abstract class SessionRepository {
  Future<List<Session>> getSessionsByDate(DateTime date);
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end);
  Future<void> saveSession(Session session);
  Future<void> deleteSession(String id);
  Future<void> updateSession(Session session);
}

// Infrastructure layer - local implementation (MVP)
class LocalSessionRepository implements SessionRepository {
  // Uses Isar DB
}

// Infrastructure layer - future cloud implementation
// class CloudSessionRepository implements SessionRepository {
//   // Uses Supabase/Firebase
// }
```

```dart
// Domain layer - calendar interface (for future Google Calendar)
abstract class CalendarService {
  Future<void> exportSession(Session session);
  Future<void> exportSessions(List<Session> sessions);
  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end);
}

// Infrastructure - no-op implementation (MVP)
class NoOpCalendarService implements CalendarService {
  // Does nothing - placeholder for future integration
}
```

```dart
// Domain layer - auth interface (for future auth)
abstract class AuthService {
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser> signIn();
  Future<void> signOut();
  bool get isAuthenticated;
}

// Infrastructure - pass-through implementation (MVP)
class LocalAuthService implements AuthService {
  // Always returns a local-only user, no real auth
}
```

### 4.4 Folder Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, theme, router
├── core/
│   ├── theme/
│   │   ├── app_theme.dart      # Light/dark theme definitions
│   │   └── app_colors.dart     # Color constants
│   ├── constants/
│   │   └── app_constants.dart  # Default presets, limits
│   └── utils/
│       ├── date_utils.dart
│       └── duration_utils.dart
├── domain/
│   ├── entities/
│   │   ├── preset.dart
│   │   ├── session.dart
│   │   └── user_settings.dart
│   ├── repositories/
│   │   ├── preset_repository.dart      # Abstract
│   │   ├── session_repository.dart     # Abstract
│   │   └── settings_repository.dart    # Abstract
│   └── services/
│       ├── timer_service.dart          # Abstract
│       ├── calendar_service.dart       # Abstract
│       └── auth_service.dart           # Abstract
├── infrastructure/
│   ├── local/
│   │   ├── local_preset_repository.dart
│   │   ├── local_session_repository.dart
│   │   └── local_settings_repository.dart
│   ├── calendar/
│   │   └── noop_calendar_service.dart
│   ├── auth/
│   │   └── local_auth_service.dart
│   └── timer/
│       └── flutter_timer_service.dart
├── presentation/
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── preset_card.dart
│   │   └── home_providers.dart
│   ├── timer/
│   │   ├── timer_screen.dart
│   │   ├── timer_display.dart
│   │   └── timer_providers.dart
│   ├── preset/
│   │   ├── preset_form_screen.dart
│   │   └── preset_providers.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   ├── session_tile.dart
│   │   └── history_providers.dart
│   ├── statistics/
│   │   ├── statistics_screen.dart
│   │   ├── widgets/
│   │   │   ├── daily_chart.dart
│   │   │   ├── weekly_chart.dart
│   │   │   └── goal_progress.dart
│   │   └── statistics_providers.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── settings_providers.dart
└── providers/
    └── app_providers.dart       # Global DI setup
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
| `isar` | Local database | Latest stable |
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
