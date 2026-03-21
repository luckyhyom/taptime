import 'package:shared_preferences/shared_preferences.dart';

/// 동기화 메타데이터 — 마지막 pull 시각을 SharedPreferences에 저장한다.
///
/// pull 시 "마지막 동기화 이후 변경된 데이터만" 가져오기 위해
/// lastPullTimestamp를 기록한다.
class SyncMetadata {
  static const _keyLastPull = 'sync_last_pull';
  static const _keyLastSync = 'sync_last_completed';

  /// 마지막으로 서버에서 데이터를 pull한 시각을 가져온다.
  /// 한 번도 pull하지 않았으면 null.
  static Future<DateTime?> getLastPullTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyLastPull);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  /// 마지막 pull 시각을 저장한다.
  static Future<void> setLastPullTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastPull, timestamp.toUtc().millisecondsSinceEpoch);
  }

  /// 마지막으로 동기화가 성공적으로 완료된 시각을 가져온다.
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyLastSync);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) : null;
  }

  /// 마지막 동기화 완료 시각을 저장한다.
  static Future<void> setLastSyncTime(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSync, timestamp.toUtc().millisecondsSinceEpoch);
  }

  /// 동기화 메타데이터를 모두 초기화한다 (로그아웃 시).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastPull);
    await prefs.remove(_keyLastSync);
  }
}
