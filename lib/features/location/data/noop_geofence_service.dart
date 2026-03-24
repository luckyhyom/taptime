import 'package:taptime/shared/services/geofence_service.dart';

/// GeofenceService의 NoOp(무동작) 구현.
///
/// iOS 이외 플랫폼(Android 등)에서 사용된다.
/// 모든 메서드가 아무것도 하지 않고 즉시 반환한다.
class NoopGeofenceService implements GeofenceService {
  @override
  Future<void> startMonitoring() async {}

  @override
  Future<void> stopMonitoring() async {}

  @override
  Future<void> addRegion({
    required String id,
    required String placeName,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required bool notifyOnEntry,
    required bool notifyOnExit,
  }) async {}

  @override
  Future<void> removeRegion(String id) async {}

  @override
  Future<void> removeAllRegions() async {}

  @override
  Stream<GeofenceEvent> watchEvents() => const Stream.empty();

  @override
  Future<GeofencePermissionStatus> checkPermission() async => GeofencePermissionStatus.denied;

  @override
  Future<GeofencePermissionStatus> requestPermission() async => GeofencePermissionStatus.denied;

  @override
  Future<List<String>> getMonitoredRegionIds() async => [];

  @override
  void dispose() {}
}
