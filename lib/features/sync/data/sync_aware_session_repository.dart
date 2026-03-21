import 'dart:async';

import 'package:taptime/shared/models/session.dart';
import 'package:taptime/shared/repositories/session_repository.dart';
import 'package:taptime/shared/services/sync_service.dart';

/// 동기화 트리거를 추가하는 SessionRepository 데코레이터.
///
/// 모든 쓰기 작업 후 [SyncService.syncNow]를 fire-and-forget으로 호출한다.
/// 읽기 작업은 내부 리포지토리에 그대로 위임한다.
class SyncAwareSessionRepository implements SessionRepository {
  SyncAwareSessionRepository(this._inner, this._syncService);

  final SessionRepository _inner;
  final SyncService _syncService;

  // ── 조회 (위임) ──────────────────────────────────────────

  @override
  Future<List<Session>> getSessionsByDate(DateTime date) =>
      _inner.getSessionsByDate(date);

  @override
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end) =>
      _inner.getSessionsByDateRange(start, end);

  @override
  Stream<List<Session>> watchSessionsByDate(DateTime date) =>
      _inner.watchSessionsByDate(date);

  @override
  Stream<List<Session>> watchSessionsByDateRange(DateTime start, DateTime end) =>
      _inner.watchSessionsByDateRange(start, end);

  @override
  Stream<List<Session>> watchSessionsByMonth(int year, int month) =>
      _inner.watchSessionsByMonth(year, month);

  @override
  Future<Map<String, int>> getDailyDurationByPreset(DateTime date) =>
      _inner.getDailyDurationByPreset(date);

  @override
  Future<Map<DateTime, int>> getDailyTotalsForRange(DateTime start, DateTime end) =>
      _inner.getDailyTotalsForRange(start, end);

  @override
  Future<Map<DateTime, int>> getDailyTotalsForPreset(DateTime start, DateTime end, String presetId) =>
      _inner.getDailyTotalsForPreset(start, end, presetId);

  // ── 쓰기 (위임 + 동기화 트리거) ──────────────────────────

  @override
  Future<void> createSession(Session session) async {
    await _inner.createSession(session);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> updateSession(Session session) async {
    await _inner.updateSession(session);
    unawaited(_syncService.syncNow());
  }

  @override
  Future<void> deleteSession(String id) async {
    await _inner.deleteSession(id);
    unawaited(_syncService.syncNow());
  }

  /// 데이터 초기화용 — 동기화를 트리거하지 않는다.
  @override
  Future<void> deleteAllSessions() => _inner.deleteAllSessions();
}
