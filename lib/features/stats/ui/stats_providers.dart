import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/session.dart';

/// Today 탭에서 선택된 날짜.
final statsDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Week 탭에서 선택된 주의 월요일.
final statsWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - (now.weekday - 1));
});

/// 선택된 날짜의 세션 목록을 실시간으로 관찰한다.
final daySessionsProvider = StreamProvider<List<Session>>((ref) {
  final date = ref.watch(statsDayProvider);
  return ref.watch(sessionRepositoryProvider).watchSessionsByDate(date);
});

/// 선택된 주의 세션 목록을 실시간으로 관찰한다.
final weekSessionsProvider = StreamProvider<List<Session>>((ref) {
  final weekStart = ref.watch(statsWeekStartProvider);
  final weekEnd = DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59, 999);
  return ref.watch(sessionRepositoryProvider).watchSessionsByDateRange(weekStart, weekEnd);
});

/// Month 탭에서 선택된 월의 첫째 날.
final statsMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// 선택된 월의 세션 목록을 실시간으로 관찰한다.
final monthSessionsProvider = StreamProvider<List<Session>>((ref) {
  final month = ref.watch(statsMonthProvider);
  return ref.watch(sessionRepositoryProvider).watchSessionsByMonth(month.year, month.month);
});

/// 특정 프리셋의 선택된 월 일별 총 소요 시간.
/// 프리셋별 히트맵 캘린더에서 사용.
final monthDailyTotalsForPresetProvider = FutureProvider.family<Map<DateTime, int>, String>((ref, presetId) {
  final month = ref.watch(statsMonthProvider);
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
  return ref.watch(sessionRepositoryProvider).getDailyTotalsForPreset(start, end, presetId);
});

/// 특정 프리셋의 연속 기록일 수 (스트릭).
///
/// 오늘부터 과거로 거슬러 올라가며 해당 프리셋의 세션이 있는 연속 날짜를 센다.
/// 오늘 아직 세션이 없으면 어제부터 계산한다.
final streakForPresetProvider = FutureProvider.family<int, String>((ref, presetId) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final start = today.subtract(const Duration(days: 365));
  final dailyTotals = await ref.watch(sessionRepositoryProvider).getDailyTotalsForPreset(start, today, presetId);

  var streak = 0;
  var date = today;

  // 오늘 세션이 없으면 어제부터 시작
  if (!dailyTotals.containsKey(date)) {
    date = date.subtract(const Duration(days: 1));
  }

  while (dailyTotals.containsKey(date) && streak < 366) {
    streak++;
    date = date.subtract(const Duration(days: 1));
  }

  return streak;
});
