import 'package:flutter/material.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/shared/models/preset.dart';

/// 홈 화면 그리드에 표시되는 프리셋 카드.
///
/// 아이콘, 이름, 시간(분), 일일 진행률을 하나의 카드에 표시한다.
/// 탭하면 타이머 화면으로, 길게 누르면 수정 화면으로 이동한다.
///
/// todayMinutes는 오늘 이 프리셋으로 기록한 누적 시간이다.
/// Phase 3(타이머)에서 실제 세션 데이터가 연결되기 전까지는 0으로 표시된다.
class PresetCard extends StatelessWidget {
  const PresetCard({
    required this.preset,
    this.todayMinutes = 0,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Preset preset;

  /// 오늘 이 프리셋으로 기록한 시간 (분 단위)
  final int todayMinutes;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final presetColor = ColorUtils.fromHex(preset.color);
    // DB에 저장된 아이콘 키를 실제 IconData로 변환한다.
    // 매핑에 없는 키가 올 경우 기본 타이머 아이콘을 사용한다.
    final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;
    final theme = Theme.of(context);

    // 일일 목표 진행률 (0.0 ~ 1.0)
    // dailyGoalMin이 0이면 목표가 없으므로 진행률 바를 표시하지 않는다.
    final hasGoal = preset.dailyGoalMin > 0;
    final progress = hasGoal ? (todayMinutes / preset.dailyGoalMin).clamp(0.0, 1.0) : 0.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 아이콘 배지 ─────────────────────────────────────
              // 프리셋 색상을 배경에 연하게 깔고, 아이콘을 진한 색으로 표시한다.
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: presetColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Icon(icon, color: presetColor, size: 28),
              ),

              const SizedBox(height: AppSpacing.gap),

              // ── 이름 + 시간 ─────────────────────────────────────
              Text(
                preset.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('${preset.durationMin}분', style: theme.textTheme.bodySmall),

              // Column 내부에서 남은 공간을 차지하여
              // 진행률 바를 카드 하단에 고정한다.
              const Spacer(),

              // ── 일일 진행률 ─────────────────────────────────────
              if (hasGoal) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: presetColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(presetColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$todayMinutes / ${preset.dailyGoalMin}분',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
