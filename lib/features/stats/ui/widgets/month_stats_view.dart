import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/stats/ui/stats_providers.dart';
import 'package:taptime/features/stats/ui/widgets/goal_progress_bar.dart';
import 'package:taptime/features/stats/ui/widgets/heatmap_calendar.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';

/// 월간 통계 뷰.
///
/// 프리셋별 히트맵 캘린더 + 스트릭, 총 시간, 카테고리별 도넛 차트를 표시한다.
class MonthStatsView extends ConsumerWidget {
  const MonthStatsView({required this.tabController, super.key});

  /// 히트맵 날짜 탭 시 Today 탭(index 0)으로 전환하기 위한 컨트롤러.
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(statsMonthProvider);
    final sessionsAsync = ref.watch(monthSessionsProvider);
    final presetMapAsync = ref.watch(presetMapProvider);

    return Column(
      children: [
        _MonthNavigator(
          month: month,
          onPrevious: () =>
              ref.read(statsMonthProvider.notifier).state = DateTime(month.year, month.month - 1),
          onNext: _isCurrentMonth(month)
              ? null
              : () => ref.read(statsMonthProvider.notifier).state = DateTime(month.year, month.month + 1),
        ),
        Expanded(
          child: sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (sessions) {
              final presetMap = presetMapAsync.valueOrNull ?? {};

              // 이 달에 세션이 있는 프리셋 ID 추출 (홈 화면 sortOrder 기준)
              final activePresetIds = <String>{};
              for (final s in sessions) {
                activePresetIds.add(s.presetId);
              }
              final sortedPresetIds = activePresetIds.toList()
                ..sort((a, b) {
                  final sa = presetMap[a]?.sortOrder ?? 999;
                  final sb = presetMap[b]?.sortOrder ?? 999;
                  return sa.compareTo(sb);
                });

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
                children: [
                  // 프리셋별 히트맵 + 스트릭
                  if (activePresetIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sectionGap),
                      child: Center(child: Text('이 달에 기록이 없습니다.')),
                    )
                  else
                    for (final presetId in sortedPresetIds)
                      _PresetHeatmapSection(
                        presetId: presetId,
                        preset: presetMap[presetId],
                        year: month.year,
                        month: month.month,
                        onDayTap: (date) {
                          ref.read(statsDayProvider.notifier).state = date;
                          tabController.animateTo(0);
                        },
                      ),
                  if (sessions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    // 총 시간
                    _TotalTimeCard(sessions: sessions),
                    const SizedBox(height: AppSpacing.sectionGap),
                    // 카테고리별 도넛
                    Text('카테고리별', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.grid),
                    _CategoryDonut(sessions: sessions, presetMap: presetMap),
                    // 월간 목표 달성률
                    ..._buildMonthlyGoals(sessions, presetMap, month, context),
                  ],
                  const SizedBox(height: AppSpacing.padding),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// 월간 목표가 있는 프리셋의 달성률 위젯 목록을 생성한다.
  static List<Widget> _buildMonthlyGoals(
    List<Session> sessions,
    Map<String, Preset> presetMap,
    DateTime month,
    BuildContext context,
  ) {
    final presetTotals = <String, int>{};
    for (final s in sessions) {
      presetTotals[s.presetId] = (presetTotals[s.presetId] ?? 0) + s.durationSeconds;
    }

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final withGoals = presetTotals.entries
        .where((e) => (presetMap[e.key]?.dailyGoalMin ?? 0) > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (withGoals.isEmpty) return [];

    return [
      const SizedBox(height: AppSpacing.sectionGap),
      Text('월간 목표 달성률', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.grid),
      for (final entry in withGoals)
        GoalProgressBar(
          preset: presetMap[entry.key]!,
          actualMinutes: entry.value ~/ 60,
          goalMinutes: presetMap[entry.key]!.dailyGoalMin * daysInMonth,
        ),
    ];
  }

  static bool _isCurrentMonth(DateTime month) {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }
}

// ── 프리셋별 히트맵 섹션 ────────────────────────────────────────

/// 개별 프리셋의 히트맵 + 인라인 스트릭을 표시하는 섹션.
class _PresetHeatmapSection extends ConsumerWidget {
  const _PresetHeatmapSection({
    required this.presetId,
    required this.preset,
    required this.year,
    required this.month,
    this.onDayTap,
  });

  final String presetId;
  final Preset? preset;
  final int year;
  final int month;
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTotalsAsync = ref.watch(monthDailyTotalsForPresetProvider(presetId));
    final streakAsync = ref.watch(streakForPresetProvider(presetId));
    final theme = Theme.of(context);

    final color = preset != null ? ColorUtils.fromHex(preset!.color) : Colors.grey;
    final icon = preset != null ? (AppConstants.presetIcons[preset!.icon] ?? Icons.timer) : Icons.circle;
    final name = preset?.name ?? '삭제됨';
    final streak = streakAsync.valueOrNull ?? 0;
    final dailyTotals = dailyTotalsAsync.valueOrNull ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.grid),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프리셋 헤더: 아이콘 + 이름 + 스트릭
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.grid),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (streak > 0) ...[
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    '$streak일',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.grid),
            // 히트맵 (Card 없이, 프리셋 색상 사용)
            HeatmapCalendar(
              year: year,
              month: month,
              dailyTotals: dailyTotals,
              activeColor: color,
              showCard: false,
              onDayTap: onDayTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 월간 네비게이터 ──────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({required this.month, required this.onPrevious, this.onNext});

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final label = '${month.year}년 ${month.month}월';

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

// ── 총 시간 카드 ─────────────────────────────────────────────

class _TotalTimeCard extends StatelessWidget {
  const _TotalTimeCard({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    var totalSeconds = 0;
    for (final s in sessions) {
      totalSeconds += s.durationSeconds;
    }

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

// ── 카테고리 도넛 차트 ──────────────────────────────────────────

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({required this.sessions, required this.presetMap});

  final List<Session> sessions;
  final Map<String, Preset> presetMap;

  @override
  Widget build(BuildContext context) {
    final presetTotals = <String, int>{};
    var totalSeconds = 0;
    for (final s in sessions) {
      presetTotals[s.presetId] = (presetTotals[s.presetId] ?? 0) + s.durationSeconds;
      totalSeconds += s.durationSeconds;
    }
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
