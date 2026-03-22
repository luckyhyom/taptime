import 'package:taptime/features/sync/data/sync_remote_data_source.dart';

/// 테스트용 인메모리 원격 데이터 소스.
///
/// Map 구조로 Supabase 테이블을 시뮬레이션한다.
/// upsert는 같은 id가 있으면 교체, 없으면 추가한다.
/// fetchRows는 user_id 필터와 updated_at 시간 필터를 적용한다.
class FakeSyncRemoteDataSource implements SyncRemoteDataSource {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'presets': [],
    'sessions': [],
    'location_triggers': [],
  };

  String? currentUserIdOverride;

  @override
  String? get currentUserId => currentUserIdOverride;

  List<Map<String, dynamic>> _getRows(String table) {
    return _tables[table] ?? (throw ArgumentError('Unknown table: $table'));
  }

  @override
  Future<void> upsert(String table, Map<String, dynamic> json) async {
    final rows = _getRows(table);
    final id = json['id'] as String;
    final index = rows.indexWhere((r) => r['id'] == id);
    if (index >= 0) {
      rows[index] = Map.from(json);
    } else {
      rows.add(Map.from(json));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRows(
    String table,
    String userId, {
    DateTime? since,
  }) async {
    final rows = _getRows(table);
    return rows.where((row) {
      if (row['user_id'] != userId) return false;
      if (since != null) {
        final updatedAt = DateTime.parse(row['updated_at'] as String);
        if (!updatedAt.isAfter(since)) return false;
      }
      return true;
    }).toList();
  }

  // ── 테스트 헬퍼 ─────────────────────────────────────────────

  /// 특정 테이블의 모든 행을 반환한다.
  List<Map<String, dynamic>> getTable(String table) => List.from(_getRows(table));

  /// 테이블에 초기 데이터를 주입한다.
  void seedTable(String table, List<Map<String, dynamic>> rows) {
    _tables[table] = rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  /// 모든 데이터를 초기화한다.
  void clear() {
    for (final table in _tables.values) {
      table.clear();
    }
  }
}
