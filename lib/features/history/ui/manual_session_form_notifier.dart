import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/features/history/ui/history_providers.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';
import 'package:uuid/uuid.dart';

// ── 폼 상태 ──────────────────────────────────────────────────

/// 수동 세션 입력 폼의 전체 상태.
class ManualSessionFormState {
  const ManualSessionFormState({
    this.selectedPreset,
    this.date,
    this.startTime,
    this.endTime,
    this.memo = '',
    this.isSubmitting = false,
    this.error,
  });

  /// 선택된 프리셋. null이면 아직 선택하지 않은 상태.
  final Preset? selectedPreset;

  /// 세션 날짜. null이면 아직 선택하지 않은 상태.
  final DateTime? date;

  /// 시작 시각. null이면 아직 선택하지 않은 상태.
  final TimeOfDay? startTime;

  /// 종료 시각. null이면 아직 선택하지 않은 상태.
  final TimeOfDay? endTime;

  /// 메모 (선택)
  final String memo;

  final bool isSubmitting;
  final String? error;

  /// 종료 시각이 시작 시각보다 이르면 자정을 넘긴 것으로 간주한다.
  bool get _crossesMidnight {
    if (startTime == null || endTime == null) return false;
    return _toMinutes(endTime!) <= _toMinutes(startTime!);
  }

  /// 계산된 소요 시간 (초). 유효하지 않으면 null.
  int? get durationSeconds {
    if (startTime == null || endTime == null) return null;
    final startMin = _toMinutes(startTime!);
    final endMin = _toMinutes(endTime!);
    final diff = _crossesMidnight ? (24 * 60 - startMin + endMin) : (endMin - startMin);
    return diff > 0 ? diff * 60 : null;
  }

  /// 모든 필수 필드가 채워졌고, 소요 시간이 0보다 큰지 확인.
  bool get isValid => selectedPreset != null && date != null && startTime != null && endTime != null && (durationSeconds ?? 0) > 0;

  ManualSessionFormState copyWith({
    Preset? selectedPreset,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? memo,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return ManualSessionFormState(
      selectedPreset: selectedPreset ?? this.selectedPreset,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      memo: memo ?? this.memo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}

// ── 폼 Notifier ───────────────────────────────────────────────

/// 수동 세션 입력 폼 상태를 관리하는 Notifier.
///
/// History 화면의 selectedDateProvider 값을 초기 날짜로 사용한다.
class ManualSessionFormNotifier extends AutoDisposeNotifier<ManualSessionFormState> {
  @override
  ManualSessionFormState build() {
    // History 화면에서 선택 중인 날짜를 기본값으로 사용한다.
    // 이 시점에서 한 번만 읽고, 이후 날짜 변경은 setDate()로 처리한다.
    final selectedDate = ref.read(selectedDateProvider);
    return ManualSessionFormState(date: selectedDate);
  }

  // ── 필드 업데이트 ──────────────────────────────────────────

  void setPreset(Preset preset) => state = state.copyWith(selectedPreset: preset, clearError: true);

  void setDate(DateTime date) => state = state.copyWith(date: date, clearError: true);

  void setStartTime(TimeOfDay time) => state = state.copyWith(startTime: time, clearError: true);

  void setEndTime(TimeOfDay time) => state = state.copyWith(endTime: time, clearError: true);

  void setMemo(String value) => state = state.copyWith(memo: value);

  // ── 저장 ───────────────────────────────────────────────────

  /// 세션을 저장한다. 성공하면 true, 실패하면 false.
  Future<bool> save() async {
    if (!state.isValid) return false;

    // 미래 시간 검증
    final now = DateTime.now();
    final endDateTime = _buildEndDateTime();
    if (endDateTime.isAfter(now)) {
      state = state.copyWith(error: '미래 시간에는 세션을 기록할 수 없습니다.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(sessionRepositoryProvider);
      final startDateTime = _buildStartDateTime();

      await repo.createSession(
        Session(
          id: const Uuid().v4(),
          presetId: state.selectedPreset!.id,
          startedAt: startDateTime,
          endedAt: endDateTime,
          durationSeconds: state.durationSeconds!,
          status: SessionStatus.completed,
          memo: state.memo.trim().isEmpty ? null : state.memo.trim().substring(0, state.memo.trim().length.clamp(0, AppConstants.sessionMemoMaxLength)),
          createdAt: now,
        ),
      );

      return true;
    } on Exception catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  // ── 헬퍼 ───────────────────────────────────────────────────

  DateTime _buildStartDateTime() {
    final d = state.date!;
    final t = state.startTime!;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  DateTime _buildEndDateTime() {
    final d = state.date!;
    final t = state.endTime!;
    final base = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    // 자정 교차: 종료 시각이 시작 시각 이전이면 다음 날로 간주
    if (state._crossesMidnight) {
      return base.add(const Duration(days: 1));
    }
    return base;
  }
}

// ── 프로바이더 ────────────────────────────────────────────────

/// 수동 세션 입력 폼 프로바이더.
final manualSessionFormProvider = NotifierProvider.autoDispose<ManualSessionFormNotifier, ManualSessionFormState>(
  ManualSessionFormNotifier.new,
);
