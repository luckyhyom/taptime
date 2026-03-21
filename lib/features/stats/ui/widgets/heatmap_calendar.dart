import 'package:flutter/material.dart';

import 'package:taptime/core/theme/app_spacing.dart';

/// GitHub 스타일 히트맵 캘린더.
///
/// 7열(월~일) 그리드로 월별 활동 강도를 색상으로 표시한다.
/// 각 셀의 색상은 해당 날짜의 총 활동 시간에 비례한다.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    required this.year,
    required this.month,
    required this.dailyTotals,
    this.activeColor,
    this.onDayTap,
    this.showCard = true,
    super.key,
  });

  final int year;
  final int month;

  /// 날짜(시간 제거) → 총 소요 시간(초) 매핑.
  final Map<DateTime, int> dailyTotals;

  /// 히트맵 셀 색상. null이면 테마의 primary 색상을 사용.
  final Color? activeColor;

  /// 날짜 셀 탭 콜백.
  final void Function(DateTime date)? onDayTap;

  /// Card로 감쌀지 여부. 프리셋별 컴팩트 모드에서는 false.
  final bool showCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;
    final firstDayOfMonth = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 월요일 = 1 기준으로 첫째 날 앞의 빈 칸 수
    final leadingBlanks = firstDayOfMonth.weekday - 1;

    // 최대 시간(초)을 기준으로 강도 계산
    final maxSeconds = dailyTotals.values.fold<int>(0, (a, b) => a > b ? a : b);

    final content = Column(
      children: [
        // 요일 헤더
        _WeekdayHeader(theme: theme),
        const SizedBox(height: AppSpacing.grid),
        // 날짜 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return const SizedBox.shrink();
            }

            final day = index - leadingBlanks + 1;
            final date = DateTime(year, month, day);
            final seconds = dailyTotals[date] ?? 0;
            final intensity = _intensity(seconds, maxSeconds);
            final isToday = _isToday(date);

            return GestureDetector(
              onTap: onDayTap != null ? () => onDayTap!(date) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: intensity > 0
                      ? color.withValues(alpha: intensity)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: isToday ? Border.all(color: color, width: 2) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: intensity > 0.5 ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    if (!showCard) return Padding(padding: const EdgeInsets.all(AppSpacing.grid), child: content);

    return Card(
      child: Padding(padding: const EdgeInsets.all(AppSpacing.padding), child: content),
    );
  }

  /// 4단계 강도: 0 (없음), 0.15, 0.35, 0.6, 1.0
  static double _intensity(int seconds, int maxSeconds) {
    if (seconds == 0) return 0;
    if (maxSeconds == 0) return 0;
    final ratio = seconds / maxSeconds;
    if (ratio <= 0.25) return .15;
    if (ratio <= 0.5) return 0.35;
    if (ratio <= 0.75) return 0.6;
    return 1;
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.theme});

  final ThemeData theme;

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
