import 'package:taptime/shared/models/session.dart';
import 'package:taptime/shared/services/calendar_service.dart';

/// 캘린더 서비스의 NoOp(무동작) 구현.
///
/// MVP 단계에서 CalendarService의 플레이스홀더로 사용한다.
/// 모든 메서드가 아무것도 하지 않고 즉시 반환한다.
/// v1.2에서 Google Calendar 구현으로 교체될 예정.
class NoopCalendarService implements CalendarService {
  @override
  Future<void> exportSession(Session session) async {}

  @override
  Future<void> exportSessions(List<Session> sessions) async {}
}
