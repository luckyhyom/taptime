import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/active_timer.dart';
import 'package:taptime/shared/models/preset.dart';

/// 프리셋 목록을 실시간으로 관찰하는 스트림 프로바이더.
///
/// watchAllPresets()는 DB의 프리셋 테이블을 감시하는 Stream을 반환한다.
/// 프리셋이 추가/수정/삭제되면 Stream이 새 리스트를 방출하고,
/// 이 프로바이더를 watch하는 홈 그리드가 자동으로 리빌드된다.
final presetListProvider = StreamProvider<List<Preset>>((ref) {
  final repo = ref.watch(presetRepositoryProvider);
  return repo.watchAllPresets();
});

/// 오늘 프리셋별 총 소요 시간 (초 단위).
///
/// 홈 화면 프리셋 카드의 일일 진행률 표시에 사용한다.
/// 새 세션이 저장되면 자동으로 갱신된다.
/// 현재 활성 타이머를 실시간으로 관찰한다.
///
/// 홈 화면 프리셋 카드에 실행 중/일시정지 상태를 표시하는 데 사용한다.
final activeTimerProvider = StreamProvider<ActiveTimer?>((ref) {
  return ref.watch(activeTimerRepositoryProvider).watchActiveTimer();
});

final todayDurationByPresetProvider = StreamProvider<Map<String, int>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessionsByDate(DateTime.now()).map((sessions) {
    final result = <String, int>{};
    for (final s in sessions) {
      result[s.presetId] = (result[s.presetId] ?? 0) + s.durationSeconds;
    }
    return result;
  });
});
