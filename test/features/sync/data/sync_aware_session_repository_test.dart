import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taptime/features/sync/data/sync_aware_session_repository.dart';
import 'package:taptime/shared/models/session.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late MockSessionRepository mockInner;
  late MockSyncService mockSyncService;
  late SyncAwareSessionRepository repo;

  final now = DateTime(2026, 3, 22, 10, 0);
  final session = Session(
    id: 's1',
    presetId: 'p1',
    startedAt: now,
    endedAt: now.add(const Duration(minutes: 25)),
    durationSeconds: 1500,
    status: SessionStatus.completed,
    createdAt: now,
  );

  setUp(() {
    mockInner = MockSessionRepository();
    mockSyncService = MockSyncService();
    repo = SyncAwareSessionRepository(mockInner, mockSyncService);

    when(() => mockSyncService.syncNow()).thenAnswer((_) async {});
  });

  group('읽기 작업 위임', () {
    test('getSessionsByDate를 내부 리포지토리에 위임한다', () async {
      when(() => mockInner.getSessionsByDate(now)).thenAnswer((_) async => [session]);

      final result = await repo.getSessionsByDate(now);

      expect(result, [session]);
      verifyNever(() => mockSyncService.syncNow());
    });

    test('getSessionsByDateRange를 내부 리포지토리에 위임한다', () async {
      final end = now.add(const Duration(days: 7));
      when(() => mockInner.getSessionsByDateRange(now, end)).thenAnswer((_) async => [session]);

      final result = await repo.getSessionsByDateRange(now, end);

      expect(result, [session]);
      verifyNever(() => mockSyncService.syncNow());
    });

    test('getDailyDurationByPreset를 내부 리포지토리에 위임한다', () async {
      when(() => mockInner.getDailyDurationByPreset(now)).thenAnswer((_) async => {'p1': 1500});

      final result = await repo.getDailyDurationByPreset(now);

      expect(result, {'p1': 1500});
      verifyNever(() => mockSyncService.syncNow());
    });

    test('getDailyTotalsForRange를 내부 리포지토리에 위임한다', () async {
      final end = now.add(const Duration(days: 7));
      when(() => mockInner.getDailyTotalsForRange(now, end)).thenAnswer((_) async => {});

      await repo.getDailyTotalsForRange(now, end);
      verifyNever(() => mockSyncService.syncNow());
    });

    test('getDailyTotalsForPreset를 내부 리포지토리에 위임한다', () async {
      final end = now.add(const Duration(days: 7));
      when(() => mockInner.getDailyTotalsForPreset(now, end, 'p1')).thenAnswer((_) async => {});

      await repo.getDailyTotalsForPreset(now, end, 'p1');
      verifyNever(() => mockSyncService.syncNow());
    });
  });

  group('쓰기 작업 + 동기화 트리거', () {
    test('createSession 후 syncNow를 호출한다', () async {
      when(() => mockInner.createSession(session)).thenAnswer((_) async {});

      await repo.createSession(session);

      verify(() => mockInner.createSession(session)).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('updateSession 후 syncNow를 호출한다', () async {
      when(() => mockInner.updateSession(session)).thenAnswer((_) async {});

      await repo.updateSession(session);

      verify(() => mockInner.updateSession(session)).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('deleteSession 후 syncNow를 호출한다', () async {
      when(() => mockInner.deleteSession('s1')).thenAnswer((_) async {});

      await repo.deleteSession('s1');

      verify(() => mockInner.deleteSession('s1')).called(1);
      verify(() => mockSyncService.syncNow()).called(1);
    });

    test('deleteAllSessions은 syncNow를 호출하지 않는다', () async {
      when(() => mockInner.deleteAllSessions()).thenAnswer((_) async {});

      await repo.deleteAllSessions();

      verify(() => mockInner.deleteAllSessions()).called(1);
      verifyNever(() => mockSyncService.syncNow());
    });
  });
}
