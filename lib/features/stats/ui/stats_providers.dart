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
