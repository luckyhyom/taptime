/// 동기화 상태 DB 값 상수.
///
/// Drift `TextColumn`과 비교/저장 시 사용하여 오타를 방지한다.
abstract final class SyncStatusDb {
  static const pending = 'pending';
  static const synced = 'synced';
}
