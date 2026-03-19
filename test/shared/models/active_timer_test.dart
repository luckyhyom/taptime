import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/shared/models/active_timer.dart';

void main() {
  final now = DateTime(2026, 3, 19, 10);

  ActiveTimer makeTimer({
    bool isPaused = false,
    DateTime? pausedAt,
    int remainingSeconds = 1500,
    int pausedDurationSeconds = 0,
  }) {
    return ActiveTimer(
      id: ActiveTimer.singletonId,
      presetId: 'preset-1',
      startedAt: now,
      pausedDurationSeconds: pausedDurationSeconds,
      isPaused: isPaused,
      pausedAt: pausedAt,
      remainingSeconds: remainingSeconds,
      createdAt: now,
    );
  }

  group('ActiveTimer 생성', () {
    test('유효한 running 상태로 생성된다', () {
      final timer = makeTimer();
      expect(timer.isPaused, false);
      expect(timer.pausedAt, isNull);
      expect(timer.remainingSeconds, 1500);
    });

    test('유효한 paused 상태로 생성된다', () {
      final timer = makeTimer(isPaused: true, pausedAt: now);
      expect(timer.isPaused, true);
      expect(timer.pausedAt, now);
    });

    test('remainingSeconds가 음수이면 실패한다', () {
      expect(() => makeTimer(remainingSeconds: -1), throwsA(isA<AssertionError>()));
    });

    test('remainingSeconds 0은 허용된다 (타이머 완료 직전)', () {
      expect(makeTimer(remainingSeconds: 0).remainingSeconds, 0);
    });

    test('pausedDurationSeconds가 음수이면 실패한다', () {
      expect(() => makeTimer(pausedDurationSeconds: -1), throwsA(isA<AssertionError>()));
    });

    test('isPaused=true인데 pausedAt이 null이면 실패한다', () {
      expect(
        () => makeTimer(isPaused: true),
        throwsA(isA<AssertionError>()),
      );
    });

    test('isPaused=false인데 pausedAt이 있으면 허용된다 (resume 직전 상태)', () {
      // isPaused=false + pausedAt != null은 논리적으로 가능한 중간 상태
      final timer = makeTimer(pausedAt: now);
      expect(timer.isPaused, false);
      expect(timer.pausedAt, now);
    });
  });

  group('ActiveTimer.toMap / fromMap', () {
    test('toMap → fromMap 왕복 변환이 일치한다 (running)', () {
      final original = makeTimer();
      final restored = ActiveTimer.fromMap(original.toMap());
      expect(restored, original);
      expect(restored.isPaused, false);
      expect(restored.pausedAt, isNull);
    });

    test('toMap → fromMap 왕복 변환이 일치한다 (paused)', () {
      final original = makeTimer(isPaused: true, pausedAt: now, pausedDurationSeconds: 60);
      final restored = ActiveTimer.fromMap(original.toMap());
      expect(restored, original);
      expect(restored.isPaused, true);
      expect(restored.pausedAt, now);
      expect(restored.pausedDurationSeconds, 60);
    });

    test('fromMap이 DateTime 객체를 직접 받을 수 있다', () {
      final timer = ActiveTimer.fromMap({
        'id': ActiveTimer.singletonId,
        'presetId': 'p1',
        'startedAt': now,
        'pausedDurationSeconds': 0,
        'isPaused': false,
        'pausedAt': null,
        'remainingSeconds': 1500,
        'createdAt': now,
      });
      expect(timer.startedAt, now);
    });
  });

  group('ActiveTimer.clearPausedAt', () {
    test('pausedAt를 null로 설정한다', () {
      final timer = makeTimer(pausedAt: now);
      final cleared = timer.clearPausedAt();
      expect(cleared.pausedAt, isNull);
      expect(cleared.presetId, timer.presetId);
    });
  });
}
