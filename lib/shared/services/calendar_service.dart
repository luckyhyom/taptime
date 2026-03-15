import 'package:taptime/shared/models/session.dart';

/// 캘린더 연동 서비스 인터페이스.
///
/// MVP에서는 NoOp 구현(아무것도 하지 않는 더미)을 사용하고,
/// v1.2에서 Google Calendar 구현으로 교체할 예정이다.
/// 인터페이스를 미리 정의해두면 나중에 구현체만 바꾸면 된다.
abstract class CalendarService {
  /// 단일 세션을 캘린더에 내보낸다.
  Future<void> exportSession(Session session);

  /// 여러 세션을 캘린더에 일괄 내보낸다.
  Future<void> exportSessions(List<Session> sessions);
}
