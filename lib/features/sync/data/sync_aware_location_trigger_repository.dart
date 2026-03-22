import 'dart:async';

import 'package:taptime/shared/models/location_trigger.dart';
import 'package:taptime/shared/repositories/location_trigger_repository.dart';
import 'package:taptime/shared/services/sync_service.dart';

/// 동기화 트리거를 추가하는 LocationTriggerRepository 데코레이터.
///
/// 모든 쓰기 작업 후 [SyncService.syncNow]를 fire-and-forget으로 호출한다.
class SyncAwareLocationTriggerRepository implements LocationTriggerRepository {
  SyncAwareLocationTriggerRepository(this._inner, this._syncService);

  final LocationTriggerRepository _inner;
  final SyncService _syncService;

  // ── 조회 (위임) ──────────────────────────────────────────

  @override
  Future<List<LocationTrigger>> getAllTriggers() => _inner.getAllTriggers();

  @override
  Stream<List<LocationTrigger>> watchAllTriggers() => _inner.watchAllTriggers();

  @override
  Future<LocationTrigger?> getTriggerById(String id) => _inner.getTriggerById(id);

  // ── 쓰기 (위임 + 동기화 트리거) ──────────────────────────

  @override
  Future<void> createTrigger(LocationTrigger trigger) async {
    await _inner.createTrigger(trigger);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> updateTrigger(LocationTrigger trigger) async {
    await _inner.updateTrigger(trigger);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> deleteTrigger(String id) async {
    await _inner.deleteTrigger(id);
    unawaited(_syncService.syncNow());
  }

  /// 데이터 초기화용 — 동기화를 트리거하지 않는다.
  @override
  Future<void> deleteAllTriggers() => _inner.deleteAllTriggers();
}
