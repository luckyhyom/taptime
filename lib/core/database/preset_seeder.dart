import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:uuid/uuid.dart';

/// 앱 최초 실행 시 기본 프리셋을 생성하는 시더.
///
/// 프리셋 테이블이 비어있을 때만 AppConstants.defaultPresets 기반으로
/// 기본 프리셋 3개(Study, Exercise, Reading)를 생성한다.
/// Riverpod provider 초기화 시점에서 호출된다.
class PresetSeeder {
  PresetSeeder(this._repository);

  final PresetRepository _repository;

  static const _uuid = Uuid();

  /// 프리셋이 없으면 기본 프리셋을 생성한다.
  /// 이미 프리셋이 존재하면 아무 것도 하지 않는다.
  Future<void> seedIfEmpty() async {
    final existing = await _repository.getAllPresets();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    for (var i = 0; i < AppConstants.defaultPresets.length; i++) {
      final data = AppConstants.defaultPresets[i];
      final preset = Preset(
        id: _uuid.v4(),
        name: data['name']! as String,
        durationMin: data['durationMin']! as int,
        icon: data['icon']! as String,
        color: data['color']! as String,
        dailyGoalMin: data['dailyGoalMin']! as int,
        sortOrder: i,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.createPreset(preset);
    }
  }
}
