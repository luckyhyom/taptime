import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/sync_constants.dart';
import 'package:taptime/features/sync/data/connectivity_monitor.dart';
import 'package:taptime/features/sync/data/supabase_mappers.dart';
import 'package:taptime/features/sync/data/sync_metadata.dart';
import 'package:taptime/features/sync/data/sync_remote_data_source.dart';
import 'package:taptime/shared/services/sync_service.dart';

/// Supabase 기반 양방향 자동 동기화 서비스.
///
/// **동기화 흐름:**
/// 1. Push: syncStatus='pending'인 로컬 행을 Supabase에 upsert
/// 2. Pull: lastPullTimestamp 이후 변경된 서버 행을 로컬에 반영
/// 3. 충돌: updatedAt 비교 — last-write-wins
///
/// **트리거:** 로그인 직후, 앱 복귀(resume), 네트워크 복원, 15분 주기
class SupabaseSyncService implements SyncService {
  SupabaseSyncService({
    required AppDatabase db,
    required SyncRemoteDataSource remoteDataSource,
    ConnectivityMonitor? connectivityMonitor,
  })  : _db = db,
        _remote = remoteDataSource,
        _connectivity = connectivityMonitor ?? ConnectivityMonitor();

  final AppDatabase _db;
  final SyncRemoteDataSource _remote;
  final ConnectivityMonitor _connectivity;

  Timer? _periodicTimer;
  StreamSubscription<bool>? _connectivitySub;
  final _statusController = StreamController<SyncStatus>.broadcast();
  bool _isSyncing = false;

  // ── SyncService 구현 ─────────────────────────────────────────

  @override
  Future<void> start() async {
    await syncNow();

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => syncNow(),
    );

