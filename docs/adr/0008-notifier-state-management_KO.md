<!-- translated from: docs/adr/0008-notifier-state-management.md @ commit da20b26 (2026-03-19) -->

# ADR-0008: 복잡한 상태 관리를 위한 Notifier 패턴

## 상태

승인됨

## 날짜

2026-03-19

## 맥락

Phase 2 (Presets)에서는 처음으로 복잡한 상호작용 UI 상태가 등장합니다:

- Preset form: form state, field validation, submission, error display
- Timer (Phase 3): countdown, pause/resume, background handling

Riverpod은 여러 상태 관리 패턴을 제공합니다. 명확한 규칙이 없으면, 첫 기능이 의도치 않게 선례가 됩니다. 상호작용 상태와 읽기 전용 reactive data에 어떤 패턴을 쓸지 결정해야 합니다.

## 결정

### 상호작용 상태에는 Notifier / AutoDisposeNotifier

사용자 액션에 따라 상태가 변경되는 화면에는 `Notifier`(또는 `AutoDisposeNotifier`)를 사용합니다: forms, timer controls, editing flows.

```dart
// 예시: Preset form
@riverpod
class PresetFormNotifier extends _$PresetFormNotifier {
  @override
  PresetFormState build() => PresetFormState.initial();

  void updateName(String name) { ... }
  Future<void> submit() async { ... }
}
```

### 읽기 전용 reactive data에는 StreamProvider

UI가 단지 시간에 따라 변하는 데이터를 보여주기만 하고, 해당 provider에서 직접 사용자 mutation을 처리하지 않는다면 `StreamProvider`를 사용합니다.

```dart
// 예시: Home의 Preset list
@riverpod
Stream<List<Preset>> presetList(Ref ref) {
  return ref.watch(presetRepositoryProvider).watchAllPresets();
}
```

### 일회성 async 작업에는 FutureProvider

한 번 로드되고 바뀌지 않거나, 변경 시 `ref.invalidate()` 정도로 충분한 데이터에는 `FutureProvider`를 사용합니다.

```dart
// 예시: App initialization
@riverpod
Future<void> appInit(Ref ref) async {
  await ref.watch(presetSeederProvider).seedDefaults();
}
```

## 검토한 대안

### StateNotifier (기각)

Riverpod 1.x의 레거시 API입니다. `Notifier`가 권장 대체안이며 타입 추론과 override 패턴이 더 단순합니다.

### AsyncNotifier (보류)

Notifier 자체에 async 초기화가 필요한 경우 유용합니다 (예: UI 렌더 전에 remote data 로딩). Form state는 `isSubmitting` 플래그를 둔 동기 `Notifier`가 더 단순합니다. 정말 필요한 경우에만 `AsyncNotifier`를 사용합니다.

### BLoC / Cubit (기각)

별도 의존성과 패턴을 추가해야 합니다. Riverpod의 `Notifier`는 기존 provider 기반 아키텍처와 더 잘 통합되면서도 동등한 기능을 더 적은 boilerplate로 제공합니다.

## 결과

- 모든 interactive state가 같은 패턴을 따르므로 onboarding이 쉬워짐
- StreamProvider + Notifier 조합으로 약 95%의 use case를 커버 가능
- Timer feature (Phase 3)는 countdown logic에 Notifier를 사용할 예정
- Form validation은 widget tree가 아니라 Notifier 안에 위치
