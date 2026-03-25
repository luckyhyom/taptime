import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:uuid/uuid.dart';

// ── 폼 상태 ──────────────────────────────────────────────────

/// 프리셋 생성/수정 폼의 전체 상태.
///
/// 불변 객체로 정의하여 Notifier가 상태 변경 시 항상 새 객체를 만든다.
/// Riverpod은 이전 상태와 새 상태를 비교하여 UI 리빌드 여부를 결정한다.
class PresetFormState {
  const PresetFormState({
    this.name = '',
    this.durationMin = AppConstants.timerDefaultMinutes,
    this.icon = 'menu_book',
    this.color = '#4A90D9',
    this.dailyGoalMin = 0,
    this.locationTriggerId,
    this.locationTriggerName,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  final String name;
  final int durationMin;
  final String icon;
  final String color;

  /// 일일 목표 시간 (분). 0이면 목표 없음.
  final int dailyGoalMin;

  /// 연결된 위치 트리거 ID. null이면 위치 연결 없음.
  final String? locationTriggerId;

  /// 연결된 위치 트리거의 장소 이름 (UI 표시용).
  final String? locationTriggerName;

  /// 수정 모드에서 기존 프리셋을 불러오는 중인지 여부.
  final bool isLoading;

  /// 저장/삭제 요청이 진행 중인지 여부.
  final bool isSubmitting;

  /// 저장/삭제 실패 시 오류 메시지.
  final String? error;

  bool get isValid => name.trim().isNotEmpty;

  PresetFormState copyWith({
    String? name,
    int? durationMin,
    String? icon,
    String? color,
    int? dailyGoalMin,
    String? locationTriggerId,
    String? locationTriggerName,
    bool clearLocation = false,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return PresetFormState(
      name: name ?? this.name,
      durationMin: durationMin ?? this.durationMin,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
      locationTriggerId: clearLocation ? null : (locationTriggerId ?? this.locationTriggerId),
      locationTriggerName: clearLocation ? null : (locationTriggerName ?? this.locationTriggerName),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── 폼 Notifier ───────────────────────────────────────────────

/// 프리셋 폼 상태를 관리하는 Notifier.
///
/// ADR-0008: 인터랙티브 상태(폼)에는 Notifier를 사용한다.
/// AutoDispose: 폼 화면을 벗어나면 상태가 자동 해제된다.
/// Family: presetId(String?)를 인자로 받아 생성/수정 모드를 구분한다.
///   - null → 새 프리셋 생성 모드
///   - String → 기존 프리셋 수정 모드
class PresetFormNotifier extends AutoDisposeFamilyNotifier<PresetFormState, String?> {
  // build()에서 받은 presetId를 다른 메서드에서도 쓸 수 있도록 저장한다.
  String? _presetId;

  @override
  PresetFormState build(String? presetId) {
    _presetId = presetId;

    // 수정 모드: 기존 프리셋 데이터를 비동기로 불러온다.
    // build()는 동기 메서드이므로 microtask로 비동기 작업을 지연 실행한다.
    if (presetId != null) {
      Future.microtask(() => _loadPreset(presetId));
      return const PresetFormState(isLoading: true);
    }

    return const PresetFormState();
  }

  Future<void> _loadPreset(String presetId) async {
    final repo = ref.read(presetRepositoryProvider);
    final preset = await repo.getPresetById(presetId);

    if (preset == null) {
      state = state.copyWith(isLoading: false, error: '프리셋을 찾을 수 없습니다.');
      return;
    }

    // 연결된 위치 트리거가 있으면 장소 이름도 불러온다.
    String? triggerName;
    if (preset.locationTriggerId != null) {
      final triggerRepo = ref.read(locationTriggerRepositoryProvider);
      final trigger = await triggerRepo.getTriggerById(preset.locationTriggerId!);
      triggerName = trigger?.placeName;
    }

    state = PresetFormState(
      name: preset.name,
      durationMin: preset.durationMin,
      icon: preset.icon,
      color: preset.color,
      dailyGoalMin: preset.dailyGoalMin,
      locationTriggerId: preset.locationTriggerId,
      locationTriggerName: triggerName,
    );
  }

  // ── 필드 업데이트 ──────────────────────────────────────────

  void setName(String value) => state = state.copyWith(name: value, clearError: true);

  void setDuration(int value) =>
      state = state.copyWith(durationMin: value.clamp(AppConstants.timerMinMinutes, AppConstants.timerMaxMinutes));

  void setIcon(String value) => state = state.copyWith(icon: value);

  void setColor(String value) => state = state.copyWith(color: value);

  void setDailyGoal(int value) => state = state.copyWith(dailyGoalMin: value.clamp(0, 480));

  /// 위치 트리거를 연결한다.
  /// 지도 피커에서 반환된 triggerId로 트리거 정보를 조회하여 상태에 반영한다.
  Future<void> setLocationTrigger(String triggerId) async {
    final triggerRepo = ref.read(locationTriggerRepositoryProvider);
    final trigger = await triggerRepo.getTriggerById(triggerId);
    if (trigger != null) {
      state = state.copyWith(locationTriggerId: triggerId, locationTriggerName: trigger.placeName);
    }
  }

  /// 위치 트리거 연결을 해제한다.
  void clearLocationTrigger() => state = state.copyWith(clearLocation: true);

  // ── 저장 / 삭제 ───────────────────────────────────────────

  /// 폼을 저장한다. 성공하면 true, 실패하면 false를 반환한다.
  Future<bool> save() async {
    if (!state.isValid) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(presetRepositoryProvider);
      final now = DateTime.now();

      if (_presetId != null) {
        // 수정 모드: 기존 프리셋의 필드를 갱신한다.
        final existing = await repo.getPresetById(_presetId!);
        if (existing == null) throw Exception('프리셋을 찾을 수 없습니다.');

        // 위치 트리거가 해제된 경우 clearLocationTrigger()로 FK를 null로 설정한다.
        var updated = existing.copyWith(
          name: state.name.trim(),
          durationMin: state.durationMin,
          icon: state.icon,
          color: state.color,
          dailyGoalMin: state.dailyGoalMin,
          locationTriggerId: state.locationTriggerId,
          updatedAt: now,
        );
        if (state.locationTriggerId == null && existing.locationTriggerId != null) {
          updated = updated.clearLocationTrigger();
        }
        await repo.updatePreset(updated);
      } else {
        // 생성 모드: sortOrder를 기존 최댓값 + 1로 설정하여 목록 마지막에 추가.
        final allPresets = await repo.getAllPresets();
        final maxOrder =
            allPresets.isEmpty ? 0 : allPresets.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b);

        await repo.createPreset(
          Preset(
            id: const Uuid().v4(),
            name: state.name.trim(),
            durationMin: state.durationMin,
            icon: state.icon,
            color: state.color,
            dailyGoalMin: state.dailyGoalMin,
            locationTriggerId: state.locationTriggerId,
            sortOrder: maxOrder + 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      return true;
    } on Exception catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// 현재 프리셋을 보관한다. 성공하면 true, 실패하면 false를 반환한다.
  Future<bool> archive() async {
    if (_presetId == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await ref.read(presetRepositoryProvider).archivePreset(_presetId!);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// 현재 프리셋을 삭제한다. 성공하면 true, 실패하면 false를 반환한다.
  Future<bool> delete() async {
    if (_presetId == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await ref.read(presetRepositoryProvider).deletePreset(_presetId!);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

// ── 프로바이더 ────────────────────────────────────────────────

/// 프리셋 폼 프로바이더.
///
/// 사용 예:
///   - 생성: `ref.watch(presetFormProvider(null))`
///   - 수정: `ref.watch(presetFormProvider('preset-uuid'))`
final presetFormProvider =
    NotifierProvider.autoDispose.family<PresetFormNotifier, PresetFormState, String?>(
  PresetFormNotifier.new,
);
