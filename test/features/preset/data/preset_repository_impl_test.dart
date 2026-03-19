import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/features/preset/data/preset_repository_impl.dart';
import 'package:taptime/shared/models/preset.dart';

void main() {
  late AppDatabase db;
  late PresetRepositoryImpl repo;

  final now = DateTime(2026, 3, 19);

  Preset makePreset({
    String id = 'p1',
    String name = 'Study',
    int durationMin = 25,
    int sortOrder = 0,
  }) {
    return Preset(
      id: id,
      name: name,
      durationMin: durationMin,
      icon: 'menu_book',
      color: '#4A90D9',
      dailyGoalMin: 0,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PresetRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('CRUD', () {
    test('빈 DB에서 getAllPresets는 빈 리스트를 반환한다', () async {
      final presets = await repo.getAllPresets();
      expect(presets, isEmpty);
    });

    test('createPreset 후 getAllPresets로 조회된다', () async {
      await repo.createPreset(makePreset());
      final presets = await repo.getAllPresets();
      expect(presets, hasLength(1));
      expect(presets.first.name, 'Study');
    });

    test('getPresetById로 단일 프리셋을 조회한다', () async {
      await repo.createPreset(makePreset());
      final preset = await repo.getPresetById('p1');
      expect(preset, isNotNull);
      expect(preset!.id, 'p1');
    });

    test('존재하지 않는 id로 조회하면 null을 반환한다', () async {
      final preset = await repo.getPresetById('nonexistent');
      expect(preset, isNull);
    });

    test('updatePreset으로 수정한다', () async {
      await repo.createPreset(makePreset());
      await repo.updatePreset(makePreset().copyWith(name: 'Reading'));
      final preset = await repo.getPresetById('p1');
      expect(preset!.name, 'Reading');
    });

    test('deletePreset으로 삭제한다', () async {
      await repo.createPreset(makePreset());
      await repo.deletePreset('p1');
      final presets = await repo.getAllPresets();
      expect(presets, isEmpty);
    });

    test('deleteAllPresets로 전체 삭제한다', () async {
      await repo.createPreset(makePreset());
      await repo.createPreset(makePreset(id: 'p2', name: 'Ex', sortOrder: 1));
      await repo.deleteAllPresets();
      final presets = await repo.getAllPresets();
      expect(presets, isEmpty);
    });
  });

  group('정렬', () {
    test('getAllPresets는 sortOrder 순으로 반환한다', () async {
      await repo.createPreset(makePreset(id: 'p2', name: 'B', sortOrder: 2));
      await repo.createPreset(makePreset(name: 'A', sortOrder: 1));
      await repo.createPreset(makePreset(id: 'p3', name: 'C'));
      final presets = await repo.getAllPresets();
      expect(presets.map((p) => p.name).toList(), ['C', 'A', 'B']);
    });

    test('updateSortOrder로 순서를 변경한다', () async {
      await repo.createPreset(makePreset(name: 'A'));
      await repo.createPreset(makePreset(id: 'p2', name: 'B', sortOrder: 1));
      await repo.updateSortOrder({'p1': 1, 'p2': 0});
      final presets = await repo.getAllPresets();
      expect(presets.first.name, 'B');
    });
  });

  group('watchAllPresets', () {
    test('데이터 변경 시 새 값을 emit한다', () async {
      // insert 전: 빈 리스트
      final before = await repo.watchAllPresets().first;
      expect(before, isEmpty);

      await repo.createPreset(makePreset());

      // insert 후: 1개
      final after = await repo.watchAllPresets().first;
      expect(after, hasLength(1));
    });
  });
}
