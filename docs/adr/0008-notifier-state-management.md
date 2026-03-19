# ADR-0008: Notifier Pattern for Complex State Management

## Status

Accepted

## Date

2026-03-19

## Context

Phase 2 (Presets) introduces the first interactive UI with complex state:
- Preset form: form state, field validation, submission, error display
- Timer (Phase 3): countdown, pause/resume, background handling

Riverpod offers multiple state management patterns. Without a convention,
the first feature sets an unintentional precedent. We need to decide which
pattern to use for interactive state vs. read-only reactive data.

## Decision

### Notifier / AutoDisposeNotifier for interactive state

Use `Notifier` (or `AutoDisposeNotifier`) for screens that mutate state
in response to user actions: forms, timer controls, editing flows.

```dart
// Example: Preset form
@riverpod
class PresetFormNotifier extends _$PresetFormNotifier {
  @override
  PresetFormState build() => PresetFormState.initial();

  void updateName(String name) { ... }
  Future<void> submit() async { ... }
}
```

### StreamProvider for read-only reactive data

Use `StreamProvider` when the UI simply displays data that changes
over time, with no user-triggered mutations on that provider.

```dart
// Example: Preset list on home screen
@riverpod
Stream<List<Preset>> presetList(Ref ref) {
  return ref.watch(presetRepositoryProvider).watchAllPresets();
}
```

### FutureProvider for one-shot async operations

Use `FutureProvider` for data that loads once and doesn't change
(or changes rarely enough to use `ref.invalidate()`).

```dart
// Example: App initialization
@riverpod
Future<void> appInit(Ref ref) async {
  await ref.watch(presetSeederProvider).seedDefaults();
}
```

## Alternatives Considered

### StateNotifier (rejected)

Riverpod 1.x legacy API. `Notifier` is the recommended replacement
with better type inference and simpler override patterns.

### AsyncNotifier (deferred)

Useful when the Notifier itself needs async initialization (e.g.,
loading remote data before the UI renders). For form state, synchronous
`Notifier` with an `isSubmitting` flag is simpler. Use `AsyncNotifier`
when genuinely needed.

### BLoC / Cubit (rejected)

Adds a separate dependency and pattern. Riverpod's `Notifier` provides
equivalent functionality with less boilerplate and better integration
with the existing provider-based architecture.

## Consequences

- All interactive state follows the same pattern — easier onboarding
- StreamProvider + Notifier covers 95% of use cases
- Timer feature (Phase 3) will use Notifier for countdown logic
- Form validation lives in the Notifier, not the widget tree
