import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taptime/core/database/tables.dart';

// Drift 코드 제너레이터가 이 파일을 기반으로 app_database.g.dart를 생성한다.
// part 지시문은 생성된 코드를 이 파일의 일부로 포함시킨다.
part 'app_database.g.dart';

/// 앱의 메인 데이터베이스.
///
/// Drift가 _$AppDatabase 클래스를 자동 생성하며,
/// 이를 상속하여 실제 사용하는 AppDatabase를 만든다.
///
/// 생성자에 QueryExecutor를 받을 수 있도록 설계하여,
/// 테스트 시 인메모리 DB를 주입할 수 있다.
/// 예: AppDatabase(NativeDatabase.memory())
@DriftDatabase(tables: [Presets, Sessions, UserSettingsTable, ActiveTimers, LocationTriggers])
class AppDatabase extends _$AppDatabase {
  /// [executor]를 지정하지 않으면 기본 SQLite 파일 연결을 사용한다.
  /// 테스트에서는 NativeDatabase.memory()를 전달하여
  /// 파일 없이 메모리에서 동작하는 DB를 사용할 수 있다.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// 스키마 버전 — 테이블 구조를 변경할 때마다 이 값을 올린다.
  /// Drift가 이전 버전과 비교하여 마이그레이션을 실행한다.
  @override
  int get schemaVersion => 3;

  /// SQLite 파일 연결을 생성한다.
  ///
  /// driftDatabase()는 drift_flutter 패키지가 제공하는 헬퍼로,
  /// 플랫폼별 SQLite 바이너리 번들링과 백그라운드 isolate를
  /// 자동으로 처리한다.
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'taptime',
      native: const DriftNativeOptions(
        // 앱의 지원 디렉토리에 DB 파일을 저장한다.
        // iOS: ~/Library/Application Support/
        // Android: /data/data/<package>/files/
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  /// SQLite 외래키 제약조건을 활성화한다.
  ///
  /// SQLite는 기본적으로 외래키를 검사하지 않는다.
  /// 이 설정이 없으면 Sessions의 presetId가 존재하지 않는
  /// Preset을 참조해도 에러가 발생하지 않는다.
  /// 마이그레이션 전략.
  ///
  /// - onCreate: 처음 DB를 생성할 때 모든 테이블을 만든다.
  /// - onUpgrade: schemaVersion이 올라갈 때 스키마를 변경한다.
  ///   새 버전이 추가되면 `if (from < N)` 블록을 추가한다.
  /// - beforeOpen: 매 연결 시 외래키 제약조건을 활성화한다.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // 동기화를 위한 컬럼 추가.
        // Sessions: updatedAt, deletedAt, syncStatus, lastSyncedAt
        await m.addColumn(sessions, sessions.updatedAt);
        await m.addColumn(sessions, sessions.deletedAt);
        await m.addColumn(sessions, sessions.syncStatus);
        await m.addColumn(sessions, sessions.lastSyncedAt);
        // Presets: deletedAt, syncStatus, lastSyncedAt
        await m.addColumn(presets, presets.deletedAt);
        await m.addColumn(presets, presets.syncStatus);
        await m.addColumn(presets, presets.lastSyncedAt);
        // 기존 세션의 updatedAt을 createdAt 값으로 채운다.
        await customStatement('UPDATE sessions SET updated_at = created_at WHERE updated_at IS NULL');
      }
      if (from < 3) {
        // v2.1: 위치 기반 자동 트래킹
        await m.createTable(locationTriggers);
        await m.addColumn(presets, presets.locationTriggerId);
        await m.addColumn(userSettingsTable, userSettingsTable.locationTrackingEnabled);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
