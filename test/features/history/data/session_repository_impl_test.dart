import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/features/history/data/session_repository_impl.dart';
import 'package:taptime/features/preset/data/preset_repository_impl.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';

void main() {
  late AppDatabase db;
  late SessionRepositoryImpl sessionRepo;
  late PresetRepositoryImpl presetRepo;

  final today = DateTime(2026, 3, 19);
  final todayStart = DateTime(2026, 3, 19, 10);
  final todayEnd = DateTime(2026, 3, 19, 10, 25);
  final yesterday = DateTime(2026, 3, 18, 15);
  final yesterdayEnd = DateTime(2026, 3, 18, 15, 30);

  // 세션은 프리셋에 외래키로 연결되므로 프리셋을 먼저 만들어야 한다.
  final testPreset = Preset(
    id: 'preset-1',
    name: 'Study',
    durationMin: 25,
    icon: 'menu_book',
    color: '#4A90D9',
    dailyGoalMin: 120,
    sortOrder: 0,
    createdAt: today,
    updatedAt: today,
  );

  final testPreset2 = Preset(
    id: 'preset-2',
    name: 'Exercise',
    durationMin: 30,
    icon: 'fitness_center',
    color: '#6DB56D',
    dailyGoalMin: 60,
    sortOrder: 1,
    createdAt: today,
    updatedAt: today,
  );

  Session makeSession({
    String id = 's1',
    String presetId = 'preset-1',
    DateTime? startedAt,
    DateTime? endedAt,
    int durationSeconds = 1500,
    SessionStatus status = SessionStatus.completed,
  }) {
    return Session(
      id: id,
      presetId: presetId,
      startedAt: startedAt ?? todayStart,
      endedAt: endedAt ?? todayEnd,
      durationSeconds: durationSeconds,
      status: status,
      createdAt: startedAt ?? todayStart,
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sessionRepo = SessionRepositoryImpl(db);
    presetRepo = PresetRepositoryImpl(db);
    // 외래키 참조를 위한 프리셋 생성
    await presetRepo.createPreset(testPreset);
    await presetRepo.createPreset(testPreset2);
  });

  tearDown(() => db.close());

  group('CRUD', () {
    test('createSession 후 getSessionsByDate로 조회된다', () async {
      await sessionRepo.createSession(makeSession());
      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions, hasLength(1));
      expect(sessions.first.presetId, 'preset-1');
    });

    test('updateSession으로 메모를 추가한다', () async {
      await sessionRepo.createSession(makeSession());
      final updated = makeSession().copyWith(memo: 'focused well');
      await sessionRepo.updateSession(updated);
      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions.first.memo, 'focused well');
    });

    test('deleteSession으로 삭제한다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.deleteSession('s1');
      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions, isEmpty);
    });

    test('deleteAllSessions로 전체 삭제한다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.createSession(makeSession(id: 's2'));
      await sessionRepo.deleteAllSessions();
      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions, isEmpty);
    });
  });

  group('날짜 범위 조회', () {
    test('getSessionsByDate는 해당 날짜의 세션만 반환한다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.createSession(
        makeSession(id: 's2', startedAt: yesterday, endedAt: yesterdayEnd),
      );
      final todaySessions = await sessionRepo.getSessionsByDate(today);
      expect(todaySessions, hasLength(1));
      expect(todaySessions.first.id, 's1');
    });

    test('getSessionsByDateRange는 범위 내 세션을 반환한다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.createSession(
        makeSession(id: 's2', startedAt: yesterday, endedAt: yesterdayEnd),
      );
      final sessions = await sessionRepo.getSessionsByDateRange(
        DateTime(2026, 3, 18),
        DateTime(2026, 3, 19, 23, 59, 59),
      );
      expect(sessions, hasLength(2));
    });
  });

  group('프리셋별 일일 집계', () {
    test('getDailyDurationByPreset이 프리셋별 총 시간을 반환한다', () async {
      await sessionRepo.createSession(
        makeSession(durationSeconds: 600),
      );
      await sessionRepo.createSession(
        makeSession(id: 's2', durationSeconds: 900),
      );
      await sessionRepo.createSession(
        makeSession(id: 's3', presetId: 'preset-2', durationSeconds: 300),
      );
      final result = await sessionRepo.getDailyDurationByPreset(today);
      expect(result['preset-1'], 1500);
      expect(result['preset-2'], 300);
    });

    test('세션이 없는 날은 빈 맵을 반환한다', () async {
      final result = await sessionRepo.getDailyDurationByPreset(today);
      expect(result, isEmpty);
    });
  });

  group('월별 조회', () {
    test('watchSessionsByMonth는 해당 월의 세션만 스트림으로 반환한다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.createSession(
        makeSession(id: 's2', startedAt: yesterday, endedAt: yesterdayEnd),
      );
      // 다른 달 세션
      await sessionRepo.createSession(
        makeSession(
          id: 's3',
          startedAt: DateTime(2026, 2, 15, 10),
          endedAt: DateTime(2026, 2, 15, 10, 25),
        ),
      );

      final sessions = await sessionRepo.watchSessionsByMonth(2026, 3).first;
      expect(sessions, hasLength(2));
    });
  });

  group('일별 총 시간 집계', () {
    test('getDailyTotalsForRange는 날짜별 총 시간을 반환한다', () async {
      await sessionRepo.createSession(makeSession(durationSeconds: 600));
      await sessionRepo.createSession(makeSession(id: 's2', durationSeconds: 900));
      await sessionRepo.createSession(
        makeSession(id: 's3', startedAt: yesterday, endedAt: yesterdayEnd, durationSeconds: 300),
      );

      final result = await sessionRepo.getDailyTotalsForRange(
        DateTime(2026, 3, 18),
        DateTime(2026, 3, 19, 23, 59, 59),
      );

      expect(result[DateTime(2026, 3, 19)], 1500); // 600 + 900
      expect(result[DateTime(2026, 3, 18)], 300);
    });

    test('세션이 없는 범위는 빈 맵을 반환한다', () async {
      final result = await sessionRepo.getDailyTotalsForRange(
        DateTime(2026),
        DateTime(2026, 1, 31, 23, 59, 59),
      );
      expect(result, isEmpty);
    });

    test('getDailyTotalsForPreset은 해당 프리셋의 시간만 반환한다', () async {
      await sessionRepo.createSession(makeSession(durationSeconds: 600));
      await sessionRepo.createSession(makeSession(id: 's2', presetId: 'preset-2', durationSeconds: 300));
      await sessionRepo.createSession(
        makeSession(id: 's3', startedAt: yesterday, endedAt: yesterdayEnd, durationSeconds: 400),
      );

      final result = await sessionRepo.getDailyTotalsForPreset(
        DateTime(2026, 3, 18),
        DateTime(2026, 3, 19, 23, 59, 59),
        'preset-1',
      );

      expect(result[DateTime(2026, 3, 19)], 600); // preset-1만
      expect(result[DateTime(2026, 3, 18)], 400);
      expect(result.containsKey(DateTime(2026, 3, 20)), isFalse);
    });
  });

  group('cascade 삭제', () {
    test('프리셋 삭제 시 관련 세션도 함께 삭제된다', () async {
      await sessionRepo.createSession(makeSession());
      await sessionRepo.createSession(makeSession(id: 's2', presetId: 'preset-2'));

      // preset-1 삭제 → s1도 삭제됨
      await presetRepo.deletePreset('preset-1');

      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions, hasLength(1));
      expect(sessions.first.presetId, 'preset-2');
    });
  });

  group('안전한 enum 파싱', () {
    test('잘못된 status 문자열이 DB에 있을 때 completed로 fallback한다', () async {
      // DB에 직접 잘못된 status를 삽입한다
      await db.customInsert(
        'INSERT INTO sessions (id, preset_id, started_at, ended_at, duration_seconds, status, created_at, updated_at) '
        "VALUES ('bad', 'preset-1', ${todayStart.millisecondsSinceEpoch ~/ 1000}, "
        "${todayEnd.millisecondsSinceEpoch ~/ 1000}, 1500, 'invalid_status', "
        '${todayStart.millisecondsSinceEpoch ~/ 1000}, '
        '${todayStart.millisecondsSinceEpoch ~/ 1000})',
      );

      final sessions = await sessionRepo.getSessionsByDate(today);
      expect(sessions, hasLength(1));
      expect(sessions.first.status, SessionStatus.completed);
    });
  });
}
