import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taptime/features/sync/data/sync_aware_preset_repository.dart';
import 'package:taptime/shared/models/preset.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late MockPresetRepository mockInner;
  late MockSyncService mockSyncService;
  late SyncAwarePresetRepository repo;

  final now = DateTime(2026, 3, 22);
  final preset = Preset(
    id: 'p1',
    name: 'Study',
    durationMin: 25,
    icon: 'menu_book',
    color: '#4A90D9',
    dailyGoalMin: 0,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockInner = MockPresetRepository();
    mockSyncService = MockSyncService();
    repo = SyncAwarePresetRepository(mockInner, mockSyncService);

    // syncNow는 항상 성공
    when(() => mockSyncService.syncNow()).thenAnswer((_) async {});
  });

  group('읽기 작업 위임', () {
    test('getAllPresets를 내부 리포지토리에 위임한다', () async {
      when(() => mockInner.getAllPresets()).thenAnswer((_) async => [preset]);

      final result = await repo.getAllPresets();

      expect(result, [preset]);
      verify(() => mockInner.getAllPresets()).called(1);
      verifyNever(() => mockSyncService.syncNow());
    });

    test('watchAllPresets를 내부 리포지토리에 위임한다', () {
      when(() => mockInner.watchAllPresets()).thenAnswer((_) => Stream.value([preset]));

      repo.watchAllPresets();

      verify(() => mockInner.watchAllPresets()).called(1);
      verifyNever(() => mockSyncService.syncNow());
    });

    test('getPresetById를 내부 리포지토리에 위임한다', () async {
      when(() => mockInner.getPresetById('p1')).thenAnswer((_) async => preset);

      final result = await repo.getPresetById('p1');

      expect(result, preset);
      verify(() => mockInner.getPresetById('p1')).called(1);
      verifyNever(() => mockSyncService.syncNow());
    });
  });

  group('쓰기 작업 + 동기화 트리거', () {
    test('createPreset 후 syncNow를 호출한다', () async {
      when(() => mockInner.createPreset(preset)).thenAnswer((_) async {});

      await repo.createPreset(preset);

      verify(() => mockInner.createPreset(preset)).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('updatePreset 후 syncNow를 호출한다', () async {
      when(() => mockInner.updatePreset(preset)).thenAnswer((_) async {});

      await repo.updatePreset(preset);

      verify(() => mockInner.updatePreset(preset)).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('deletePreset 후 syncNow를 호출한다', () async {
      when(() => mockInner.deletePreset('p1')).thenAnswer((_) async {});

      await repo.deletePreset('p1');

      verify(() => mockInner.deletePreset('p1')).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('updateSortOrder 후 syncNow를 호출한다', () async {
      final order = {'p1': 1, 'p2': 0};
      when(() => mockInner.updateSortOrder(order)).thenAnswer((_) async {});

      await repo.updateSortOrder(order);

      verify(() => mockInner.updateSortOrder(order)).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('deleteAllPresets은 syncNow를 호출하지 않는다', () async {
      when(() => mockInner.deleteAllPresets()).thenAnswer((_) async {});

      await repo.deleteAllPresets();

      verify(() => mockInner.deleteAllPresets()).called(1);
      verifyNever(() => mockSyncService.syncNow());
    });
  });
}
