*Read this in other languages: [English](README.md), [한국어](README_KO.md)*

# Taptime

**Tap a preset. Start a timer. Build your habits.**

Taptime is a time management app that makes tracking your activities as simple as a single tap. Create presets for your daily routines — study, exercise, reading — and let Taptime handle the rest.

## Features

### Core
- **Preset-based timer** — Create custom activity presets with name, duration, icon, and color
- **One-tap start** — Tap a preset card on the home screen to start a timer instantly
- **Stopwatch mode** — Set duration to 0 for unlimited time tracking
- **Break timer** — 5-minute short break or 15-minute long break after sessions

### Tracking & Statistics
- **Automatic session logging** — Completed and stopped sessions are saved automatically
- **Manual session entry** — Record past activities you forgot to track
- **Daily/Weekly/Monthly stats** — Bar charts, donut charts, goal progress bars
- **Per-preset heatmap** — GitHub-style contribution graph for each activity
- **Streak tracking** — Consecutive days meeting your goals

### Location Intelligence
- **Geofence auto-tracking** — Register places (library, gym, cafe) and Taptime automatically starts/stops timers when you arrive or leave
- **Reverse geocoding** — Tap the map and the place name fills in automatically
- **Smart notifications** — "Study timer started (Library)" when you arrive

### Cloud Sync
- **Supabase backend** — Google and Apple sign-in
- **Cross-device sync** — Your presets, sessions, and settings sync across devices
- **Offline-first** — Everything works without internet, syncs when connected

### Organization
- **Preset archiving** — Hide presets you're not using without losing session history
- **Drag-and-drop reorder** — Arrange your home screen grid
- **Memo on sessions** — Add notes to any session

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (iOS + Android) |
| State Management | Riverpod |
| Local Database | Drift (SQLite) |
| Cloud Backend | Supabase (PostgreSQL + Auth) |
| Architecture | 2-layer MVVM + Repository Pattern |
| Location | CLLocationManager (iOS native via Platform Channel) |
| Maps | flutter_map + OpenStreetMap |
| Search | Kakao Local API |

## Architecture

```
lib/
├── core/          # Theme, router, database, providers, constants
├── features/      # Feature-first modules
│   ├── home/      # Preset grid, active timer display
│   ├── timer/     # Countdown, stopwatch, break timer
│   ├── preset/    # Create, edit, archive presets
│   ├── history/   # Session list, memo editor, manual entry
│   ├── stats/     # Daily/weekly/monthly analytics
│   ├── settings/  # Theme, sound, data reset, archived presets
│   ├── location/  # Geofence manager, map picker
│   ├── sync/      # Supabase sync engine
│   └── auth/      # Google + Apple sign-in
└── shared/        # Models, repository interfaces, service interfaces
```

## Getting Started

```bash
# Clone
git clone https://github.com/your-repo/taptime.git
cd taptime

# Install dependencies
flutter pub get

# Run (iOS simulator)
flutter run --dart-define-from-file=.env

# Run (physical device)
flutter run -d <device-id> --dart-define-from-file=.env
```

> See [`docs/guides/SETUP.md`](docs/guides/SETUP.md) for detailed setup instructions including Supabase configuration.

## Documentation

See [`docs/INDEX.md`](docs/INDEX.md) for the full documentation map.

## For AI Agents

See [`CLAUDE.md`](CLAUDE.md).
