import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/features/location/data/geofence_service_impl.dart';
import 'package:taptime/shared/services/geofence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.taptime.taptime/geofence');
  late GeofenceServiceImpl service;

  /// 네이티브 측 응답을 시뮬레이션하는 핸들러.
  /// 각 테스트에서 필요한 응답을 설정한다.
  MethodCall? lastCall;
  dynamic mockResult;

  setUp(() {
    lastCall = null;
    mockResult = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      lastCall = call;
      return mockResult;
    });

    service = GeofenceServiceImpl();
  });

  tearDown(() {
    service.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Dart → Native 명령', () {
    test('startMonitoring은 네이티브에 startMonitoring을 호출한다', () async {
      await service.startMonitoring();
      expect(lastCall?.method, 'startMonitoring');
    });

    test('stopMonitoring은 네이티브에 stopMonitoring을 호출한다', () async {
      await service.stopMonitoring();
      expect(lastCall?.method, 'stopMonitoring');
    });

    test('addRegion은 올바른 인자를 전달한다', () async {
      await service.addRegion(
        id: 'test-id',
        placeName: '카페',
        latitude: 37.5665,
        longitude: 126.978,
        radiusMeters: 200,
        notifyOnEntry: true,
        notifyOnExit: false,
      );

      expect(lastCall?.method, 'addRegion');
      final args = lastCall?.arguments as Map;
      expect(args['id'], 'test-id');
      expect(args['placeName'], '카페');
      expect(args['latitude'], 37.5665);
      expect(args['longitude'], 126.978);
      expect(args['radiusMeters'], 200);
      expect(args['notifyOnEntry'], true);
      expect(args['notifyOnExit'], false);
    });

    test('removeRegion은 id를 전달한다', () async {
      await service.removeRegion('test-id');

      expect(lastCall?.method, 'removeRegion');
      final args = lastCall?.arguments as Map;
      expect(args['id'], 'test-id');
    });

    test('removeAllRegions는 네이티브에 removeAllRegions를 호출한다', () async {
      await service.removeAllRegions();
      expect(lastCall?.method, 'removeAllRegions');
    });

    test('checkPermission은 권한 상태를 파싱한다', () async {
      mockResult = 'authorizedAlways';
      final status = await service.checkPermission();
      expect(status, GeofencePermissionStatus.authorizedAlways);
    });

    test('checkPermission은 알 수 없는 값에 notDetermined를 반환한다', () async {
      mockResult = 'unknownStatus';
      final status = await service.checkPermission();
      expect(status, GeofencePermissionStatus.notDetermined);
    });

    test('requestPermission은 권한 상태를 반환한다', () async {
      mockResult = 'authorizedWhenInUse';
      final status = await service.requestPermission();
      expect(status, GeofencePermissionStatus.authorizedWhenInUse);
    });

    test('getMonitoredRegionIds는 ID 목록을 반환한다', () async {
      mockResult = <dynamic>['region-1', 'region-2'];
      final ids = await service.getMonitoredRegionIds();
      expect(ids, ['region-1', 'region-2']);
    });

    test('getMonitoredRegionIds는 null 응답 시 빈 목록을 반환한다', () async {
      mockResult = null;
      final ids = await service.getMonitoredRegionIds();
      expect(ids, isEmpty);
    });
  });

  group('Native → Dart 이벤트', () {
    test('onRegionEntered 콜백은 entered 이벤트를 방출한다', () async {
      final events = <GeofenceEvent>[];
      final sub = service.watchEvents().listen(events.add);

      // Swift → Dart 콜백 시뮬레이션
      await _simulateNativeCallback(
        channel,
        'onRegionEntered',
        {'regionId': 'test-region'},
      );

      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.regionId, 'test-region');
      expect(events.first.type, GeofenceEventType.entered);

      await sub.cancel();
    });

    test('onRegionExited 콜백은 exited 이벤트를 방출한다', () async {
      final events = <GeofenceEvent>[];
      final sub = service.watchEvents().listen(events.add);

      await _simulateNativeCallback(
        channel,
        'onRegionExited',
        {'regionId': 'test-region'},
      );

      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.type, GeofenceEventType.exited);

      await sub.cancel();
    });

    test('watchEvents는 broadcast 스트림이다 (다중 리스너 가능)', () async {
      final events1 = <GeofenceEvent>[];
      final events2 = <GeofenceEvent>[];
      final sub1 = service.watchEvents().listen(events1.add);
      final sub2 = service.watchEvents().listen(events2.add);

      await _simulateNativeCallback(
        channel,
        'onRegionEntered',
        {'regionId': 'test-region'},
      );

      await Future<void>.delayed(Duration.zero);

      expect(events1, hasLength(1));
      expect(events2, hasLength(1));

      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('권한 상태 파싱', () {
    final cases = {
      'notDetermined': GeofencePermissionStatus.notDetermined,
      'authorizedWhenInUse': GeofencePermissionStatus.authorizedWhenInUse,
      'authorizedAlways': GeofencePermissionStatus.authorizedAlways,
      'denied': GeofencePermissionStatus.denied,
      'restricted': GeofencePermissionStatus.restricted,
    };

    for (final entry in cases.entries) {
      test('${entry.key}를 올바르게 파싱한다', () async {
        mockResult = entry.key;
        final status = await service.checkPermission();
        expect(status, entry.value);
      });
    }
  });
}

/// 네이티브 측에서 Dart로 메서드를 호출하는 것을 시뮬레이션한다.
Future<void> _simulateNativeCallback(
  MethodChannel channel,
  String method,
  Map<String, dynamic> arguments,
) async {
  final data = const StandardMethodCodec().encodeMethodCall(
    MethodCall(method, arguments),
  );

  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    channel.name,
    data,
    (ByteData? reply) {},
  );
}
