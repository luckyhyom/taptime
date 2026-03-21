import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/active_timer.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';
import 'package:taptime/shared/repositories/active_timer_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:uuid/uuid.dart';

// ── 타이머 상태 열거형 ──────────────────────────────────────────

/// 타이머 화면의 상태 단계.
///
/// loading → running ↔ paused → completed / stopped
enum TimerStatus { loading, running, paused, completed, stopped }

// ── 타이머 상태 ──────────────────────────────────────────────────

/// 타이머 화면의 전체 상태.
///
/// UI가 필요한 정보만 포함한다.
/// 타임스탬프 기반 계산에 필요한 내부 값(_startedAt 등)은
/// Notifier의 private 필드로 관리한다.
class TimerState {
  const TimerState({
    this.presetName = '',
    this.presetIcon = 'timer',
    this.presetColor = '#4A90D9',
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.status = TimerStatus.loading,
    this.error,
  });

  final String presetName;
  final String presetIcon;
  final String presetColor;

  /// 남은 시간 (초). 매 틱마다 타임스탬프로 재계산된다.
  final int remainingSeconds;

  /// 전체 타이머 시간 (초). 프로그레스 링의 분모.
  final int totalSeconds;

  final TimerStatus status;
  final String? error;

  /// 진행률 (0.0 ~ 1.0). 프로그레스 링에 사용.
  double get progress => totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0;

