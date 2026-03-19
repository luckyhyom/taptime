import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/shared/models/preset.dart';

void main() {
  final now = DateTime(2026, 3, 19);

  Preset makePreset({
    String name = 'Study',
    int durationMin = 25,
    int dailyGoalMin = 0,
  }) {
    return Preset(
      id: 'test-id',
      name: name,
      durationMin: durationMin,
      icon: 'menu_book',
      color: '#4A90D9',
      dailyGoalMin: dailyGoalMin,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Preset 생성', () {
    test('유효한 값으로 생성된다', () {
      final preset = makePreset();
      expect(preset.name, 'Study');
      expect(preset.durationMin, 25);
    });

    test('durationMin이 1 미만이면 실패한다', () {
      expect(() => makePreset(durationMin: 0), throwsA(isA<AssertionError>()));
    });

    test('durationMin이 180 초과이면 실패한다', () {
      expect(() => makePreset(durationMin: 181), throwsA(isA<AssertionError>()));
    });

    test('durationMin 경계값 1과 180은 허용된다', () {
      expect(makePreset(durationMin: 1).durationMin, 1);
      expect(makePreset(durationMin: 180).durationMin, 180);
    });

    test('name이 빈 문자열이면 실패한다', () {
      expect(() => makePreset(name: ''), throwsA(isA<AssertionError>()));
    });

    test('name이 20자를 초과하면 실패한다', () {
      expect(() => makePreset(name: 'a' * 21), throwsA(isA<AssertionError>()));
    });

    test('name 경계값 1자와 20자는 허용된다', () {
      expect(makePreset(name: 'A').name, 'A');
      expect(makePreset(name: 'a' * 20).name.length, 20);
    });

    test('dailyGoalMin이 음수이면 실패한다', () {
      expect(() => makePreset(dailyGoalMin: -1), throwsA(isA<AssertionError>()));
    });

    test('dailyGoalMin 0은 허용된다 (목표 없음)', () {
      expect(makePreset().dailyGoalMin, 0);
    });
  });

  group('Preset.toMap / fromMap', () {
    test('toMap → fromMap 왕복 변환이 일치한다', () {
      final original = makePreset();
      final restored = Preset.fromMap(original.toMap());
      expect(restored, original);
      expect(restored.name, original.name);
      expect(restored.durationMin, original.durationMin);
    });

    test('fromMap이 DateTime 객체를 직접 받을 수 있다', () {
      final preset = Preset.fromMap({
        'id': 'test',
        'name': 'Test',
        'durationMin': 25,
        'icon': 'timer',
        'color': '#FF0000',
        'dailyGoalMin': 0,
        'sortOrder': 0,
        'createdAt': now,
        'updatedAt': now,
      });
      expect(preset.createdAt, now);
    });

    test('fromMap이 ISO 8601 문자열을 파싱한다', () {
      final preset = Preset.fromMap({
        'id': 'test',
        'name': 'Test',
        'durationMin': 25,
        'icon': 'timer',
        'color': '#FF0000',
        'dailyGoalMin': 0,
        'sortOrder': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      expect(preset.createdAt, now);
    });
  });

  group('Preset 동등성', () {
    test('같은 id면 동등하다', () {
      final a = makePreset(name: 'A');
      final b = makePreset(name: 'B');
      expect(a, b);
    });

    test('다른 id면 동등하지 않다', () {
      final a = makePreset();
      final b = Preset(
        id: 'other-id',
        name: 'Study',
        durationMin: 25,
        icon: 'menu_book',
        color: '#4A90D9',
        dailyGoalMin: 0,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, isNot(b));
    });
  });
}
