import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taptime/features/location/data/geofence_manager.dart';
import 'package:taptime/shared/models/location_trigger.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/services/geofence_service.dart';

import '../../../../test/mocks/mock_repositories.dart';

// ── 테스트 헬퍼 ────────────────────────────────────────────────

LocationTrigger _makeTrigger({
  String id = 'trigger-1',
  String placeName = '사무실',
}) {
  return LocationTrigger(
    id: id,
    placeName: placeName,
    latitude: 37.5665,
    longitude: 126.978,
    radiusMeters: 200,
    createdAt: DateTime(2026),
  );
}

Preset _makePreset({
  String id = 'preset-1',
  String name = '공부',
  String? locationTriggerId = 'trigger-1',
}) {
  return Preset(
    id: id,
    name: name,
    durationMin: 25,
    icon: 'book',
    color: '#4A90D9',
    dailyGoalMin: 120,
    sortOrder: 0,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    locationTriggerId: locationTriggerId,
  );
}

void main() {
  late MockGeofenceService mockGeofenceService;
  late MockLocationTriggerRepository mockTriggerRepo;
  late MockPresetRepository mockPresetRepo;
  late GeofenceManager manager;
  late StreamController<GeofenceEvent> eventController;
  late StreamController<List<LocationTrigger>> triggerStreamController;

  setUp(() {
    mockGeofenceService = MockGeofenceService();
    mockTriggerRepo = MockLocationTriggerRepository();
    mockPresetRepo = MockPresetRepository();
    eventController = StreamController<GeofenceEvent>.broadcast();
    triggerStreamController = StreamController<List<LocationTrigger>>.broadcast();

    when(() => mockGeofenceService.startMonitoring()).thenAnswer((_) async {});
    when(() => mockGeofenceService.stopMonitoring()).thenAnswer((_) async {});
    when(() => mockGeofenceService.removeAllRegions()).thenAnswer((_) async {});
    when(() => mockGeofenceService.watchEvents()).thenAnswer((_) => eventController.stream);
    when(() => mockTriggerRepo.watchAllTriggers()).thenAnswer((_) => triggerStreamController.stream);

    manager = GeofenceManager(
      geofenceService: mockGeofenceService,
      triggerRepo: mockTriggerRepo,
      presetRepo: mockPresetRepo,
    );
  });

  tearDown(() async {
    await eventController.close();
    await triggerStreamController.close();
  });

  group('진입 이벤트 처리', () {
    test('진입 시 연결된 프리셋이 있으면 start 액션을 emit한다', () async {
      final trigger = _makeTrigger();
      final preset = _makePreset();

      when(() => mockTriggerRepo.getTriggerById('trigger-1'))
          .thenAnswer((_) async => trigger);
      when(() => mockPresetRepo.getAllPresets())
          .thenAnswer((_) async => [preset]);

      await manager.start();

      final actions = <GeofenceAction>[];
      manager.actions.listen(actions.add);

      eventController.add(GeofenceEvent(
        regionId: 'trigger-1',
        type: GeofenceEventType.entered,
        timestamp: DateTime.now(),
      ));

      // 비동기 처리 대기
      await Future<void>.delayed(Duration.zero);

      expect(actions, hasLength(1));
      expect(actions.first.type, GeofenceActionType.start);
      expect(actions.first.presetId, 'preset-1');
      expect(actions.first.presetName, '공부');
      expect(actions.first.placeName, '사무실');
    });

    test('진입 시 트리거가 DB에 없으면 액션을 emit하지 않는다', () async {
      when(() => mockTriggerRepo.getTriggerById('deleted-trigger'))
          .thenAnswer((_) async => null);

      await manager.start();

      final actions = <GeofenceAction>[];
      manager.actions.listen(actions.add);

      eventController.add(GeofenceEvent(
        regionId: 'deleted-trigger',
        type: GeofenceEventType.entered,
        timestamp: DateTime.now(),
      ));

      await Future<void>.delayed(Duration.zero);

      expect(actions, isEmpty);
    });

    test('진입 시 연결된 프리셋이 없으면 액션을 emit하지 않는다', () async {
      final trigger = _makeTrigger();
      // locationTriggerId가 다른 프리셋만 존재
      final unrelatedPreset = _makePreset(
        id: 'preset-other',
        locationTriggerId: 'trigger-other',
      );

      when(() => mockTriggerRepo.getTriggerById('trigger-1'))
          .thenAnswer((_) async => trigger);
      when(() => mockPresetRepo.getAllPresets())
          .thenAnswer((_) async => [unrelatedPreset]);

      await manager.start();

      final actions = <GeofenceAction>[];
      manager.actions.listen(actions.add);

      eventController.add(GeofenceEvent(
        regionId: 'trigger-1',
        type: GeofenceEventType.entered,
        timestamp: DateTime.now(),
      ));

      await Future<void>.delayed(Duration.zero);

      expect(actions, isEmpty);
    });
  });

  group('퇴장 이벤트 처리', () {
    test('퇴장 시 연결된 프리셋이 있으면 stop 액션을 emit한다', () async {
      final trigger = _makeTrigger();
      final preset = _makePreset();

      when(() => mockTriggerRepo.getTriggerById('trigger-1'))
          .thenAnswer((_) async => trigger);
      when(() => mockPresetRepo.getAllPresets())
          .thenAnswer((_) async => [preset]);

      await manager.start();

      final actions = <GeofenceAction>[];
      manager.actions.listen(actions.add);

      eventController.add(GeofenceEvent(
        regionId: 'trigger-1',
        type: GeofenceEventType.exited,
        timestamp: DateTime.now(),
      ));

      await Future<void>.delayed(Duration.zero);

      expect(actions, hasLength(1));
      expect(actions.first.type, GeofenceActionType.stop);
      expect(actions.first.presetId, 'preset-1');
      expect(actions.first.presetName, '공부');
      expect(actions.first.placeName, '사무실');
    });

    test('퇴장 시 연결된 프리셋이 없으면 액션을 emit하지 않는다', () async {
      final trigger = _makeTrigger();

      when(() => mockTriggerRepo.getTriggerById('trigger-1'))
          .thenAnswer((_) async => trigger);
      when(() => mockPresetRepo.getAllPresets())
          .thenAnswer((_) async => []);

      await manager.start();

      final actions = <GeofenceAction>[];
      manager.actions.listen(actions.add);

      eventController.add(GeofenceEvent(
        regionId: 'trigger-1',
        type: GeofenceEventType.exited,
        timestamp: DateTime.now(),
      ));

      await Future<void>.delayed(Duration.zero);

      expect(actions, isEmpty);
    });
  });
}
