import 'package:flutter/foundation.dart';

/// 지오펜스 이벤트 유형.
enum GeofenceEventType {
  /// 등록된 장소에 진입
  entered,

  /// 등록된 장소에서 퇴장
  exited,
}

/// 지오펜스 이벤트.
///
/// 사용자가 등록된 지오펜스 영역에 진입하거나 퇴장할 때 발생한다.
@immutable
class GeofenceEvent {
  const GeofenceEvent({
    required this.regionId,
    required this.type,
    required this.timestamp,
  });

  /// 이벤트가 발생한 지오펜스 영역의 ID (LocationTrigger.id와 동일)
  final String regionId;

  /// 진입/퇴장 구분
  final GeofenceEventType type;

  /// 이벤트 발생 시각
  final DateTime timestamp;
}

/// 위치 권한 상태.
///
/// 플랫폼별 위치 권한 상태를 통합 표현하는 enum.
/// 지오펜스 백그라운드 모니터링에는 [authorizedAlways]가 필요하다.
enum GeofencePermissionStatus {
  /// 아직 권한을 요청하지 않은 상태
  notDetermined,

  /// "앱 사용 중에만 허용" — 지오펜스 백그라운드 모니터링 불가
  authorizedWhenInUse,

  /// "항상 허용" — 지오펜스 모니터링 가능
  authorizedAlways,

  /// 사용자가 권한을 거부함
  denied,

  /// 시스템 제한으로 위치 서비스 사용 불가 (보호자 제한 등)
  restricted,
}

/// 지오펜스 모니터링 서비스 인터페이스.
///
/// 등록된 영역에 진입/퇴장 시 이벤트를 발생시키고, 로컬 알림을 표시한다.
/// 플랫폼별 구현체가 네이티브 지오펜스 API를 사용한다.
///
/// 제약사항:
/// - 최대 20개 영역 동시 모니터링 가능
/// - [GeofencePermissionStatus.authorizedAlways] 권한 필요
abstract class GeofenceService {
  /// 등록된 모든 지오펜스 영역의 모니터링을 시작한다.
  Future<void> startMonitoring();

  /// 모든 지오펜스 영역의 모니터링을 중단한다.
  Future<void> stopMonitoring();

  /// 단일 지오펜스 영역을 등록하고 모니터링을 시작한다.
  ///
  /// [id]는 LocationTrigger.id와 동일하게 사용한다.
  /// 최대 20개까지 등록 가능하며, 초과 시 예외를 던진다.
  Future<void> addRegion({
    required String id,
    required String placeName,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required bool notifyOnEntry,
    required bool notifyOnExit,
  });

  /// 단일 지오펜스 영역의 모니터링을 중단하고 등록을 해제한다.
  Future<void> removeRegion(String id);

  /// 모든 지오펜스 영역의 등록을 해제한다.
  Future<void> removeAllRegions();

  /// 지오펜스 진입/퇴장 이벤트 스트림.
  ///
  /// 앱이 백그라운드에 있어도 이벤트가 발생하며,
  /// 네이티브 측에서 로컬 알림도 함께 표시한다.
  Stream<GeofenceEvent> watchEvents();

  /// 현재 위치 권한 상태를 확인한다.
  Future<GeofencePermissionStatus> checkPermission();

  /// 위치 권한을 요청한다.
  ///
  /// "항상 허용(Always)" 권한을 요청한다.
  /// 이미 WhenInUse 상태이면 Always로 업그레이드를 시도한다.
  Future<GeofencePermissionStatus> requestPermission();

  /// 현재 모니터링 중인 영역 ID 목록을 반환한다.
  Future<List<String>> getMonitoredRegionIds();

  /// 알림 권한을 요청한다. 지오펜스 알림을 표시하려면 필요하다.
  /// 반환값: true면 권한 승인, false면 거부.
  Future<bool> requestNotificationPermission();

  /// 리소스를 정리한다.
  void dispose();
}
