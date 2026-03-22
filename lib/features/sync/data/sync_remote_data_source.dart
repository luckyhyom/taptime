/// 원격 동기화 데이터 소스 인터페이스.
///
/// Supabase의 query builder 체인을 추상화하여
/// SupabaseSyncService가 테스트 가능하도록 한다.
/// 프로덕션에서는 SupabaseRemoteDataSource가 구현한다.
abstract class SyncRemoteDataSource {
  /// 현재 인증된 사용자 ID. 미로그인 시 null.
  String? get currentUserId;

  /// 행을 원격 테이블에 upsert한다.
  Future<void> upsert(String table, Map<String, dynamic> json);

  /// 특정 사용자의 행을 가져온다.
  /// [since]가 non-null이면 해당 시각 이후에 변경된 행만 반환한다.
  Future<List<Map<String, dynamic>>> fetchRows(
    String table,
    String userId, {
    DateTime? since,
  });
}
