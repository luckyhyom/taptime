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
