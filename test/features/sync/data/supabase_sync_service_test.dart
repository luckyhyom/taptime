import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/sync_constants.dart';
import 'package:taptime/features/sync/data/supabase_sync_service.dart';
import 'package:taptime/shared/services/sync_service.dart';

import '../../../mocks/fake_sync_remote_data_source.dart';
import '../../../mocks/mock_repositories.dart';

void main() {
  late AppDatabase db;
  late FakeSyncRemoteDataSource remote;
  late MockConnectivityMonitor connectivity;
  late SupabaseSyncService syncService;

  const testUserId = 'user-123';
  final now = DateTime.utc(2026, 3, 22, 10, 0, 0);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeSyncRemoteDataSource()..currentUserIdOverride = testUserId;
    connectivity = MockConnectivityMonitor();

    when(() => connectivity.isOnline).thenAnswer((_) async => true);
    when(() => connectivity.watchConnectivity()).thenAnswer((_) => const Stream.empty());

    SharedPreferences.setMockInitialValues({});

    syncService = SupabaseSyncService(
      db: db,
      remoteDataSource: remote,
      connectivityMonitor: connectivity,
    );
  });

  tearDown(() async {
    await syncService.stop();
    await db.close();
  });

  // ── 헬퍼 ─────────────────────────────────────────────────────

  Future<void> insertLocalPreset({
    String id = 'p1',
    String name = 'Study',
    String syncStatus = SyncStatusDb.pending,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) async {
    await db.into(db.presets).insert(PresetsCompanion(
          id: Value(id),
          name: Value(name),
          durationMin: const Value(25),
          icon: const Value('menu_book'),
          color: const Value('#4A90D9'),
          dailyGoalMin: const Value(0),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(updatedAt ?? now),
          deletedAt: Value(deletedAt),
          syncStatus: Value(syncStatus),
        ));
  }

  // FK 제약: 프리셋이 먼저 존재해야 한다.
  Future<void> insertLocalSession({
    String id = 's1',
    String presetId = 'p1',
    String syncStatus = SyncStatusDb.pending,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) async {
    await db.into(db.sessions).insert(SessionsCompanion(
          id: Value(id),
          presetId: Value(presetId),
          startedAt: Value(now),
          endedAt: Value(now.add(const Duration(minutes: 25))),
          durationSeconds: const Value(1500),
          status: const Value('completed'),
          createdAt: Value(now),
          updatedAt: Value(updatedAt ?? now),
          deletedAt: Value(deletedAt),
          syncStatus: Value(syncStatus),
        ));
  }

  Map<String, dynamic> makeServerPreset({
    String id = 'p1',
    String name = 'Study',
    DateTime? updatedAt,
    String? deletedAt,
  }) {
    return {
      'id': id,
      'user_id': testUserId,
      'name': name,
      'duration_min': 25,
      'icon': 'menu_book',
      'color': '#4A90D9',
      'daily_goal_min': 0,
      'sort_order': 0,
      'created_at': now.toIso8601String(),
      'updated_at': (updatedAt ?? now).toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt,
    };
  }

  Map<String, dynamic> makeServerSession({
    String id = 's1',
    String presetId = 'p1',
    DateTime? updatedAt,
    String? deletedAt,
  }) {
    return {
      'id': id,
      'user_id': testUserId,
      'preset_id': presetId,
      'started_at': now.toIso8601String(),
      'ended_at': now.add(const Duration(minutes: 25)).toIso8601String(),
      'duration_seconds': 1500,
      'status': 'completed',
      'memo': null,
      'created_at': now.toIso8601String(),
      'updated_at': (updatedAt ?? now).toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt,
    };
  }

  // deletedAt 포함 조회 (soft delete된 행도 반환)
  Future<PresetRow?> getLocalPreset(String id) async {
    return await (db.select(db.presets)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<SessionRow?> getLocalSession(String id) async {
    return await (db.select(db.sessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ── Push 흐름 ────────────────────────────────────────────────

  group('Push 흐름', () {
    test('syncStatus=pending인 프리셋을 서버에 upsert한다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.pending);

      await syncService.syncNow();

      final serverPresets = remote.getTable('presets');
      expect(serverPresets, hasLength(1));
      expect(serverPresets.first['id'], 'p1');
      expect(serverPresets.first['user_id'], 'user-123');
    });

    test('push 후 로컬 syncStatus를 synced로 변경한다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.pending);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row!.syncStatus, SyncStatusDb.synced);
    });

    test('push 후 lastSyncedAt을 설정한다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.pending);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row!.lastSyncedAt, isNotNull);
    });

    test('syncStatus=synced인 행은 push하지 않는다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.synced);

      await syncService.syncNow();

      final serverPresets = remote.getTable('presets');
      expect(serverPresets, isEmpty);
    });

    test('deletedAt이 non-null인 행의 deleted_at을 포함한다', () async {
      final deletedTime = now.add(const Duration(hours: 1));
      await insertLocalPreset(
        syncStatus: SyncStatusDb.pending,
        deletedAt: deletedTime,
      );

      await syncService.syncNow();

      final serverPresets = remote.getTable('presets');
      expect(serverPresets.first['deleted_at'], isNotNull);
    });

    test('세션 push도 동일한 패턴으로 동작한다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.synced);
      await insertLocalSession(syncStatus: SyncStatusDb.pending);

      await syncService.syncNow();

      final serverSessions = remote.getTable('sessions');
      expect(serverSessions, hasLength(1));
      expect(serverSessions.first['preset_id'], 'p1');

      final row = await getLocalSession('s1');
      expect(row!.syncStatus, SyncStatusDb.synced);
    });

    test('빈 pending 목록이면 upsert를 호출하지 않는다', () async {
      await syncService.syncNow();

      expect(remote.getTable('presets'), isEmpty);
      expect(remote.getTable('sessions'), isEmpty);
    });
  });

  // ── Pull 흐름 ────────────────────────────────────────────────

  group('Pull 흐름', () {
    test('서버의 새 프리셋을 로컬에 삽입한다', () async {
      remote.seedTable('presets', [makeServerPreset()]);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row, isNotNull);
      expect(row!.name, 'Study');
      expect(row.syncStatus, SyncStatusDb.synced);
    });

    test('서버의 새 세션을 로컬에 삽입한다', () async {
      // 세션 FK를 위해 프리셋도 함께 시드
      remote.seedTable('presets', [makeServerPreset()]);
      remote.seedTable('sessions', [makeServerSession()]);

      await syncService.syncNow();

      final presetRow = await getLocalPreset('p1');
      expect(presetRow, isNotNull);

      final sessionRow = await getLocalSession('s1');
      expect(sessionRow, isNotNull);
      expect(sessionRow!.syncStatus, SyncStatusDb.synced);
    });

    test('서버에서 삭제된 프리셋(deletedAt non-null)은 삽입하지 않는다', () async {
      remote.seedTable('presets', [
        makeServerPreset(deletedAt: now.toIso8601String()),
      ]);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row, isNull);
    });

    test('lastPull이 설정되면 이후 변경분만 가져온다', () async {
      // 첫 번째 동기화: 서버에 p1 시드
      remote.seedTable('presets', [makeServerPreset(id: 'p1')]);
      await syncService.syncNow();

      // 서버에 p2 추가 (p1보다 이후 시각)
      final later = DateTime.now().toUtc().add(const Duration(seconds: 1));
      remote.seedTable('presets', [
        makeServerPreset(id: 'p1'), // 기존
        makeServerPreset(id: 'p2', name: 'Exercise', updatedAt: later), // 신규
      ]);

      await syncService.syncNow();

      // p2만 새로 삽입되어야 한다
      final p2 = await getLocalPreset('p2');
      expect(p2, isNotNull);
      expect(p2!.name, 'Exercise');
    });
  });

  // ── 충돌 해결 — 프리셋 ──────────────────────────────────────

  group('충돌 해결 — 프리셋', () {
    test('로컬이 synced면 서버 데이터로 덮어쓴다', () async {
      await insertLocalPreset(
        name: 'Old Name',
        syncStatus: SyncStatusDb.synced,
        updatedAt: now,
      );

      final serverUpdated = now.add(const Duration(hours: 1));
      remote.seedTable('presets', [
        makeServerPreset(name: 'New Name', updatedAt: serverUpdated),
      ]);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row!.name, 'New Name');
    });

    test('로컬이 pending이고 서버보다 최신이면 로컬을 유지한다', () async {
      final localUpdated = now.add(const Duration(hours: 2));
      await insertLocalPreset(
        name: 'Local Edit',
        syncStatus: SyncStatusDb.pending,
        updatedAt: localUpdated,
      );

      final serverUpdated = now.add(const Duration(hours: 1));
      remote.seedTable('presets', [
        makeServerPreset(name: 'Server Edit', updatedAt: serverUpdated),
      ]);

      await syncService.syncNow();

      // push에서 로컬이 서버에 올라가고, pull에서 서버 데이터가 무시된다
      final row = await getLocalPreset('p1');
      expect(row!.name, 'Local Edit');
    });

    test('로컬이 pending이면 push가 서버를 덮어쓰고 로컬이 유지된다', () async {
      // push-then-pull 아키텍처에서 pending 행은 항상 먼저 서버에 push된다.
      // 서버에 더 최신 데이터가 있어도 push가 덮어쓰므로 pull에서 로컬 데이터가 돌아온다.
      final localUpdated = now.add(const Duration(hours: 1));
      await insertLocalPreset(
        name: 'Local Edit',
        syncStatus: SyncStatusDb.pending,
        updatedAt: localUpdated,
      );

      final serverUpdated = now.add(const Duration(hours: 3));
      remote.seedTable('presets', [
        makeServerPreset(name: 'Server Edit', updatedAt: serverUpdated),
      ]);

      await syncService.syncNow();

      // push가 서버를 덮어쓰므로 로컬 데이터가 유지된다
      final row = await getLocalPreset('p1');
      expect(row!.name, 'Local Edit');
      expect(row.syncStatus, SyncStatusDb.synced);
    });

    test('서버가 삭제(deletedAt)된 행을 로컬에도 반영한다', () async {
      await insertLocalPreset(syncStatus: SyncStatusDb.synced);

      remote.seedTable('presets', [
        makeServerPreset(
          updatedAt: now.add(const Duration(hours: 1)),
          deletedAt: now.add(const Duration(hours: 1)).toIso8601String(),
        ),
      ]);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row!.deletedAt, isNotNull);
    });
  });

  // ── 충돌 해결 — 세션 ────────────────────────────────────────

  group('충돌 해결 — 세션', () {
    setUp(() async {
      // FK를 위해 프리셋을 먼저 삽입
      await insertLocalPreset(syncStatus: SyncStatusDb.synced);
    });

    test('로컬이 synced면 서버 데이터로 덮어쓴다', () async {
      await insertLocalSession(syncStatus: SyncStatusDb.synced);

      final serverUpdated = now.add(const Duration(hours: 1));
      remote.seedTable('sessions', [
        makeServerSession(updatedAt: serverUpdated),
      ]);

      await syncService.syncNow();

      final row = await getLocalSession('s1');
      expect(row!.syncStatus, SyncStatusDb.synced);
      expect(row.updatedAt.isAfter(now), isTrue);
    });

    test('로컬이 pending이고 서버보다 최신이면 로컬을 유지한다', () async {
      final localUpdated = now.add(const Duration(hours: 2));
      await insertLocalSession(
        syncStatus: SyncStatusDb.pending,
        updatedAt: localUpdated,
      );

      final serverUpdated = now.add(const Duration(hours: 1));
      remote.seedTable('sessions', [
        makeServerSession(updatedAt: serverUpdated),
      ]);

      await syncService.syncNow();

      final row = await getLocalSession('s1');
      // push에서 로컬이 올라가므로 synced 상태
      // Drift는 DateTime을 epoch millis로 저장하여 로컬 시간대로 반환하므로
      // isAtSameMomentAs로 비교한다.
      expect(row!.updatedAt.isAtSameMomentAs(localUpdated), isTrue);
    });

    test('서버가 삭제(deletedAt)된 행을 로컬에도 반영한다', () async {
      await insertLocalSession(syncStatus: SyncStatusDb.synced);

      remote.seedTable('sessions', [
        makeServerSession(
          updatedAt: now.add(const Duration(hours: 1)),
          deletedAt: now.add(const Duration(hours: 1)).toIso8601String(),
        ),
      ]);

      await syncService.syncNow();

      final row = await getLocalSession('s1');
      expect(row!.deletedAt, isNotNull);
    });
  });

  // ── 소프트 삭제 전파 ─────────────────────────────────────────

  group('소프트 삭제 전파', () {
    test('로컬 소프트 삭제가 push 시 서버에 전파된다', () async {
      final deletedTime = now.add(const Duration(hours: 1));
      await insertLocalPreset(
        syncStatus: SyncStatusDb.pending,
        deletedAt: deletedTime,
      );

      await syncService.syncNow();

      final serverPresets = remote.getTable('presets');
      expect(serverPresets.first['deleted_at'], isNotNull);
    });

    test('이미 삭제된 서버 행은 새 로컬 삽입을 생성하지 않는다', () async {
      remote.seedTable('presets', [
        makeServerPreset(deletedAt: now.toIso8601String()),
      ]);

      await syncService.syncNow();

      final row = await getLocalPreset('p1');
      expect(row, isNull);
    });
  });

  // ── 가드 ─────────────────────────────────────────────────────

  group('가드', () {
    test('오프라인 상태에서 syncNow는 아무것도 하지 않는다', () async {
      when(() => connectivity.isOnline).thenAnswer((_) async => false);
      await insertLocalPreset(syncStatus: SyncStatusDb.pending);

      await syncService.syncNow();

      expect(remote.getTable('presets'), isEmpty);
    });

    test('userId가 null이면 idle 상태를 설정하고 반환한다', () async {
      remote.currentUserIdOverride = null;
      await insertLocalPreset(syncStatus: SyncStatusDb.pending);

      final statuses = <SyncStatus>[];
      syncService.watchSyncStatus().listen(statuses.add);

      await syncService.syncNow();
      await Future.delayed(Duration.zero);

      expect(statuses, contains(SyncStatus.idle));
      expect(remote.getTable('presets'), isEmpty);
    });
  });

  // ── 상태 관리 ────────────────────────────────────────────────

  group('상태 관리', () {
    test('syncNow 성공 시 syncing → synced 순서로 상태를 emit한다', () async {
      final statuses = <SyncStatus>[];
      syncService.watchSyncStatus().listen(statuses.add);

      await syncService.syncNow();
      await Future.delayed(Duration.zero);

      expect(statuses, contains(SyncStatus.syncing));
      expect(statuses.last, SyncStatus.synced);
    });

    test('syncNow 실패 시 error 상태를 emit한다', () async {
      // remote를 에러를 던지는 mock으로 교체
      final errorRemote = MockSyncRemoteDataSource();
      when(() => errorRemote.currentUserId).thenReturn('user-123');
      when(() => errorRemote.fetchRows(any(), any(), since: any(named: 'since')))
          .thenThrow(Exception('network error'));

      final errorSyncService = SupabaseSyncService(
        db: db,
        remoteDataSource: errorRemote,
        connectivityMonitor: connectivity,
      );

      final statuses = <SyncStatus>[];
      errorSyncService.watchSyncStatus().listen(statuses.add);

      await errorSyncService.syncNow();
      await Future.delayed(Duration.zero);

      expect(statuses, contains(SyncStatus.error));

      await errorSyncService.stop();
    });
  });

  // ── Push → Pull 통합 시나리오 ────────────────────────────────

  group('Push → Pull 통합 시나리오', () {
    test('로컬 변경 push 후 서버 변경 pull이 하나의 syncNow에서 실행된다', () async {
      // 로컬에 pending 프리셋
      await insertLocalPreset(id: 'p-local', name: 'Local', syncStatus: SyncStatusDb.pending);

      // 서버에 다른 프리셋
      remote.seedTable('presets', [
        makeServerPreset(id: 'p-server', name: 'Server'),
      ]);

      await syncService.syncNow();

      // 로컬 프리셋이 서버에 push됨
      final serverPresets = remote.getTable('presets');
      expect(serverPresets.any((p) => p['id'] == 'p-local'), isTrue);

      // 서버 프리셋이 로컬에 pull됨
      final pullRow = await getLocalPreset('p-server');
      expect(pullRow, isNotNull);
      expect(pullRow!.name, 'Server');
    });
  });
}