    await _connectivitySub?.cancel();
    _connectivitySub = _connectivity.watchConnectivity().listen((isOnline) {
      if (isOnline) syncNow();
    });
  }

  @override
  Future<void> stop() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _setStatus(SyncStatus.idle);
    await _statusController.close();
  }

  @override
  Future<void> syncNow() async {
    if (_isSyncing) return;
    if (!await _connectivity.isOnline) return;

    _isSyncing = true;
    _setStatus(SyncStatus.syncing);

    try {
      final userId = _remote.currentUserId;
      if (userId == null) {
        _setStatus(SyncStatus.idle);
        return;
      }

      // Push → Pull 순서: 로컬 변경을 먼저 올리고 서버 변경을 받는다.
      // FK 의존 순서: location_triggers → presets → sessions
      await _pushLocationTriggers(userId);
      await _pushPresets(userId);
      await _pushSessions(userId);

      // pull 전에 timestamp를 캡처하여 양쪽 pull이 동일한 기준점을 사용하도록 한다.
      // FK 의존 순서: location_triggers 먼저 (presets가 참조하므로)
      final lastPull = await SyncMetadata.getLastPullTimestamp();
      await _pullTable('location_triggers', userId, lastPull, _mergeLocationTrigger);
      await _pullTable('presets', userId, lastPull, _mergePreset);
      await _pullTable('sessions', userId, lastPull, _mergeSession);
      await SyncMetadata.setLastPullTimestamp(DateTime.now().toUtc());

      await SyncMetadata.setLastSyncTime(DateTime.now().toUtc());
      _setStatus(SyncStatus.synced);
    } on Exception catch (e) {
      debugPrint('Sync error: $e');
      _setStatus(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _statusController.stream;

  // ── Push (로컬 → 서버) ──────────────────────────────────────

  Future<void> _pushLocationTriggers(String userId) async {
    final pendingRows = await (_db.select(_db.locationTriggers)
          ..where((t) => t.syncStatus.equals(SyncStatusDb.pending)))
        .get();

    if (pendingRows.isEmpty) return;

    for (final row in pendingRows) {
      final json = SupabaseMappers.locationTriggerRowToSupabase(row, userId);

      if (row.deletedAt != null) {
        json['deleted_at'] = row.deletedAt!.toUtc().toIso8601String();
      }

      await _remote.upsert('location_triggers', json);

      await (_db.update(_db.locationTriggers)..where((t) => t.id.equals(row.id))).write(
        LocationTriggersCompanion(
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _pushPresets(String userId) async {
    final pendingRows = await (_db.select(_db.presets)
          ..where((t) => t.syncStatus.equals(SyncStatusDb.pending)))
        .get();

    if (pendingRows.isEmpty) return;

    for (final row in pendingRows) {
      final json = SupabaseMappers.presetRowToSupabase(row, userId);

      if (row.deletedAt != null) {
        json['deleted_at'] = row.deletedAt!.toUtc().toIso8601String();
      }

      await _remote.upsert('presets', json);

      await (_db.update(_db.presets)..where((t) => t.id.equals(row.id))).write(
        PresetsCompanion(
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _pushSessions(String userId) async {
    final pendingRows = await (_db.select(_db.sessions)
          ..where((t) => t.syncStatus.equals(SyncStatusDb.pending)))
        .get();

    if (pendingRows.isEmpty) return;

    for (final row in pendingRows) {
      final json = SupabaseMappers.sessionRowToSupabase(row, userId);

      if (row.deletedAt != null) {
        json['deleted_at'] = row.deletedAt!.toUtc().toIso8601String();
      }

      await _remote.upsert('sessions', json);

      await (_db.update(_db.sessions)..where((t) => t.id.equals(row.id))).write(
        SessionsCompanion(
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ── Pull (서버 → 로컬) ──────────────────────────────────────

  /// 서버 테이블에서 변경된 행을 가져와 [merge] 콜백으로 로컬에 병합한다.
  /// [lastPull]이 null이면 초기 동기화로 전체 데이터를 가져온다.
  Future<void> _pullTable(
    String tableName,
    String userId,
    DateTime? lastPull,
    Future<void> Function(Map<String, dynamic>) merge,
  ) async {
    final rows = await _remote.fetchRows(tableName, userId, since: lastPull);

    for (final json in rows) {
      await merge(json);
    }
  }

  // ── 충돌 해결 (Last-Write-Wins) ─────────────────────────────

  /// 서버에서 받은 프리셋을 로컬에 병합한다.
  /// 로컬에 같은 id가 있으면 updatedAt을 비교하여 최신 데이터를 유지한다.
  Future<void> _mergePreset(Map<String, dynamic> serverJson) async {
    final serverId = serverJson['id'] as String;
    final serverUpdatedAt = DateTime.parse(serverJson['updated_at'] as String);
    final serverDeletedAt = serverJson['deleted_at'] as String?;

    final localRow = await (_db.select(_db.presets)
          ..where((t) => t.id.equals(serverId)))
        .getSingleOrNull();

    if (localRow == null) {
      if (serverDeletedAt != null) return;
      final preset = SupabaseMappers.presetFromSupabase(serverJson);
      await _db.into(_db.presets).insert(
            PresetsCompanion(
              id: Value(preset.id),
              name: Value(preset.name),
              durationMin: Value(preset.durationMin),
              icon: Value(preset.icon),
              color: Value(preset.color),
              dailyGoalMin: Value(preset.dailyGoalMin),
              sortOrder: Value(preset.sortOrder),
              locationTriggerId: Value(preset.locationTriggerId),
              createdAt: Value(preset.createdAt),
              updatedAt: Value(preset.updatedAt),
              syncStatus: const Value(SyncStatusDb.synced),
              lastSyncedAt: Value(DateTime.now()),
            ),
          );
      return;
    }

    if (localRow.syncStatus == SyncStatusDb.pending && localRow.updatedAt.isAfter(serverUpdatedAt)) {
      return;
    }

    if (serverDeletedAt != null) {
      await (_db.update(_db.presets)..where((t) => t.id.equals(serverId))).write(
        PresetsCompanion(
          deletedAt: Value(DateTime.parse(serverDeletedAt)),
          updatedAt: Value(serverUpdatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    } else {
      final preset = SupabaseMappers.presetFromSupabase(serverJson);
      await (_db.update(_db.presets)..where((t) => t.id.equals(serverId))).write(
        PresetsCompanion(
          name: Value(preset.name),
          durationMin: Value(preset.durationMin),
          icon: Value(preset.icon),
          color: Value(preset.color),
          dailyGoalMin: Value(preset.dailyGoalMin),
          sortOrder: Value(preset.sortOrder),
          locationTriggerId: Value(preset.locationTriggerId),
          updatedAt: Value(preset.updatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// 서버에서 받은 세션을 로컬에 병합한다.
  Future<void> _mergeSession(Map<String, dynamic> serverJson) async {
    final serverId = serverJson['id'] as String;
    final serverUpdatedAt = DateTime.parse(serverJson['updated_at'] as String);
    final serverDeletedAt = serverJson['deleted_at'] as String?;

    final localRow = await (_db.select(_db.sessions)
          ..where((t) => t.id.equals(serverId)))
        .getSingleOrNull();

    if (localRow == null) {
      if (serverDeletedAt != null) return;
      final session = SupabaseMappers.sessionFromSupabase(serverJson);
      await _db.into(_db.sessions).insert(
            SessionsCompanion(
              id: Value(session.id),
              presetId: Value(session.presetId),
              startedAt: Value(session.startedAt),
              endedAt: Value(session.endedAt),
              durationSeconds: Value(session.durationSeconds),
              status: Value(session.status.name),
              memo: Value(session.memo),
              createdAt: Value(session.createdAt),
              updatedAt: Value(session.updatedAt),
              syncStatus: const Value(SyncStatusDb.synced),
              lastSyncedAt: Value(DateTime.now()),
            ),
          );
      return;
    }

    if (localRow.syncStatus == SyncStatusDb.pending && localRow.updatedAt.isAfter(serverUpdatedAt)) {
      return;
    }

    if (serverDeletedAt != null) {
      await (_db.update(_db.sessions)..where((t) => t.id.equals(serverId))).write(
        SessionsCompanion(
          deletedAt: Value(DateTime.parse(serverDeletedAt)),
          updatedAt: Value(serverUpdatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    } else {
      final session = SupabaseMappers.sessionFromSupabase(serverJson);
      await (_db.update(_db.sessions)..where((t) => t.id.equals(serverId))).write(
        SessionsCompanion(
          presetId: Value(session.presetId),
          startedAt: Value(session.startedAt),
          endedAt: Value(session.endedAt),
          durationSeconds: Value(session.durationSeconds),
          status: Value(session.status.name),
          memo: Value(session.memo),
          updatedAt: Value(session.updatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// 서버에서 받은 위치 트리거를 로컬에 병합한다.
  Future<void> _mergeLocationTrigger(Map<String, dynamic> serverJson) async {
    final serverId = serverJson['id'] as String;
    final serverUpdatedAt = DateTime.parse(serverJson['updated_at'] as String);
    final serverDeletedAt = serverJson['deleted_at'] as String?;

    final localRow = await (_db.select(_db.locationTriggers)
          ..where((t) => t.id.equals(serverId)))
        .getSingleOrNull();

    if (localRow == null) {
      if (serverDeletedAt != null) return;
      final trigger = SupabaseMappers.locationTriggerFromSupabase(serverJson);
      await _db.into(_db.locationTriggers).insert(
            LocationTriggersCompanion(
              id: Value(trigger.id),
              placeName: Value(trigger.placeName),
              latitude: Value(trigger.latitude),
              longitude: Value(trigger.longitude),
              radiusMeters: Value(trigger.radiusMeters),
              notifyOnEntry: Value(trigger.notifyOnEntry),
              notifyOnExit: Value(trigger.notifyOnExit),
              autoStart: Value(trigger.autoStart),
              createdAt: Value(trigger.createdAt),
              updatedAt: Value(trigger.updatedAt),
              syncStatus: const Value(SyncStatusDb.synced),
              lastSyncedAt: Value(DateTime.now()),
            ),
          );
      return;
    }

    if (localRow.syncStatus == SyncStatusDb.pending && localRow.updatedAt.isAfter(serverUpdatedAt)) {
      return;
    }

    if (serverDeletedAt != null) {
      await (_db.update(_db.locationTriggers)..where((t) => t.id.equals(serverId))).write(
        LocationTriggersCompanion(
          deletedAt: Value(DateTime.parse(serverDeletedAt)),
          updatedAt: Value(serverUpdatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    } else {
      final trigger = SupabaseMappers.locationTriggerFromSupabase(serverJson);
      await (_db.update(_db.locationTriggers)..where((t) => t.id.equals(serverId))).write(
        LocationTriggersCompanion(
          placeName: Value(trigger.placeName),
          latitude: Value(trigger.latitude),
          longitude: Value(trigger.longitude),
          radiusMeters: Value(trigger.radiusMeters),
          notifyOnEntry: Value(trigger.notifyOnEntry),
          notifyOnExit: Value(trigger.notifyOnExit),
          autoStart: Value(trigger.autoStart),
          updatedAt: Value(trigger.updatedAt),
          syncStatus: const Value(SyncStatusDb.synced),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ── 유틸리티 ────────────────────────────────────────────────

  void _setStatus(SyncStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}
