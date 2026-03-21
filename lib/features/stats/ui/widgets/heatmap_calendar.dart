import 'package:flutter/material.dart';

import 'package:taptime/core/theme/app_spacing.dart';

/// GitHub 컨트리뷰션 그래프 스타일 히트맵.
///
/// 7행(Mon~Sun) × N열(주차) 그리드로 월별 활동 강도를 색상으로 표시한다.
/// 달력 레이아웃 대비 세로 공간을 약 3배 절약하여
/// 프리셋이 많을 때도 한눈에 비교할 수 있다.
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

  static const _monthLabels = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;
    final maxSeconds = dailyTotals.values.fold<int>(0, (a, b) => a > b ? a : b);
    final weeks = _buildWeeks(year, month);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = _cellSize(constraints.maxWidth, weeks.length);
        const cellSpacing = 2.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월 라벨 (GitHub 스타일: "Mar" 등)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text(
                _monthLabels[month],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 요일 라벨 (Mon, Wed, Fri — GitHub 컨벤션)
                _DayLabels(cellSize: cellSize, cellSpacing: cellSpacing, theme: theme),
                const SizedBox(width: 4),
                // 주차별 열
                for (var wi = 0; wi < weeks.length; wi++)
                  Padding(
                    padding: EdgeInsets.only(left: wi > 0 ? cellSpacing : 0),
                    child: Column(
                      children: [
                        for (var di = 0; di < 7; di++)
                          Padding(
                            padding: EdgeInsets.only(top: di > 0 ? cellSpacing : 0),
                            child: _buildCell(
                              date: weeks[wi][di],
                              cellSize: cellSize,
                              color: color,
                              maxSeconds: maxSeconds,
                              theme: theme,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );

    if (!showCard) return Padding(padding: const EdgeInsets.all(AppSpacing.grid), child: content);

    return Card(
      child: Padding(padding: const EdgeInsets.all(AppSpacing.padding), child: content),
    );
  }

  Widget _buildCell({
    required DateTime? date,
    required double cellSize,
    required Color color,
    required int maxSeconds,
    required ThemeData theme,
  }) {
    // 빈 칸 (월 시작 전 / 월 종료 후)
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final seconds = dailyTotals[date] ?? 0;
    final intensity = _intensity(seconds, maxSeconds);
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: onDayTap != null ? () => onDayTap!(date) : null,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: intensity > 0
              ? color.withValues(alpha: intensity)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
          border: isToday ? Border.all(color: color, width: 1.5) : null,
        ),
      ),
    );
  }

  // ── 데이터 변환 ─────────────────────────────────────────────

  /// 월의 날짜를 주차별 2차원 배열로 변환한다.
  ///
  /// 반환값: outer = 주차(열), inner = 요일 7개(Mon=0 ~ Sun=6).
  /// 월 시작 전/종료 후 빈 칸은 null.
  static List<List<DateTime?>> _buildWeeks(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weeks = <List<DateTime?>>[];
    var currentWeek = List<DateTime?>.filled(7, null);

    for (var day = 1; day <= daysInMonth; day++) {
      final weekdayIndex = DateTime(year, month, day).weekday - 1; // 0=Mon ~ 6=Sun

      // 새 주 시작 (월요일이고 첫날이 아닌 경우)
      if (weekdayIndex == 0 && day > 1) {
        weeks.add(currentWeek);
        currentWeek = List<DateTime?>.filled(7, null);
      }

      currentWeek[weekdayIndex] = DateTime(year, month, day);
    }
    weeks.add(currentWeek); // 마지막 주

    return weeks;
  }

  // ── 셀 크기 계산 ────────────────────────────────────────────

  /// 사용 가능한 너비와 주 수로 셀 크기를 계산한다.
  /// 10px 고정 크기를 기본으로, 최소 8px ~ 최대 14px.
  static double _cellSize(double availableWidth, int weekCount) {
    const dayLabelWidth = 28.0;
    const labelGap = 4.0;
    const cellSpacing = 2.0;
    final gridWidth = availableWidth - dayLabelWidth - labelGap;
    return ((gridWidth - (weekCount - 1) * cellSpacing) / weekCount).clamp(8.0, 14.0);
  }

  // ── 강도 계산 ───────────────────────────────────────────────

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

// ── 요일 라벨 (좌측 세로) ──────────────────────────────────────

/// GitHub 스타일 요일 라벨. Mon/Wed/Fri만 표시한다.
class _DayLabels extends StatelessWidget {
  const _DayLabels({
    required this.cellSize,
    required this.cellSpacing,
    required this.theme,
  });

  final double cellSize;
  final double cellSpacing;
  final ThemeData theme;

  // Mon=0, Tue=1, Wed=2, Thu=3, Fri=4, Sat=5, Sun=6
  static const _visibleIndices = {0, 2, 4}; // Mon, Wed, Fri
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          for (var i = 0; i < 7; i++)
            Container(
              height: cellSize + (i > 0 ? cellSpacing : 0),
              padding: EdgeInsets.only(top: i > 0 ? cellSpacing : 0),
              alignment: Alignment.centerLeft,
              child: _visibleIndices.contains(i)
                  ? Text(
                      _labels[i],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
