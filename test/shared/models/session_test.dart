import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/shared/models/session.dart';

void main() {
  final start = DateTime(2026, 3, 19, 10);
  final end = DateTime(2026, 3, 19, 10, 25);

  Session makeSession({
    DateTime? startedAt,
    DateTime? endedAt,
    int durationSeconds = 1500,
    SessionStatus status = SessionStatus.completed,
    String? memo,
  }) {
    return Session(
      id: 'test-id',
      presetId: 'preset-1',
      startedAt: startedAt ?? start,
      endedAt: endedAt ?? end,
      durationSeconds: durationSeconds,
      status: status,
      memo: memo,
      createdAt: start,
    );
  }

  group('Session 생성', () {
    test('유효한 값으로 생성된다', () {
      final session = makeSession();
      expect(session.durationSeconds, 1500);
      expect(session.status, SessionStatus.completed);
    });

    test('durationSeconds가 음수이면 실패한다', () {
      expect(() => makeSession(durationSeconds: -1), throwsA(isA<AssertionError>()));
    });

    test('durationSeconds 0은 허용된다', () {
      expect(makeSession(durationSeconds: 0).durationSeconds, 0);
    });

    test('endedAt이 startedAt보다 이전이면 실패한다', () {
      expect(
        () => makeSession(
          startedAt: end,
          endedAt: start,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('endedAt과 startedAt이 같으면 허용된다', () {
      final session = makeSession(startedAt: start, endedAt: start);
      expect(session.startedAt, session.endedAt);
    });
  });

  group('Session.toMap / fromMap', () {
    test('toMap → fromMap 왕복 변환이 일치한다', () {
      final original = makeSession(memo: 'good focus');
      final restored = Session.fromMap(original.toMap());
      expect(restored, original);
      expect(restored.memo, 'good focus');
      expect(restored.status, SessionStatus.completed);
    });

    test('fromMap이 DateTime 객체를 직접 받을 수 있다', () {
      final session = Session.fromMap({
        'id': 'test',
        'presetId': 'p1',
        'startedAt': start,
        'endedAt': end,
        'durationSeconds': 1500,
        'status': 'completed',
        'memo': null,
        'createdAt': start,
      });
      expect(session.startedAt, start);
    });

    test('fromMap이 잘못된 status 문자열에 대해 completed로 fallback한다', () {
      final session = Session.fromMap({
        'id': 'test',
        'presetId': 'p1',
        'startedAt': start,
        'endedAt': end,
        'durationSeconds': 1500,
        'status': 'invalid_status',
        'memo': null,
        'createdAt': start,
      });
      expect(session.status, SessionStatus.completed);
    });

    test('memo가 null인 경우도 정상 처리된다', () {
      final session = makeSession();
      final map = session.toMap();
      expect(map['memo'], isNull);

      final restored = Session.fromMap(map);
      expect(restored.memo, isNull);
    });
  });

  group('Session.clearMemo', () {
    test('메모를 null로 설정한다', () {
      final session = makeSession(memo: 'some memo');
      final cleared = session.clearMemo();
      expect(cleared.memo, isNull);
      expect(cleared.id, session.id);
    });
  });
}
