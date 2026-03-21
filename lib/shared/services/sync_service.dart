/// 동기화 서비스 인터페이스.
///
/// 로컬 Drift DB와 Supabase 간 양방향 자동 동기화를 추상화한다.
/// 로그인 시 start(), 로그아웃 시 stop()을 호출한다.
abstract class SyncService {
  /// 동기화를 시작한다.
  ///
  /// Realtime 구독, 주기적 full-sync, 연결 상태 감시를 시작한다.
  /// 이미 실행 중이면 무시한다.
  Future<void> start();

  /// 동기화를 중단한다.
  ///
  /// Realtime 구독, 타이머, 연결 감시를 모두 해제한다.
  Future<void> stop();

  /// 즉시 동기화를 실행한다.
  ///
  /// pending 상태인 로컬 변경을 push하고,
  /// 마지막 pull 이후 변경된 서버 데이터를 pull한다.
  Future<void> syncNow();

  /// 현재 동기화 상태를 실시간으로 관찰한다.
  Stream<SyncStatus> watchSyncStatus();
}

/// 동기화 상태.
enum SyncStatus {
  /// 동기화 미시작 (로그아웃 상태)
  idle,

  /// 동기화 진행 중
  syncing,

  /// 동기화 완료, 최신 상태
  synced,

  /// 동기화 실패 (네트워크 오류 등)
  error,
}
