import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/stats/ui/stats_providers.dart';
import 'package:taptime/features/stats/ui/widgets/goal_progress_bar.dart';
import 'package:taptime/shared/models/preset.dart';

/// 주간 통계 뷰.
///
/// 요일별 바 차트와 카테고리별 도넛 차트를 표시한다.
class WeekStatsView extends ConsumerWidget {
  const WeekStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(statsWeekStartProvider);
    final sessionsAsync = ref.watch(weekSessionsProvider);
    final presetMapAsync = ref.watch(presetMapProvider);

    return Column(
      children: [
        _WeekNavigator(
          weekStart: weekStart,
          onPrevious: () =>
              ref.read(statsWeekStartProvider.notifier).state = weekStart.subtract(const Duration(days: 7)),
          onNext: _isCurrentWeek(weekStart)
              ? null
              : () =>
                  ref.read(statsWeekStartProvider.notifier).state = weekStart.add(const Duration(days: 7)),
        ),
        Expanded(
          child: sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Center(child: Text('이 주에 기록이 없습니다.'));
              }

              final presetMap = presetMapAsync.valueOrNull ?? {};

              // 요일별 총 시간 집계 (1=Mon ... 7=Sun)
              final dailyTotals = <int, int>{for (var i = 1; i <= 7; i++) i: 0};
              var totalSeconds = 0;
              for (final s in sessions) {
                dailyTotals[s.startedAt.weekday] =
                    (dailyTotals[s.startedAt.weekday] ?? 0) + s.durationSeconds;
                totalSeconds += s.durationSeconds;
              }

              // 프리셋별 총 시간 집계
              final presetTotals = <String, int>{};
              for (final s in sessions) {
                presetTotals[s.presetId] = (presetTotals[s.presetId] ?? 0) + s.durationSeconds;
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
                children: [
                  _TotalTimeCard(totalSeconds: totalSeconds),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('요일별 시간', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.grid),
                  _DailyBarChart(
                    dailyTotals: dailyTotals,
                    todayWeekday: _isCurrentWeek(weekStart) ? DateTime.now().weekday : null,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('카테고리별', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.grid),
                  _CategoryDonut(
                    presetTotals: presetTotals,
                    presetMap: presetMap,
                    totalSeconds: totalSeconds,
                  ),
                  // 주간 목표 달성률
                  ..._buildWeeklyGoals(presetTotals, presetMap, context),
                  const SizedBox(height: AppSpacing.padding),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// 주간 목표가 있는 프리셋의 달성률 위젯 목록을 생성한다.
  static List<Widget> _buildWeeklyGoals(
    Map<String, int> presetTotals,
    Map<String, Preset> presetMap,
    BuildContext context,
  ) {
    final withGoals = presetTotals.entries
        .where((e) => (presetMap[e.key]?.dailyGoalMin ?? 0) > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (withGoals.isEmpty) return [];

    return [
      const SizedBox(height: AppSpacing.sectionGap),
      Text('주간 목표 달성률', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.grid),
      for (final entry in withGoals)
        GoalProgressBar(
          preset: presetMap[entry.key]!,
          actualMinutes: entry.value ~/ 60,
          goalMinutes: presetMap[entry.key]!.dailyGoalMin * 7,
        ),
    ];
  }

  static bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final currentMonday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return weekStart.isSameDay(currentMonday);
  }
}

// ── 주간 네비게이터 ─────────────────────────────────────────

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({required this.weekStart, required this.onPrevious, this.onNext});

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    String label;
    if (weekStart.month == weekEnd.month) {
      label = '${weekStart.month}월 ${weekStart.day}일 ~ ${weekEnd.day}일';
    } else {
      label = '${weekStart.month}/${weekStart.day} ~ ${weekEnd.month}/${weekEnd.day}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.grid, vertical: AppSpacing.grid),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

// ── 총 시간 카드 ────────────────────────────────────────────

class _TotalTimeCard extends StatelessWidget {
  const _TotalTimeCard({required this.totalSeconds});

  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Center(
          child: Column(
            children: [
              Text('총 시간', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                TimeFormatter.humanize(totalSeconds ~/ 60),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 요일별 바 차트 ──────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.dailyTotals, this.todayWeekday});

  final Map<int, int> dailyTotals;

  /// 이번 주를 보고 있을 때만 오늘 요일을 하이라이트. null이면 하이라이트 없음.
  final int? todayWeekday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSeconds = dailyTotals.values.fold<int>(0, (a, b) => a > b ? a : b);
    const barMaxHeight = 120.0;
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: SizedBox(
          height: barMaxHeight + 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final seconds = dailyTotals[weekday] ?? 0;
              final fraction = maxSeconds > 0 ? seconds / maxSeconds : 0.0;
              final isToday = todayWeekday == weekday;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (seconds > 0)
                        Text(
                          _formatShort(seconds),
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: seconds > 0 ? (fraction * barMaxHeight).clamp(2, barMaxHeight) : 0,
                        decoration: BoxDecoration(
                          color: isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weekdays[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static String _formatShort(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    if (rem == 0) return '${hours}h';
    return '${hours}h${rem}m';
  }
}

// ── 카테고리 도넛 차트 ──────────────────────────────────────

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({
    required this.presetTotals,
    required this.presetMap,
    required this.totalSeconds,
  });

  final Map<String, int> presetTotals;
  final Map<String, Preset> presetMap;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final entries = presetTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final segments = entries.map((e) {
      final preset = presetMap[e.key];
      final color = preset != null ? ColorUtils.fromHex(preset.color) : Colors.grey;
      return _DonutSegment(color: color, fraction: totalSeconds > 0 ? e.value / totalSeconds : 0);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(120, 120),
              painter: _DonutPainter(segments),
            ),
            const SizedBox(width: AppSpacing.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in entries)
                    _LegendItem(
                      color: presetMap[entry.key] != null
                          ? ColorUtils.fromHex(presetMap[entry.key]!.color)
                          : Colors.grey,
                      name: presetMap[entry.key]?.name ?? '삭제됨',
                      percentage: totalSeconds > 0 ? (entry.value / totalSeconds * 100).round() : 0,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({required this.color, required this.fraction});

  final Color color;
  final double fraction;
}

/// 도넛 차트 CustomPainter.
///
/// 12시 방향(-π/2)부터 시작하여 각 세그먼트를 순서대로 그린다.
/// 세그먼트 간 간격 없이 연속으로 그려 깔끔한 원형을 만든다.
class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.segments);

  final List<_DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 20.0;
    final radius = size.shortestSide / 2 - strokeWidth / 2;

    var startAngle = -pi / 2;
    for (final seg in segments) {
      final sweepAngle = 2 * pi * seg.fraction;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.segments != segments;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.name, required this.percentage});

  final Color color;
  final String name;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: Theme.of(context).textTheme.bodySmall)),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
