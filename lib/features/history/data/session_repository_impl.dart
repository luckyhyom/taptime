import 'package:drift/drift.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/core/utils/enum_utils.dart';
import 'package:taptime/shared/models/session.dart';
import 'package:taptime/shared/repositories/session_repository.dart';

/// SessionRepository의 Drift(SQLite) 구현체.
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._db);

  final AppDatabase _db;

  // ── 조회 ───────────────────────────────────────────────────

  @override
  Future<List<Session>> getSessionsByDate(DateTime date) async {
    final rows = await _queryByDateRange(date.startOfDay, date.endOfDay).get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end) async {
    final rows = await _queryByDateRange(start, end).get();
    return rows.map(_toModel).toList();
  }

  @override
  Stream<List<Session>> watchSessionsByDate(DateTime date) {
    return _queryByDateRange(date.startOfDay, date.endOfDay).watch().map((rows) => rows.map(_toModel).toList());
  }

  // ── 쓰기 ───────────────────────────────────────────────────

  @override
  Future<void> createSession(Session session) async {
    await _db.into(_db.sessions).insert(_toCompanion(session));
  }

  @override
  Future<void> updateSession(Session session) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(session.id))).write(_toCompanion(session));
  }

  @override
  Future<void> deleteSession(String id) async {
    await (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteAllSessions() async {
    await _db.delete(_db.sessions).go();
  }

  @override
  Future<Map<String, int>> getDailyDurationByPreset(DateTime date) async {
    // 하루치 세션은 소량(수십 건 이하)이므로
    // SQL GROUP BY 대신 Dart에서 집계하여 가독성을 높인다.
    final sessions = await getSessionsByDate(date);
    final result = <String, int>{};
    for (final session in sessions) {
      result[session.presetId] = (result[session.presetId] ?? 0) + session.durationSeconds;
    }
    return result;
  }

  @override
  Stream<List<Session>> watchSessionsByDateRange(DateTime start, DateTime end) {
    return _queryByDateRange(start, end).watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<Session>> watchSessionsByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return _queryByDateRange(start, end).watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Map<DateTime, int>> getDailyTotalsForRange(DateTime start, DateTime end) async {
    final sessions = await getSessionsByDateRange(start, end);
    final result = <DateTime, int>{};
    for (final session in sessions) {
      final day = session.startedAt.startOfDay;
      result[day] = (result[day] ?? 0) + session.durationSeconds;
    }
    return result;
  }

  @override
  Future<Map<DateTime, int>> getDailyTotalsForPreset(DateTime start, DateTime end, String presetId) async {
    final sessions = await getSessionsByDateRange(start, end);
    final result = <DateTime, int>{};
    for (final session in sessions) {
      if (session.presetId != presetId) continue;
      final day = session.startedAt.startOfDay;
      result[day] = (result[day] ?? 0) + session.durationSeconds;
    }
    return result;
  }

  // ── 내부 헬퍼 ──────────────────────────────────────────────

  /// 날짜 범위로 세션을 조회하는 공통 쿼리 빌더.
  /// isBetweenValues()는 SQL의 BETWEEN과 같다.
  SimpleSelectStatement<$SessionsTable, SessionRow> _queryByDateRange(DateTime start, DateTime end) {
    return _db.select(_db.sessions)
      ..where((t) => t.startedAt.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
  }

  Session _toModel(SessionRow row) {
    return Session(
      id: row.id,
      presetId: row.presetId,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      durationSeconds: row.durationSeconds,
      status: safeEnumByName(SessionStatus.values, row.status) ?? SessionStatus.completed,
      memo: row.memo,
      createdAt: row.createdAt,
    );
  }

  SessionsCompanion _toCompanion(Session session) {
    return SessionsCompanion(
      id: Value(session.id),
      presetId: Value(session.presetId),
      startedAt: Value(session.startedAt),
      endedAt: Value(session.endedAt),
      durationSeconds: Value(session.durationSeconds),
      status: Value(session.status.name),
      memo: Value(session.memo),
      createdAt: Value(session.createdAt),
    );
  }
}
