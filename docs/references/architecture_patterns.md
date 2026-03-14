# Architecture Patterns Research (Flutter)

> **Researched:** 2026-03-14
> **Purpose:** Select architecture level for a personal Flutter app
> **Decision:** ADR-0002, applied in `.claude/rules/architecture.md`

## Clean Architecture (3-layer)

- Presentation / Domain / Data layers
- Domain layer: entities, use cases, repository interfaces (pure Dart)
- Pros: maximum separation, testable, swappable
- Cons: 8-12 files per feature, use cases often pass-through, over-engineered for small apps
- Verdict: **Too heavy for this project**

## 2-Layer MVVM + Repository (Selected)

- UI (presentation) + Data (repository + data source)
- Flutter official architecture guide (2025) recommends this
- Add domain layer per-feature only when complexity demands it
- Pros: less boilerplate, sufficient separation, Flutter-official
- Cons: less strict boundaries

## Feature-first vs Layer-first

| Aspect | Layer-first | Feature-first |
|--------|-------------|---------------|
| Structure | `lib/data/`, `lib/domain/`, `lib/presentation/` | `lib/features/auth/`, `lib/features/timer/` |
| Scales to | Small apps | Medium-to-large apps |
| Co-location | Must jump across directories | All files for a feature together |
| 2025 trend | Declining | **Preferred** |

## DDD in Flutter (Selective Adoption)

- **Useful:** Entity (objects with identity), Value Object (immutable validated types via `freezed`)
- **Not useful for this scale:** Aggregates, Bounded Contexts, Domain Events
- DDD is a mindset, not all-or-nothing

## SOLID in Flutter

- **SRP:** Each widget/class does one thing — most impactful principle
- **DIP:** High-level modules depend on abstractions, not implementations — enables testability
- **OCP/LSP/ISP:** Follow naturally from SRP + DIP in practice

## State Management Comparison

| Library | Pros | Cons | Verdict |
|---------|------|------|---------|
| Riverpod | Type-safe, no BuildContext, less boilerplate | Learning curve | **Selected** |
| BLoC/Cubit | Mature, strict pattern | Heavy boilerplate | Good but overkill |
| Provider | Simple, official | Less type-safe | Superseded by Riverpod |
| GetX | Minimal boilerplate | Poor testability | Not recommended |

## Notable Templates

- **Very Good CLI:** BLoC-based, 100% test coverage, production-proven
- **Andrea Bizzotto's Riverpod Architecture:** 4-layer, Riverpod-native, feature-first
- **Flutter Official Architecture Case Study:** MVVM, 2-layer

## Sources

- [Flutter Official: App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Andrea Bizzotto: Flutter App Architecture with Riverpod](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)
- [Coding Studio: Clean Architecture in Flutter 2025](https://coding-studio.com/clean-architecture-in-flutter/)
- [DEV: DDD in Flutter — Too Much or Just Right](https://dev.to/alaminkarno/ddd-domain-driven-design-in-flutter-too-much-or-just-right-d1g)
- [freeCodeCamp: SOLID Principles in Flutter](https://www.freecodecamp.org/news/implement-the-solid-principles-in-flutter-and-dart/)
