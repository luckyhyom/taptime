import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:taptime/features/sync/data/sync_remote_data_source.dart';

/// Supabase 기반 [SyncRemoteDataSource] 구현체.
///
/// [SupabaseClient]의 query builder 체인을 캡슐화하여
/// 동기화 서비스가 직접 Supabase SDK에 의존하지 않도록 한다.
class SupabaseRemoteDataSource implements SyncRemoteDataSource {
  SupabaseRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<void> upsert(String table, Map<String, dynamic> json) async {
    await _client.from(table).upsert(json);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRows(
    String table,
    String userId, {
    DateTime? since,
  }) async {
    var query = _client.from(table).select().eq('user_id', userId);

    if (since != null) {
      query = query.gt('updated_at', since.toIso8601String());
    }

    return await query;
  }
}