  TimerState copyWith({
    String? presetName,
    String? presetIcon,
    String? presetColor,
    int? remainingSeconds,
    int? totalSeconds,
    TimerStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return TimerState(
      presetName: presetName ?? this.presetName,
      presetIcon: presetIcon ?? this.presetIcon,
      presetColor: presetColor ?? this.presetColor,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── 타이머 Notifier ─────────────────────────────────────────────

/// 카운트다운 타이머 로직을 관리하는 Notifier.
///
/// ADR-0008: 인터랙티브 상태(타이머 컨트롤)에는 Notifier를 사용한다.
/// AutoDispose: 타이머 화면을 벗어나면 상태가 자동 해제된다.
/// Family(String): presetId를 인자로 받아 해당 프리셋의 타이머를 실행한다.
///
/// 남은 시간은 매 틱마다 타임스탬프 기반으로 재계산된다.
/// Timer.periodic은 UI 갱신 트리거일 뿐, 실제 시간은 startedAt과
/// pausedDurationSeconds로부터 계산하여 정확도를 보장한다.
class TimerNotifier extends AutoDisposeFamilyNotifier<TimerState, String> {
  Timer? _ticker;
  DateTime? _startedAt;
  DateTime? _pausedAt;
  int _pausedDurationSeconds = 0;
  Preset? _preset;

  @override
  TimerState build(String presetId) {
    ref.onDispose(_onDispose);
    Future.microtask(() => _initialize(presetId));
    return const TimerState();
  }

  // ── 초기화 ──────────────────────────────────────────────────

  /// 타이머를 초기화한다.
  ///
  /// 1. DB에서 ActiveTimer 확인 — 있으면 복구, 없으면 새로 시작
  /// 2. 기존 ActiveTimer가 다른 프리셋이면 stopped로 저장 후 새로 시작
  Future<void> _initialize(String presetId) async {
    final activeTimerRepo = ref.read(activeTimerRepositoryProvider);
    final presetRepo = ref.read(presetRepositoryProvider);

    final activeTimer = await activeTimerRepo.getActiveTimer();

    if (activeTimer != null && activeTimer.presetId == presetId) {
      await _restoreTimer(activeTimer, presetRepo);
    } else {
      // 다른 프리셋의 ActiveTimer가 있으면 stopped로 저장
      if (activeTimer != null) {
        await _saveStoppedSession(activeTimer, presetRepo);
        await activeTimerRepo.deleteActiveTimer();
      }
      await _startNewTimer(presetId, presetRepo, activeTimerRepo);
    }
  }

  /// 크래시/화면이탈 후 ActiveTimer에서 타이머를 복구한다.
  Future<void> _restoreTimer(ActiveTimer activeTimer, PresetRepository presetRepo) async {
    final preset = await presetRepo.getPresetById(activeTimer.presetId);
    if (preset == null) {
      state = state.copyWith(status: TimerStatus.stopped, error: '프리셋을 찾을 수 없습니다.');
      return;
    }

    _preset = preset;
    _startedAt = activeTimer.startedAt;
    _pausedAt = activeTimer.pausedAt;
    _pausedDurationSeconds = activeTimer.pausedDurationSeconds;

    final totalSeconds = preset.durationMin * 60;
    final remaining = _calculateRemaining(totalSeconds);

    // 앱이 꺼져있는 동안 타이머가 이미 만료됨
    if (remaining <= 0) {
      state = TimerState(
        presetName: preset.name,
        presetIcon: preset.icon,
        presetColor: preset.color,
        totalSeconds: totalSeconds,
        status: TimerStatus.running,
      );
      await _completeTimer();
      return;
    }

    state = TimerState(
      presetName: preset.name,
      presetIcon: preset.icon,
      presetColor: preset.color,
      remainingSeconds: remaining,
      totalSeconds: totalSeconds,
      status: activeTimer.isPaused ? TimerStatus.paused : TimerStatus.running,
    );

    if (!activeTimer.isPaused) {
      _startTicking();
    }
  }

  /// 새 타이머를 시작한다.
  Future<void> _startNewTimer(
    String presetId,
    PresetRepository presetRepo,
    ActiveTimerRepository activeTimerRepo,
  ) async {
    final preset = await presetRepo.getPresetById(presetId);
    if (preset == null) {
      state = state.copyWith(status: TimerStatus.stopped, error: '프리셋을 찾을 수 없습니다.');
      return;
    }

    _preset = preset;
    _startedAt = DateTime.now();
    _pausedAt = null;
    _pausedDurationSeconds = 0;

    final totalSeconds = preset.durationMin * 60;

    await activeTimerRepo.saveActiveTimer(
      ActiveTimer(
        id: ActiveTimer.singletonId,
        presetId: presetId,
        startedAt: _startedAt!,
        isPaused: false,
        pausedDurationSeconds: 0,
        remainingSeconds: totalSeconds,
        createdAt: DateTime.now(),
      ),
    );

    state = TimerState(
      presetName: preset.name,
      presetIcon: preset.icon,
      presetColor: preset.color,
      remainingSeconds: totalSeconds,
      totalSeconds: totalSeconds,
      status: TimerStatus.running,
    );

    _startTicking();
  }

  // ── 타이머 컨트롤 ──────────────────────────────────────────

  void pause() {
    if (state.status != TimerStatus.running) return;

    _ticker?.cancel();
    _pausedAt = DateTime.now();

    final remaining = _calculateRemaining(state.totalSeconds);
    state = state.copyWith(status: TimerStatus.paused, remainingSeconds: remaining);

    _persistActiveTimer();
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;

    // 현재 일시정지 시간을 누적에 더한다
    _pausedDurationSeconds += DateTime.now().difference(_pausedAt!).inSeconds;
    _pausedAt = null;

    state = state.copyWith(status: TimerStatus.running);
    _startTicking();
    _persistActiveTimer();
  }

  /// 타이머를 수동으로 중지하고 세션을 저장한다.
  /// 성공하면 true를 반환한다.
  Future<bool> stop() async {
    _ticker?.cancel();

    final now = DateTime.now();
    var totalPaused = _pausedDurationSeconds;
    if (_pausedAt != null) {
      totalPaused += now.difference(_pausedAt!).inSeconds;
    }
    final durationSeconds = now.difference(_startedAt!).inSeconds - totalPaused;

    try {
      await ref.read(sessionRepositoryProvider).createSession(
        Session(
          id: const Uuid().v4(),
          presetId: _preset!.id,
          startedAt: _startedAt!,
          endedAt: now,
          durationSeconds: durationSeconds.clamp(0, state.totalSeconds),
          status: SessionStatus.stopped,
          createdAt: now,
        ),
      );
      await ref.read(activeTimerRepositoryProvider).deleteActiveTimer();

      state = state.copyWith(status: TimerStatus.stopped);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 앱이 백그라운드에서 포그라운드로 돌아왔을 때 호출한다.
  ///
  /// Timer.periodic은 백그라운드에서 정확히 동작하지 않으므로,
  /// 포그라운드 복귀 시 타임스탬프를 기반으로 남은 시간을 재계산한다.
  void onAppResumed() {
    if (state.status != TimerStatus.running) return;

    final remaining = _calculateRemaining(state.totalSeconds);
    if (remaining <= 0) {
      _ticker?.cancel();
      _completeTimer();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
      _startTicking();
    }
  }

  // ── 내부 로직 ──────────────────────────────────────────────

  /// 타임스탬프 기반으로 남은 시간을 계산한다.
  ///
  /// 실제 경과 시간 = (기준 시각 - 시작 시각) - 누적 일시정지 시간
  /// 기준 시각: 실행 중이면 현재, 일시정지 중이면 일시정지 시각
  int _calculateRemaining(int totalSeconds) {
    if (_startedAt == null) return totalSeconds;

    final referenceTime = _pausedAt ?? DateTime.now();
    final elapsed = referenceTime.difference(_startedAt!).inSeconds - _pausedDurationSeconds;
    return (totalSeconds - elapsed).clamp(0, totalSeconds);
  }

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.status != TimerStatus.running) {
      _ticker?.cancel();
      return;
    }

    final remaining = _calculateRemaining(state.totalSeconds);
    if (remaining <= 0) {
      _ticker?.cancel();
      _completeTimer();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  /// 타이머 완료 처리: 세션 저장 + ActiveTimer 삭제.
  Future<void> _completeTimer() async {
    final now = DateTime.now();

    try {
      await ref.read(sessionRepositoryProvider).createSession(
        Session(
          id: const Uuid().v4(),
          presetId: _preset!.id,
          startedAt: _startedAt!,
          endedAt: now,
          durationSeconds: state.totalSeconds,
          status: SessionStatus.completed,
          createdAt: now,
        ),
      );
      await ref.read(activeTimerRepositoryProvider).deleteActiveTimer();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return;
    }

    state = state.copyWith(status: TimerStatus.completed, remainingSeconds: 0);
  }

  /// 다른 프리셋의 중단된 ActiveTimer를 세션으로 저장한다.
  Future<void> _saveStoppedSession(ActiveTimer activeTimer, PresetRepository presetRepo) async {
    final preset = await presetRepo.getPresetById(activeTimer.presetId);
    if (preset == null) return;

    final now = DateTime.now();
    final totalSeconds = preset.durationMin * 60;
    var totalPaused = activeTimer.pausedDurationSeconds;
    if (activeTimer.pausedAt != null) {
      totalPaused += now.difference(activeTimer.pausedAt!).inSeconds;
    }
    final durationSeconds = now.difference(activeTimer.startedAt).inSeconds - totalPaused;

    await ref.read(sessionRepositoryProvider).createSession(
      Session(
        id: const Uuid().v4(),
        presetId: activeTimer.presetId,
        startedAt: activeTimer.startedAt,
        endedAt: now,
        durationSeconds: durationSeconds.clamp(0, totalSeconds),
        status: SessionStatus.stopped,
        createdAt: now,
      ),
    );
  }

  /// ActiveTimer 상태를 DB에 저장한다 (크래시 복구용).
  Future<void> _persistActiveTimer() async {
    if (_startedAt == null || _preset == null) return;

    await ref.read(activeTimerRepositoryProvider).saveActiveTimer(
      ActiveTimer(
        id: ActiveTimer.singletonId,
        presetId: _preset!.id,
        startedAt: _startedAt!,
        isPaused: _pausedAt != null,
        pausedAt: _pausedAt,
        pausedDurationSeconds: _pausedDurationSeconds,
        remainingSeconds: _calculateRemaining(state.totalSeconds),
        createdAt: _startedAt!,
      ),
    );
  }

  void _onDispose() {
    _ticker?.cancel();
    // 실행/일시정지 중이면 크래시 복구용으로 저장 (fire-and-forget)
    if (state.status == TimerStatus.running || state.status == TimerStatus.paused) {
      _persistActiveTimer();
    }
  }
}

// ── 프로바이더 ────────────────────────────────────────────────

/// 타이머 Notifier 프로바이더.
///
/// 사용 예: `ref.watch(timerProvider(presetId))`
/// 타이머 화면에서 presetId와 함께 사용한다.
final timerProvider = NotifierProvider.autoDispose.family<TimerNotifier, TimerState, String>(
  TimerNotifier.new,
);
