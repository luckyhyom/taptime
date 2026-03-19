# Architecture

## Overview

- **Pattern:** MVVM + Repository Pattern
- **Layers:** 2-layer (UI + Data), add Domain layer only when complexity demands it
- **Folder structure:** Feature-first with layers inside each feature
- **State management:** Riverpod
- **Local DB:** Drift (SQLite)
- **Principles:** SOLID (focus on SRP + DIP), DDD concepts (Entity, Value Object only)

## Layer Rules

```
UI (presentation) → Data (repository + data source)
                  ↘ shared models/interfaces
```

- UI layer depends on shared models and repository interfaces — NEVER on data implementations
- Data layer implements repository interfaces — NEVER imports from UI
- Shared models and interfaces depend on nothing

## Folder Structure

```
lib/
├── app.dart                     # MaterialApp, theme, router
├── main.dart
├── core/                        # Shared utilities
│   ├── theme/                   # Light/dark theme, colors, typography
│   ├── constants/               # App-wide constants, default presets
│   ├── utils/                   # Date, duration helpers
│   └── router/                  # GoRouter configuration
├── features/
│   ├── preset/
│   │   ├── data/                # Repository impl, data source
│   │   │   ├── preset_repository_impl.dart
│   │   │   └── preset_local_data_source.dart
│   │   └── ui/                  # Screen, widgets, view model
│   │       ├── preset_form_screen.dart
│   │       ├── widgets/
│   │       └── preset_providers.dart
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

## Key Decisions

### Feature-first over Layer-first

All files for one feature are co-located. When working on the timer feature,
everything is under `lib/features/timer/`. No jumping across `lib/domain/`,
`lib/data/`, `lib/presentation/`.

### 2-layer over 3-layer (Clean Architecture)

Full Clean Architecture (presentation/domain/data) creates excessive
boilerplate for a small app. Use Cases that simply pass through to
repositories add no value. If a feature grows complex enough to need
isolated business logic, add a `domain/` subfolder inside that feature only.

### DDD: Selective Adoption

- **Entity:** Objects with identity (Preset, Session — identified by UUID)
- **Value Object:** Immutable validated types (use `freezed` package)
- **Skip:** Aggregates, Bounded Contexts, Domain Events — overkill for this scale

### Dependency Inversion

- Repository interfaces live in `shared/repositories/`
- Implementations live in `features/*/data/`
- Riverpod providers wire interface to implementation
- This allows swapping local DB for cloud (Supabase) without touching UI

## When to Add a Domain Layer

Add `features/<name>/domain/` only when:
- Business logic cannot live in the ViewModel without becoming complex
- Multiple repositories need orchestration for a single operation
- Logic needs to be tested independently from UI and data layers

## Error Handling

- Repository impls: catch Drift exceptions, throw `AppException` subtypes (`DatabaseException`, `NotFoundException`, etc.)
- Notifier: try/catch `AppException`, store error in state for UI to display
- UI: read error from Notifier state, show SnackBar or inline message
- Never let raw Drift/SQLite exceptions reach UI

## State Management Patterns

| Pattern | When to Use | Example |
|---------|------------|---------|
| `StreamProvider` | Read-only reactive data | Preset list, settings stream |
| `Notifier` / `AutoDisposeNotifier` | Interactive state with mutations | Forms, timer controls |
| `FutureProvider` | One-shot async data | App initialization |

- `StateNotifier` is Riverpod 1.x legacy — do not use
- `AsyncNotifier` — use only when async state loading is needed (e.g., fetching remote data)
- For form state, prefer synchronous `Notifier` with `isSubmitting` flag

## Cross-Feature Data Flow

- Features access other features' data via **shared repository providers** (defined in `lib/shared/`)
- NEVER import another feature's UI providers or widgets directly
- Example: Timer feature needs Preset data → inject `PresetRepository` via Riverpod, not `presetListProvider`
- Home aggregates data from multiple repos (preset, session) — this is fine via shared providers

## Database Migration

When changing the schema:

1. Increment `schemaVersion` in `app_database.dart`
2. Add a new `if (from < N)` block in `onUpgrade`
3. Use `m.addColumn()`, `m.createTable()`, etc. for schema changes
4. Test migration with both fresh install and upgrade scenarios

## Model Conventions

- Constructor validation: use `assert` for invariants (range, non-empty, consistency)
- Serialization: all models must have `toMap()` and `fromMap()` methods
- Enum fields: use `.name` for `toMap()`, `safeEnumByName()` for `fromMap()`
- DateTime fields: ISO 8601 strings in `toMap()`, accept both `DateTime` and `String` in `fromMap()`
- `@immutable` annotation on all model classes
- Identity-based equality (`==` by id) for entities
