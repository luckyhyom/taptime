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

  /// 특정 날짜의 프리셋별 총 소요 시간(초)을 반환한다.
  ///
  /// 홈 화면에서 각 프리셋 카드의 일일 진행률을 표시할 때 사용.
  /// 반환값: Map(presetId → totalDurationSeconds)
  Future<Map<String, int>> getDailyDurationByPreset(DateTime date);

  /// 날짜 범위의 세션을 실시간으로 관찰한다.
  ///
  /// 통계 화면의 주간 데이터처럼 범위가 변하지 않지만
  /// 새 세션이 추가되면 자동 갱신이 필요한 경우에 사용.
  Stream<List<Session>> watchSessionsByDateRange(DateTime start, DateTime end);

  /// 특정 월의 세션을 실시간으로 관찰한다.
  ///
  /// 월간 통계 탭에서 사용.
  Stream<List<Session>> watchSessionsByMonth(int year, int month);

  /// 날짜 범위 내 일별 총 소요 시간(초)을 반환한다.
  ///
  /// 히트맵 캘린더에서 각 날짜의 활동 강도를 표시할 때 사용.
  /// 반환값: Map(날짜(시간 제거) → totalDurationSeconds)
  Future<Map<DateTime, int>> getDailyTotalsForRange(DateTime start, DateTime end);

  /// 특정 프리셋의 날짜 범위 내 일별 총 소요 시간(초)을 반환한다.
  ///
  /// 프리셋별 히트맵 캘린더와 스트릭 계산에 사용.
  Future<Map<DateTime, int>> getDailyTotalsForPreset(DateTime start, DateTime end, String presetId);
}
