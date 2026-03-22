import 'package:drift/drift.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/sync_constants.dart';
import 'package:taptime/shared/models/location_trigger.dart';
import 'package:taptime/shared/repositories/location_trigger_repository.dart';

/// LocationTriggerRepository의 Drift(SQLite) 구현체.
class LocationTriggerRepositoryImpl implements LocationTriggerRepository {
  LocationTriggerRepositoryImpl(this._db);

  final AppDatabase _db;

  // ── 조회 ───────────────────────────────────────────────────

  @override
  Future<List<LocationTrigger>> getAllTriggers() async {
    final rows = await (_db.select(_db.locationTriggers)..where((t) => t.deletedAt.isNull())).get();
    return rows.map(_toModel).toList();
  }

  @override
  Stream<List<LocationTrigger>> watchAllTriggers() {
    return (_db.select(_db.locationTriggers)..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<LocationTrigger?> getTriggerById(String id) async {
    final row = await (_db.select(_db.locationTriggers)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── 쓰기 ───────────────────────────────────────────────────

  @override
  Future<void> createTrigger(LocationTrigger trigger) async {
    await _db.into(_db.locationTriggers).insert(_toCompanion(trigger));
  }

  @override
  Future<void> updateTrigger(LocationTrigger trigger) async {
    await (_db.update(_db.locationTriggers)..where((t) => t.id.equals(trigger.id))).write(_toCompanion(trigger));
  }

  @override
  Future<void> deleteTrigger(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.locationTriggers)..where((t) => t.id.equals(id))).write(
      LocationTriggersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(SyncStatusDb.pending),
      ),
    );
  }

  @override
  Future<void> deleteAllTriggers() async {
    await _db.delete(_db.locationTriggers).go();
  }

  // ── 변환 ───────────────────────────────────────────────────

  LocationTrigger _toModel(LocationTriggerRow row) {
    return LocationTrigger(
      id: row.id,
      placeName: row.placeName,
      latitude: row.latitude,
      longitude: row.longitude,
      radiusMeters: row.radiusMeters,
      notifyOnEntry: row.notifyOnEntry,
      notifyOnExit: row.notifyOnExit,
      autoStart: row.autoStart,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LocationTriggersCompanion _toCompanion(LocationTrigger trigger) {
    return LocationTriggersCompanion(
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
      syncStatus: const Value(SyncStatusDb.pending),
    );
  }
}
