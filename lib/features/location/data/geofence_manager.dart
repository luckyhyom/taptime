import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:taptime/shared/models/location_trigger.dart';
import 'package:taptime/shared/repositories/location_trigger_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/services/geofence_service.dart';

// ── 지오펜스 액션 ──────────────────────────────────────────────

/// 지오펜스 진입 시 UI에 전달되는 액션.
///
/// [autoStart]가 true이면 확인 없이 타이머를 시작하고,
/// false이면 다이얼로그로 사용자에게 확인을 요청한다.
@immutable
class GeofenceAction {
  const GeofenceAction({
    required this.presetId,
    required this.presetName,
    required this.placeName,
    required this.autoStart,
  });

  final String presetId;
  final String presetName;
  final String placeName;
  final bool autoStart;
}

// ── 지오펜스 매니저 ───────────────────────────────────────────

/// 지오펜스 오케스트레이터.
///
/// 역할:
/// 1. DB의 LocationTrigger를 네이티브 지오펜스 영역으로 등록/동기화
/// 2. 진입 이벤트 → 연결된 프리셋 조회 → UI에 액션 전달
///
/// [start]로 시작하면 watchAllTriggers 스트림을 구독하여
/// 트리거 CRUD 시 자동으로 네이티브 영역을 동기화한다.
class GeofenceManager {
  GeofenceManager({
    required GeofenceService geofenceService,
    required LocationTriggerRepository triggerRepo,
    required PresetRepository presetRepo,
  })  : _geofenceService = geofenceService,
        _triggerRepo = triggerRepo,
        _presetRepo = presetRepo;

  final GeofenceService _geofenceService;
  final LocationTriggerRepository _triggerRepo;
  final PresetRepository _presetRepo;

  StreamSubscription<List<LocationTrigger>>? _triggerSub;
  StreamSubscription<GeofenceEvent>? _eventSub;
  final _actionController = StreamController<GeofenceAction>.broadcast();

  /// UI가 구독하는 액션 스트림.
  /// 지오펜스 진입 시 연결된 프리셋 정보와 함께 액션을 emit한다.
  Stream<GeofenceAction> get actions => _actionController.stream;

  // ── 시작/중지 ──────────────────────────────────────────────

  /// 모니터링을 시작한다.
  ///
  /// 1. 기존 트리거를 모두 네이티브 영역으로 등록
  /// 2. 트리거 변경 스트림 구독 → 영역 자동 동기화
  /// 3. 지오펜스 이벤트 스트림 구독 → 액션 emit
  Future<void> start() async {
    await _geofenceService.startMonitoring();

    // 트리거 변경 시 자동으로 네이티브 영역을 동기화한다
    _triggerSub = _triggerRepo.watchAllTriggers().listen(
      _syncRegions,
      onError: (Object e) => debugPrint('[GeofenceManager] trigger stream error: $e'),
    );

    // 지오펜스 이벤트를 수신하여 프리셋과 매칭한다
    _eventSub = _geofenceService.watchEvents().listen(
      _handleEvent,
      onError: (Object e) => debugPrint('[GeofenceManager] event stream error: $e'),
    );
  }

  /// 모니터링을 중지하고 리소스를 정리한다.
  Future<void> stop() async {
    await _triggerSub?.cancel();
    _triggerSub = null;
    await _eventSub?.cancel();
    _eventSub = null;

    await _geofenceService.removeAllRegions();
    await _geofenceService.stopMonitoring();
    await _actionController.close();
  }

  // ── 영역 동기화 ─────────────────────────────────────────────

  /// DB의 트리거 목록과 네이티브 영역을 동기화한다.
  ///
  /// - DB에 없는 네이티브 영역 → 제거
  /// - DB에 있는 트리거 → 등록 (이미 존재하면 덮어씀)
  Future<void> _syncRegions(List<LocationTrigger> triggers) async {
    try {
      final monitoredIds = await _geofenceService.getMonitoredRegionIds();
      final triggerIds = triggers.map((t) => t.id).toSet();

      // DB에서 삭제된 영역을 네이티브에서도 제거
      for (final id in monitoredIds) {
        if (!triggerIds.contains(id)) {
          await _geofenceService.removeRegion(id);
        }
      }

      // 모든 트리거를 네이티브 영역으로 등록 (addRegion은 같은 id면 덮어씀)
      for (final trigger in triggers) {
        await _geofenceService.addRegion(
          id: trigger.id,
          placeName: trigger.placeName,
          latitude: trigger.latitude,
          longitude: trigger.longitude,
          radiusMeters: trigger.radiusMeters,
          notifyOnEntry: trigger.notifyOnEntry,
          notifyOnExit: trigger.notifyOnExit,
        );
      }
    } on Exception catch (e) {
      debugPrint('[GeofenceManager] region sync error: $e');
    }
  }

  // ── 이벤트 처리 ─────────────────────────────────────────────

  /// 지오펜스 진입 이벤트를 처리한다.
  ///
  /// 1. 퇴장 이벤트는 무시 (네이티브 알림만으로 충분)
  /// 2. regionId로 트리거 조회 → 연결된 프리셋 검색
  /// 3. 프리셋이 있으면 GeofenceAction을 emit
  Future<void> _handleEvent(GeofenceEvent event) async {
    // 진입 이벤트만 처리 — 퇴장 시에는 네이티브 알림만 보여준다
    if (event.type != GeofenceEventType.entered) return;
    if (_actionController.isClosed) return;

    try {
      final trigger = await _triggerRepo.getTriggerById(event.regionId);
      if (trigger == null) return;

      // 이 트리거에 연결된 프리셋을 찾는다
      // (하루치 프리셋 수는 적으므로 전체 조회 + 필터로 충분)
      final presets = await _presetRepo.getAllPresets();
      final preset = presets.where((p) => p.locationTriggerId == event.regionId).firstOrNull;
      if (preset == null) return;

      _actionController.add(GeofenceAction(
        presetId: preset.id,
        presetName: preset.name,
        placeName: trigger.placeName,
        autoStart: trigger.autoStart,
      ));
    } on Exception catch (e) {
      debugPrint('[GeofenceManager] event handling error: $e');
    }
  }
}
