import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:taptime/core/utils/enum_utils.dart';
import 'package:taptime/shared/services/geofence_service.dart';

/// MethodChannel 기반 GeofenceService 구현.
///
/// iOS 네이티브 GeofencePlugin과 통신하여 CLLocationManager 지오펜스 모니터링을 제어한다.
/// Dart → Swift: startMonitoring, addRegion 등 명령 전송
/// Swift → Dart: onRegionEntered, onRegionExited 등 이벤트 수신
class GeofenceServiceImpl implements GeofenceService {
  GeofenceServiceImpl() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const _channel = MethodChannel('com.taptime.taptime/geofence');

  final _eventController = StreamController<GeofenceEvent>.broadcast();

  // ── Dart → Swift 명령 ──────────────────────────────────────

  @override
  Future<void> startMonitoring() async {
    await _channel.invokeMethod<void>('startMonitoring');
  }

  @override
  Future<void> stopMonitoring() async {
    await _channel.invokeMethod<void>('stopMonitoring');
  }

  @override
  Future<void> addRegion({
    required String id,
    required String placeName,
    required String presetName,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required bool notifyOnEntry,
    required bool notifyOnExit,
  }) async {
    await _channel.invokeMethod<void>('addRegion', {
      'id': id,
      'placeName': placeName,
      'presetName': presetName,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'notifyOnEntry': notifyOnEntry,
      'notifyOnExit': notifyOnExit,
    });
  }

  @override
  Future<void> removeRegion(String id) async {
    await _channel.invokeMethod<void>('removeRegion', {'id': id});
  }

  @override
  Future<void> removeAllRegions() async {
    await _channel.invokeMethod<void>('removeAllRegions');
  }

  @override
  Future<GeofencePermissionStatus> checkPermission() async {
    final status = await _channel.invokeMethod<String>('checkPermission');
    return _parsePermissionStatus(status);
  }

  @override
  Future<GeofencePermissionStatus> requestPermission() async {
    final status = await _channel.invokeMethod<String>('requestPermission');
    return _parsePermissionStatus(status);
  }

  @override
  Future<List<String>> getMonitoredRegionIds() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getMonitoredRegionIds');
    return result?.cast<String>() ?? [];
  }

  // ── Swift → Dart 이벤트 수신 ───────────────────────────────

  @override
  Stream<GeofenceEvent> watchEvents() => _eventController.stream;

  /// Swift에서 보내는 콜백을 처리한다.
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onRegionEntered':
        _emitRegionEvent(call.arguments, GeofenceEventType.entered);
      case 'onRegionExited':
        _emitRegionEvent(call.arguments, GeofenceEventType.exited);
      case 'onPermissionChanged':
        // Phase D에서 GeofenceManager가 권한 변경을 처리할 예정
        break;
      case 'onError':
        final args = (call.arguments as Map).cast<String, dynamic>();
        debugPrint('[GeofenceService] Error: region=${args['regionId']}, message=${args['message']}');
    }
  }

  void _emitRegionEvent(dynamic arguments, GeofenceEventType type) {
    final args = (arguments as Map).cast<String, dynamic>();
    _eventController.add(GeofenceEvent(
      regionId: args['regionId'] as String,
      type: type,
      timestamp: DateTime.now(),
    ));
  }

  // ── 변환 ───────────────────────────────────────────────────

  GeofencePermissionStatus _parsePermissionStatus(String? status) {
    return safeEnumByName(GeofencePermissionStatus.values, status) ?? GeofencePermissionStatus.notDetermined;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final result = await _channel.invokeMethod<bool>('requestNotificationPermission');
    return result ?? false;
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}
