import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/shared/models/preset.dart';
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

/// 프리셋 ID → Preset 매핑.
///
/// 세션 타일에서 프리셋 이름/아이콘/색상을 표시할 때 사용한다.
/// 삭제된 프리셋의 세션은 이 맵에 없을 수 있으므로 nullable 조회 필요.
final presetMapProvider = StreamProvider<Map<String, Preset>>((ref) {
  final repo = ref.watch(presetRepositoryProvider);
  return repo.watchAllPresets().map(
        (presets) => {for (final p in presets) p.id: p},
      );
});
