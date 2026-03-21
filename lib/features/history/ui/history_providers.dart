import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/session.dart';

/// 히스토리 화면에서 선택된 날짜.
///
/// 화면 진입 시 오늘 날짜로 초기화되며,
/// 날짜 네비게이터로 이전/다음 날짜를 탐색할 수 있다.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 선택된 날짜의 세션 목록을 실시간으로 관찰한다.
///
/// selectedDateProvider가 바뀔 때마다 자동으로 새 날짜의 스트림을 구독한다.
final sessionsForDateProvider = StreamProvider<List<Session>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessionsByDate(date);
});
