import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taptime/features/sync/data/connectivity_monitor.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityMonitor monitor;

  setUp(() {
    mockConnectivity = MockConnectivity();
    monitor = ConnectivityMonitor(connectivity: mockConnectivity);
  });

  group('isOnline', () {
    test('wifi 연결 시 true를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);

      expect(await monitor.isOnline, isTrue);
    });

    test('mobile 연결 시 true를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.mobile]);

      expect(await monitor.isOnline, isTrue);
    });

    test('ethernet 연결 시 true를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.ethernet]);

      expect(await monitor.isOnline, isTrue);
    });

    test('none 연결 시 false를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);

      expect(await monitor.isOnline, isFalse);
    });

    test('bluetooth만 연결 시 false를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.bluetooth]);

      expect(await monitor.isOnline, isFalse);
    });

    test('wifi + mobile 복합 연결 시 true를 반환한다', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);

      expect(await monitor.isOnline, isTrue);
    });
  });

  group('watchConnectivity', () {
    test('연결 상태 변경을 bool 스트림으로 변환한다', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer((_) => controller.stream);

      final results = <bool>[];
      final sub = monitor.watchConnectivity().listen(results.add);

      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.none]);
      controller.add([ConnectivityResult.mobile]);

      await Future.delayed(Duration.zero);

      expect(results, [true, false, true]);

      await sub.cancel();
      await controller.close();
    });
  });
}
