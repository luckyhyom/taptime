import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/timer/ui/break_timer_notifier.dart';
import 'package:taptime/features/timer/ui/widgets/progress_ring.dart';

/// 브레이크 타이머 화면.
///
/// 포커스 세션 완료 후 짧은 휴식(5분) 또는 긴 휴식(15분)을 제공한다.
/// 세션 저장 없이 순수 카운트다운만 한다.
class BreakTimerScreen extends ConsumerWidget {
  const BreakTimerScreen({required this.durationSeconds, super.key});

  final int durationSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakState = ref.watch(breakTimerProvider(durationSeconds));
    final theme = Theme.of(context);
    const color = Colors.teal;

    // 완료 시 효과음 + 다이얼로그
    ref.listen(breakTimerProvider(durationSeconds), (prev, next) {
      if (prev?.status != BreakTimerStatus.completed && next.status == BreakTimerStatus.completed) {
        _playCompletionEffects(ref);
        _showCompletionDialog(context);
      }
    });

    final label = durationSeconds >= 600 ? '긴 휴식' : '짧은 휴식';

    // context.go()로 진입하므로 pop할 곳이 없다.
    // 모든 종료 경로에서 go(home)으로 이동한다.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('건너뛰기'),
                  ),
                ),
              ),

              const Spacer(),

              // 아이콘 + 라벨
              const Icon(Icons.self_improvement, size: 40, color: color),
              const SizedBox(height: AppSpacing.gap),
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),

              const Spacer(flex: 2),

              // 프로그레스 링 + 시간
              ProgressRing(
                progress: breakState.progress,
                color: color,
                child: Text(
                  TimeFormatter.mmss(breakState.remainingSeconds),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // 컨트롤 버튼
              _buildControls(context, ref, breakState),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, BreakTimerState breakState) {
    final notifier = ref.read(breakTimerProvider(durationSeconds).notifier);

    switch (breakState.status) {
      case BreakTimerStatus.running:
        return FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.pause();
          },
          icon: const Icon(Icons.pause_rounded, size: 28),
          label: const Text('일시정지', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        );
      case BreakTimerStatus.paused:
        return FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.resume();
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: const Text('계속하기', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        );
      case BreakTimerStatus.completed:
        return FilledButton.icon(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.check_rounded, size: 28),
          label: const Text('완료', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        );
    }
  }

  void _playCompletionEffects(WidgetRef ref) {
    final settings = ref.read(userSettingsStreamProvider).valueOrNull;
    if (settings?.soundEnabled ?? true) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (settings?.vibrationEnabled ?? true) {
      HapticFeedback.heavyImpact();
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('휴식 끝!'),
        content: const Text('다시 집중할 준비가 되셨나요?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.home);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
