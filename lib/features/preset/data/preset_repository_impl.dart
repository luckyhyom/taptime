import 'package:drift/drift.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/sync_constants.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';

/// PresetRepository의 Drift(SQLite) 구현체.
///
/// DB의 행 객체(PresetRow)와 앱의 모델 객체(Preset)를
/// 서로 변환하는 역할도 함께 담당한다.
/// UI 레이어는 이 클래스를 직접 사용하지 않고,
/// Riverpod 프로바이더를 통해 PresetRepository 인터페이스로 접근한다.
class PresetRepositoryImpl implements PresetRepository {
  PresetRepositoryImpl(this._db);

  final AppDatabase _db;

  // ── 조회 ───────────────────────────────────────────────────

  @override
  Future<List<Preset>> getAllPresets() async {
    // Drift의 select()는 SQL SELECT를 타입 안전하게 빌드한다.
    // orderBy로 정렬 순서를 지정하고, get()으로 실행한다.
    final rows = await (_db.select(_db.presets)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Stream<List<Preset>> watchAllPresets() {
    // watch()는 get()과 같은 쿼리를 Stream으로 반환한다.
    // DB에 변경이 생기면 자동으로 새 결과를 emit한다.
    return (_db.select(_db.presets)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Preset?> getPresetById(String id) async {
    final row = await (_db.select(_db.presets)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── 쓰기 ───────────────────────────────────────────────────

  @override
  Future<void> createPreset(Preset preset) async {
    await _db.into(_db.presets).insert(_toCompanion(preset));
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    await (_db.update(_db.presets)..where((t) => t.id.equals(preset.id))).write(_toCompanion(preset));
  }

  @override
  Future<void> deletePreset(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.presets)..where((t) => t.id.equals(id))).write(
      PresetsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(SyncStatusDb.pending),
      ),
    );
  }

  @override
  Future<void> deleteAllPresets() async {
    await _db.delete(_db.presets).go();
  }

  @override
  Future<void> updateSortOrder(Map<String, int> idToSortOrder) async {
    // 여러 행을 한번에 업데이트할 때는 batch를 사용한다.
    // 개별 update를 반복하는 것보다 성능이 좋다.
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final entry in idToSortOrder.entries) {
        batch.update(
          _db.presets,
          PresetsCompanion(
            sortOrder: Value(entry.value),
            updatedAt: Value(now),
            syncStatus: const Value(SyncStatusDb.pending),
          ),
          where: ($PresetsTable t) => t.id.equals(entry.key),
        );
      }
    });
  }

  // ── 변환 ───────────────────────────────────────────────────
  // DB 행(PresetRow) ↔ 앱 모델(Preset) 변환 메서드.
  // 이 변환 덕분에 UI 레이어는 Drift를 전혀 알 필요가 없다.

  Preset _toModel(PresetRow row) {
    return Preset(
      id: row.id,
      name: row.name,
      durationMin: row.durationMin,
      icon: row.icon,
      color: row.color,
      dailyGoalMin: row.dailyGoalMin,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      locationTriggerId: row.locationTriggerId,
    );
  }

  // PresetsCompanion은 Drift가 생성하는 "부분 업데이트용" 클래스이다.
  // Value<T>로 감싸면 해당 필드를 업데이트하고,
  // Value.absent()이면 해당 필드를 건드리지 않는다.
  PresetsCompanion _toCompanion(Preset preset) {
    return PresetsCompanion(
      id: Value(preset.id),
      name: Value(preset.name),
      durationMin: Value(preset.durationMin),
      icon: Value(preset.icon),
      color: Value(preset.color),
      dailyGoalMin: Value(preset.dailyGoalMin),
      sortOrder: Value(preset.sortOrder),
      createdAt: Value(preset.createdAt),
      updatedAt: Value(preset.updatedAt),
      locationTriggerId: Value(preset.locationTriggerId),
      syncStatus: const Value(SyncStatusDb.pending),
    );
  }
}
