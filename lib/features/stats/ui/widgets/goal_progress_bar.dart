import 'package:flutter/material.dart';

import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/shared/models/preset.dart';

/// 목표 달성률 프로그레스 바.
///
/// 프리셋의 목표 시간 대비 실제 달성 시간을 표시한다.
/// 일간/주간/월간 통계 화면에서 공통으로 사용한다.
class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({
    required this.preset,
    required this.actualMinutes,
    required this.goalMinutes,
    super.key,
  });

  final Preset preset;

  /// 실제 달성 시간 (분)
  final int actualMinutes;

  /// 목표 시간 (분)
  final int goalMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ColorUtils.fromHex(preset.color);
    final progress = (actualMinutes / goalMinutes).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.grid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(preset.name, style: theme.textTheme.bodyMedium),
              Text(
                '${TimeFormatter.humanize(actualMinutes)} / ${TimeFormatter.humanize(goalMinutes)} ($percentage%)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
