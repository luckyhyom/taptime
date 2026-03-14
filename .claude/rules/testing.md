# Testing Rules

## Strategy

- Unit tests for all business logic (view models, repositories, services)
- Widget tests for reusable UI components
- Integration tests for critical user flows (MVP exit criteria)

## Conventions

- Test file: `<source_file>_test.dart`
- Test location: mirror `lib/` structure under `test/`
- Mocking: use `mocktail` (preferred over `mockito` for Dart)
- Use `freezed` for test fixtures where applicable

## What to Test

| Layer | What | How |
|-------|------|-----|
| Shared models | Entity validation, equality | Unit test |
| Data (repositories) | CRUD operations, edge cases | Unit test with mock data source |
| UI (view models) | State transitions, error handling | Unit test with mock repository |
| UI (widgets) | Rendering, interaction | Widget test |
| Full flows | Timer start → complete → save | Integration test |

## What NOT to Test

- Simple getters/setters with no logic
- Framework-provided behavior (GoRouter navigation, Riverpod internals)
- UI layout details that change frequently (pixel-level assertions)
