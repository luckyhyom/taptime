import 'package:drift/drift.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/shared/models/user_settings.dart';
import 'package:taptime/shared/repositories/user_settings_repository.dart';

/// UserSettingsRepository의 Drift(SQLite) 구현체.
///
/// 단일행 패턴: DB에 항상 하나의 설정 행(id=1)만 존재한다.
/// 조회 시 행이 없으면 기본값을 반환하고,
/// 저장 시 insertOrReplace로 있으면 덮어쓰기, 없으면 새로 생성한다.
class UserSettingsRepositoryImpl implements UserSettingsRepository {
  UserSettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<UserSettings> getSettings() async {
    final row = await _db.select(_db.userSettingsTable).getSingleOrNull();
    return row == null ? UserSettings.defaults() : _toModel(row);
  }

  @override
  Stream<UserSettings> watchSettings() {
    // 테이블에 행이 없을 수도 있으므로 watch()로 리스트를 받고,
    // 비어 있으면 기본값을 emit한다.
    return _db
        .select(_db.userSettingsTable)
        .watch()
        .map((rows) => rows.isEmpty ? UserSettings.defaults() : _toModel(rows.first));
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    // insertOnConflictUpdate: 행이 있으면 UPDATE, 없으면 INSERT.
    // 단일행 패턴이므로 id=1로 고정한다.
    await _db
        .into(_db.userSettingsTable)
        .insertOnConflictUpdate(
          UserSettingsTableCompanion(
            id: const Value(1),
            themeMode: Value(settings.themeMode.name),
            soundEnabled: Value(settings.soundEnabled),
            vibrationEnabled: Value(settings.vibrationEnabled),
          ),
        );
  }

  // ── 변환 ───────────────────────────────────────────────────

  UserSettings _toModel(UserSettingsRow row) {
    return UserSettings.fromMap({
      'themeMode': row.themeMode,
      'soundEnabled': row.soundEnabled,
      'vibrationEnabled': row.vibrationEnabled,
    });
  }
}
