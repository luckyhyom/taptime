import 'package:taptime/shared/models/active_timer.dart';

/// 활성 타이머 데이터 접근 인터페이스.
///
/// 현재 실행 중인 타이머의 상태를 저장하고 복구하는 역할.
/// 단일행 패턴으로 동작하므로 항상 0개 또는 1개의 타이머만 존재한다.
abstract class ActiveTimerRepository {
  /// 현재 활성 타이머를 가져온다.
  /// 실행 중인 타이머가 없으면 null을 반환한다.
  Future<ActiveTimer?> getActiveTimer();

  /// 현재 활성 타이머를 실시간으로 관찰한다.
  /// 타이머 상태가 변경될 때마다 새 값을 emit한다.
  Stream<ActiveTimer?> watchActiveTimer();

  /// 활성 타이머 상태를 저장한다.
  /// 이미 존재하면 덮어쓰고, 없으면 새로 생성한다.
  Future<void> saveActiveTimer(ActiveTimer timer);

  /// 활성 타이머를 삭제한다.
  /// 타이머가 완료되거나 취소될 때 호출한다.
  Future<void> deleteActiveTimer();
}
