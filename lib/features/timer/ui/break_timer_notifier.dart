import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── 브레이크 타이머 상태 ──────────────────────────────────────

/// 브레이크 타이머 상태.
enum BreakTimerStatus { running, paused, completed }

/// 브레이크 타이머의 전체 상태.
class BreakTimerState {
  const BreakTimerState({
    required this.totalSeconds,
    this.remainingSeconds = 0,
    this.status = BreakTimerStatus.running,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final BreakTimerStatus status;

  double get progress => totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0;

  BreakTimerState copyWith({
    int? remainingSeconds,
    BreakTimerStatus? status,
  }) {
    return BreakTimerState(
      totalSeconds: totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}

// ── 프로바이더 ──────────────────────────────────────────────

/// 브레이크 타이머 프로바이더.
///
/// family 인자는 브레이크 시간(초). DB 저장/복구 없이 순수 카운트다운만 한다.
final breakTimerProvider =
    AutoDisposeNotifierProviderFamily<BreakTimerNotifier, BreakTimerState, int>(
  BreakTimerNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────

/// 브레이크 타이머 Notifier.
///
/// 포커스 타이머와 달리:
/// - DB에 세션을 저장하지 않는다 (유틸리티 기능)
/// - ActiveTimer 복구 로직이 없다 (앱 종료 시 소멸)
/// - 사운드/진동은 BreakTimerScreen에서 직접 처리한다
class BreakTimerNotifier extends AutoDisposeFamilyNotifier<BreakTimerState, int> {
  Timer? _ticker;

  @override
  BreakTimerState build(int arg) {
    ref.onDispose(() => _ticker?.cancel());
    // 바로 시작
    _startTicker(arg);
    return BreakTimerState(totalSeconds: arg, remainingSeconds: arg);
  }

  void _startTicker(int remaining) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _ticker?.cancel();
        state = state.copyWith(remainingSeconds: 0, status: BreakTimerStatus.completed);
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  /// 일시정지.
  void pause() {
    if (state.status != BreakTimerStatus.running) return;
    _ticker?.cancel();
    state = state.copyWith(status: BreakTimerStatus.paused);
  }

  /// 재개.
  void resume() {
    if (state.status != BreakTimerStatus.paused) return;
    state = state.copyWith(status: BreakTimerStatus.running);
    _startTicker(state.remainingSeconds);
  }
}
