import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/timer/ui/timer_notifier.dart';
import 'package:taptime/features/timer/ui/widgets/progress_ring.dart';

/// 타이머 화면 — 카운트다운과 컨트롤을 표시한다.
///
/// presetId를 받아 해당 프리셋의 설정(시간, 이름, 아이콘)으로 타이머를 실행한다.
/// 프리셋 카드를 탭하면 즉시 카운트다운이 시작된다.
///
/// ConsumerStatefulWidget을 사용하는 이유:
/// WidgetsBindingObserver가 필요하여 앱 라이프사이클(백그라운드↔포그라운드)을
/// 감지하고, 포그라운드 복귀 시 타임스탬프로 남은 시간을 재계산한다.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({required this.presetId, super.key});

  final String presetId;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 백그라운드에서 돌아왔을 때 타이머 상태를 갱신한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(timerProvider(widget.presetId).notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider(widget.presetId));
    final color = ColorUtils.fromHex(timerState.presetColor);

    // 완료/에러 시 다이얼로그 표시 + 알림 효과
    ref.listen(timerProvider(widget.presetId), (prev, next) {
      if (prev?.status != TimerStatus.completed && next.status == TimerStatus.completed) {
        _playCompletionEffects();
        _showCompletionDialog(context, next);
      }
      if (prev?.error == null && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    // 스와이프로 자유롭게 이동 가능. 타이머는 ActiveTimer DB에 저장되어
    // 다시 프리셋을 탭하면 복구된다.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: timerState.status == TimerStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, timerState, color),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TimerState timerState, Color color) {
    final icon = AppConstants.presetIcons[timerState.presetIcon] ?? Icons.timer;
    final theme = Theme.of(context);

    // SizedBox.expand: Column이 화면 전체 너비를 차지하도록 하여
    // 자식 위젯들이 수평 중앙에 배치되게 한다.
    return SizedBox.expand(
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── 프리셋 정보 ──────────────────────────────────
          Icon(icon, size: 40, color: color),
          const SizedBox(height: AppSpacing.gap),
          Text(
            timerState.presetName,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),

          // 고정 간격으로 요소들을 하나의 그룹으로 묶는다.
          // Spacer 대신 SizedBox를 사용하여 화면 크기에 관계없이
          // 일관된 배치를 유지한다.
          const SizedBox(height: 32),

          // ── 프로그레스 링 + 시간 표시 ───────────────────
          ProgressRing(
            progress: timerState.isStopwatch ? 0 : timerState.progress,
            color: color,
            child: Text(
              TimeFormatter.mmss(
                timerState.isStopwatch ? timerState.elapsedSeconds : timerState.remainingSeconds,
              ),
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),

          const SizedBox(height: 48),

          // ── 컨트롤 버튼 ──────────────────────────────────
          _buildControls(context, timerState, color),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, TimerState timerState, Color color) {
    final notifier = ref.read(timerProvider(widget.presetId).notifier);

    switch (timerState.status) {
      case TimerStatus.running:
        return Column(
          children: [
            _ActionButton(
              icon: Icons.pause_rounded,
              label: '일시정지',
              color: color,
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.pause();
              },
            ),
            const SizedBox(height: AppSpacing.padding),
            _StopTextButton(onPressed: () => _showStopConfirmation(context)),
          ],
        );
      case TimerStatus.paused:
        return Column(
          children: [
            _ActionButton(
              icon: Icons.play_arrow_rounded,
              label: '계속하기',
              color: color,
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.resume();
              },
            ),
            const SizedBox(height: AppSpacing.padding),
            _StopTextButton(onPressed: () => _showStopConfirmation(context)),
          ],
        );
      case TimerStatus.completed || TimerStatus.stopped:
        return _ActionButton(
          icon: Icons.check_rounded,
          label: '완료',
          color: color,
          onPressed: () => context.go(AppRoutes.home),
        );
      case TimerStatus.loading:
        return const SizedBox.shrink();
    }
  }

  // ── 알림 효과 ──────────────────────────────────────────────

  /// 타이머 완료 시 사운드 + 진동을 재생한다.
  /// UserSettings의 soundEnabled/vibrationEnabled을 존중한다.
  void _playCompletionEffects() {
    final settings = ref.read(userSettingsStreamProvider).valueOrNull;
    if (settings?.soundEnabled ?? true) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (settings?.vibrationEnabled ?? true) {
      HapticFeedback.heavyImpact();
    }
  }

  // ── 다이얼로그 ──────────────────────────────────────────────

  void _showCompletionDialog(BuildContext context, TimerState timerState) {
    final minutes = timerState.totalSeconds ~/ 60;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('완료!'),
        content: Text('${timerState.presetName} $minutes분을 완료했습니다.'),
        actions: [
          // 짧은 휴식
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.breakTimerPath(AppConstants.shortBreakSeconds));
            },
            child: const Text('짧은 휴식 5분'),
          ),
          // 긴 휴식
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.breakTimerPath(AppConstants.longBreakSeconds));
            },
            child: const Text('긴 휴식 15분'),
          ),
          // 완료
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.home);
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation(BuildContext context) {
    final timerState = ref.read(timerProvider(widget.presetId));
    final elapsed = timerState.isStopwatch ? timerState.elapsedSeconds : timerState.totalSeconds - timerState.remainingSeconds;
    final elapsedMin = elapsed ~/ 60;
    final elapsedSec = elapsed % 60;

    final elapsedText = elapsedMin > 0 ? '$elapsedMin분 $elapsedSec초' : '$elapsedSec초';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('타이머 중지'),
        content: Text('$elapsedText가 기록됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(timerProvider(widget.presetId).notifier).stop();
              if (success && context.mounted) {
                context.go(AppRoutes.home);
              }
            },
            child: Text(
              '중지',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공용 위젯 ──────────────────────────────────────────────────

/// 타이머 주요 액션 버튼 (재생/일시정지/완료).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
      ),
    );
  }
}

/// 타이머 중지 텍스트 버튼.
class _StopTextButton extends StatelessWidget {
  const _StopTextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.stop_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      label: Text(
        '중지',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
