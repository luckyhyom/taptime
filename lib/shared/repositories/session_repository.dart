import 'package:taptime/shared/models/session.dart';

/// 세션(타이머 기록) 데이터 접근 인터페이스.
abstract class SessionRepository {
  /// 특정 날짜의 세션 목록을 가져온다.
  Future<List<Session>> getSessionsByDate(DateTime date);

  /// 날짜 범위의 세션 목록을 가져온다 (주간 통계 등에 사용).
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end);

  /// 특정 날짜의 세션을 실시간으로 관찰한다.
  Stream<List<Session>> watchSessionsByDate(DateTime date);

  /// 새 세션을 저장한다.
  Future<void> createSession(Session session);

  /// 세션을 수정한다 (메모 추가 등).
  Future<void> updateSession(Session session);

  /// 세션을 삭제한다.
  Future<void> deleteSession(String id);

  /// 모든 세션을 삭제한다 (설정 > 데이터 초기화에 사용).
  Future<void> deleteAllSessions();
}
