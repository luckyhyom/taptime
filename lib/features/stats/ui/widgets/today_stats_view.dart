import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/stats/ui/stats_providers.dart';
import 'package:taptime/features/stats/ui/widgets/goal_progress_bar.dart';
import 'package:taptime/shared/models/preset.dart';

/// 오늘(일간) 통계 뷰.
///
/// 총 시간, 활동별 시간 바 차트, 목표 달성률을 표시한다.
class TodayStatsView extends ConsumerWidget {
  const TodayStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(statsDayProvider);
    final sessionsAsync = ref.watch(daySessionsProvider);
    final presetMapAsync = ref.watch(presetMapProvider);

    return Column(
      children: [
        _DayNavigator(
          date: date,
          onPrevious: () => ref.read(statsDayProvider.notifier).state = date.subtract(const Duration(days: 1)),
          onNext: date.isSameDay(DateTime.now())
              ? null
              : () => ref.read(statsDayProvider.notifier).state = date.add(const Duration(days: 1)),
        ),
        Expanded(
          child: sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Center(child: Text('이 날짜에 기록이 없습니다.'));
              }

              final presetMap = presetMapAsync.valueOrNull ?? {};

              // 프리셋별 총 시간 집계
              final presetTotals = <String, int>{};
              var totalSeconds = 0;
              for (final s in sessions) {
                presetTotals[s.presetId] = (presetTotals[s.presetId] ?? 0) + s.durationSeconds;
                totalSeconds += s.durationSeconds;
              }
              final sorted = presetTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
              final maxSeconds = sorted.first.value;

              // 목표가 있는 프리셋 필터링
              final withGoals = sorted.where((e) => (presetMap[e.key]?.dailyGoalMin ?? 0) > 0).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
                children: [
                  _TotalTimeCard(totalSeconds: totalSeconds),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('활동별 시간', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.grid),
                  for (final entry in sorted)
                    _PresetTimeBar(
                      preset: presetMap[entry.key],
                      seconds: entry.value,
                      fraction: maxSeconds > 0 ? entry.value / maxSeconds : 0,
                    ),
                  if (withGoals.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    Text('목표 달성률', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.grid),
                    for (final entry in withGoals)
                      GoalProgressBar(
                        preset: presetMap[entry.key]!,
                        actualMinutes: entry.value ~/ 60,
                        goalMinutes: presetMap[entry.key]!.dailyGoalMin,
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 날짜 네비게이터 ─────────────────────────────────────────

class _DayNavigator extends StatelessWidget {
  const _DayNavigator({required this.date, required this.onPrevious, this.onNext});

  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.isSameDay(now)) {
      label = '오늘';
    } else if (date.isSameDay(now.subtract(const Duration(days: 1)))) {
      label = '어제';
    } else {
      label = '${date.month}월 ${date.day}일';
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

// ── 프리셋별 시간 바 ────────────────────────────────────────

class _PresetTimeBar extends StatelessWidget {
  const _PresetTimeBar({required this.preset, required this.seconds, required this.fraction});

  final Preset? preset;
  final int seconds;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = preset != null ? ColorUtils.fromHex(preset!.color) : theme.colorScheme.outline;
    final icon = preset != null ? (AppConstants.presetIcons[preset!.icon] ?? Icons.timer) : Icons.circle;
    final name = preset?.name ?? '삭제됨';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.grid),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.grid),
          SizedBox(
            width: 72,
            child: Text(name, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.grid),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 16,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.grid),
          SizedBox(
            width: 56,
            child: Text(
              TimeFormatter.humanize(seconds ~/ 60),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
