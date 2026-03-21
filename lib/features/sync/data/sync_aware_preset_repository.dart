import 'dart:async';

import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/services/sync_service.dart';

/// 동기화 트리거를 추가하는 PresetRepository 데코레이터.
///
/// 모든 쓰기 작업 후 [SyncService.syncNow]를 fire-and-forget으로 호출한다.
/// 읽기 작업은 내부 리포지토리에 그대로 위임한다.
class SyncAwarePresetRepository implements PresetRepository {
  SyncAwarePresetRepository(this._inner, this._syncService);

  final PresetRepository _inner;
  final SyncService _syncService;

  // ── 조회 (위임) ──────────────────────────────────────────

  @override
  Future<List<Preset>> getAllPresets() => _inner.getAllPresets();

  @override
  Stream<List<Preset>> watchAllPresets() => _inner.watchAllPresets();

  @override
  Future<Preset?> getPresetById(String id) => _inner.getPresetById(id);

  // ── 쓰기 (위임 + 동기화 트리거) ──────────────────────────

  @override
  Future<void> createPreset(Preset preset) async {
    await _inner.createPreset(preset);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    await _inner.updatePreset(preset);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> deletePreset(String id) async {
    await _inner.deletePreset(id);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> updateSortOrder(Map<String, int> idToSortOrder) async {
    await _inner.updateSortOrder(idToSortOrder);
    unawaited(_syncService.syncNow());
  }

  /// 데이터 초기화용 — 동기화를 트리거하지 않는다.
  @override
  Future<void> deleteAllPresets() => _inner.deleteAllPresets();
}
