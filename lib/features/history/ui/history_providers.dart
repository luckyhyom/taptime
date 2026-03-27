import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/session.dart';

/// 히스토리 화면에서 선택된 날짜.
///
/// autoDispose: 히스토리 화면을 벗어나면 상태가 해제되어
/// 다시 진입할 때 항상 오늘 날짜(`DateTime.now()`)로 초기화된다.
/// 날짜 네비게이터로 이전/다음 날짜를 탐색할 수 있다.
final selectedDateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());

/// 선택된 날짜의 세션 목록을 실시간으로 관찰한다.
///
/// autoDispose: selectedDateProvider와 함께 해제되어
/// 히스토리 화면 재진입 시 오늘 날짜의 세션을 새로 구독한다.
final sessionsForDateProvider = StreamProvider.autoDispose<List<Session>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessionsByDate(date);
});
