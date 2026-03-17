import 'package:drift/drift.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/shared/models/active_timer.dart';
import 'package:taptime/shared/repositories/active_timer_repository.dart';

/// ActiveTimerRepository의 Drift(SQLite) 구현체.
///
/// INSERT OR REPLACE 전략으로 단일행 패턴을 유지한다.
/// id가 항상 'singleton'이므로 기존 행이 있으면 덮어쓴다.
class ActiveTimerRepositoryImpl implements ActiveTimerRepository {
  ActiveTimerRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ActiveTimer?> getActiveTimer() async {
    final row = await (_db.select(
      _db.activeTimers,
    )..where((t) => t.id.equals(ActiveTimer.singletonId))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Stream<ActiveTimer?> watchActiveTimer() {
    return (_db.select(_db.activeTimers)..where((t) => t.id.equals(ActiveTimer.singletonId))).watchSingleOrNull().map(
      (row) => row == null ? null : _toModel(row),
    );
  }

  @override
  Future<void> saveActiveTimer(ActiveTimer timer) async {
    // insertOnConflictUpdate: PK 충돌 시 기존 행을 업데이트한다.
    // 단일행 패턴에서 save(upsert) 동작을 구현한다.
    await _db.into(_db.activeTimers).insertOnConflictUpdate(_toCompanion(timer));
  }

  @override
  Future<void> deleteActiveTimer() async {
    await (_db.delete(_db.activeTimers)..where((t) => t.id.equals(ActiveTimer.singletonId))).go();
  }

  // ── 변환 ───────────────────────────────────────────────────

  ActiveTimer _toModel(ActiveTimerRow row) {
    return ActiveTimer(
      id: row.id,
      presetId: row.presetId,
      startedAt: row.startedAt,
      pausedDurationSeconds: row.pausedDurationSeconds,
      isPaused: row.isPaused,
      pausedAt: row.pausedAt,
      remainingSeconds: row.remainingSeconds,
      createdAt: row.createdAt,
    );
  }

  ActiveTimersCompanion _toCompanion(ActiveTimer timer) {
    return ActiveTimersCompanion(
      id: Value(timer.id),
      presetId: Value(timer.presetId),
      startedAt: Value(timer.startedAt),
      pausedDurationSeconds: Value(timer.pausedDurationSeconds),
      isPaused: Value(timer.isPaused),
      pausedAt: Value(timer.pausedAt),
      remainingSeconds: Value(timer.remainingSeconds),
      createdAt: Value(timer.createdAt),
    );
  }
}
