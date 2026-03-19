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

## Mock Convention

- Mock file: `test/mocks/mock_repositories.dart`
- One `Mock*` class per repository interface, using `mocktail`
- Example: `class MockPresetRepository extends Mock implements PresetRepository {}`

## Model Testing

- Test constructor assertions via `expect(() => Model(...), throwsA(isA<AssertionError>()))`
- Test `toMap()` / `fromMap()` round-trip: `Model.fromMap(model.toMap()) == model`
- Test `fromMap()` with corrupted enum values to verify safe fallback

## Repository Testing

- Use in-memory DB: `AppDatabase(NativeDatabase.memory())`
- Test CRUD operations, edge cases (empty results, duplicates)
- Test safe enum parsing: insert row with invalid enum string, verify fallback
- Test cascade delete behavior and document it

## What NOT to Test

- Simple getters/setters with no logic
- Framework-provided behavior (GoRouter navigation, Riverpod internals)
- UI layout details that change frequently (pixel-level assertions)
