import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
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
