import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/features/sync/data/supabase_mappers.dart';
import 'package:taptime/shared/models/session.dart';

void main() {
  final now = DateTime.utc(2026, 3, 22, 10, 0, 0);

  // ── Preset ──────────────────────────────────────────────────

  group('presetRowToSupabase', () {
    final row = PresetRow(
      id: 'p1',
      name: 'Study',
      durationMin: 25,
      icon: 'menu_book',
      color: '#4A90D9',
      dailyGoalMin: 120,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    test('PresetRow를 snake_case JSON으로 변환한다', () {
      final json = SupabaseMappers.presetRowToSupabase(row, 'user-123');

      expect(json['id'], 'p1');
      expect(json['user_id'], 'user-123');
      expect(json['name'], 'Study');
      expect(json['duration_min'], 25);
      expect(json['icon'], 'menu_book');
      expect(json['color'], '#4A90D9');
      expect(json['daily_goal_min'], 120);
      expect(json['sort_order'], 0);
    });

    test('DateTime을 UTC ISO 8601 문자열로 변환한다', () {
      final json = SupabaseMappers.presetRowToSupabase(row, 'user-123');

      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('syncStatus와 deletedAt은 포함하지 않는다', () {
      final json = SupabaseMappers.presetRowToSupabase(row, 'user-123');

      expect(json.containsKey('sync_status'), isFalse);
      expect(json.containsKey('deleted_at'), isFalse);
    });
  });

  group('presetFromSupabase', () {
    test('snake_case JSON을 Preset 모델로 변환한다', () {
      final json = {
        'id': 'p1',
        'name': 'Study',
        'duration_min': 25,
        'icon': 'menu_book',
        'color': '#4A90D9',
        'daily_goal_min': 120,
        'sort_order': 0,
        'created_at': '2026-03-22T10:00:00.000Z',
        'updated_at': '2026-03-22T10:00:00.000Z',
      };

      final preset = SupabaseMappers.presetFromSupabase(json);

      expect(preset.id, 'p1');
      expect(preset.name, 'Study');
      expect(preset.durationMin, 25);
      expect(preset.icon, 'menu_book');
      expect(preset.color, '#4A90D9');
      expect(preset.dailyGoalMin, 120);
      expect(preset.sortOrder, 0);
      expect(preset.createdAt, now);
      expect(preset.updatedAt, now);
    });
  });

  // ── Session ─────────────────────────────────────────────────

  group('sessionRowToSupabase', () {
    final row = SessionRow(
      id: 's1',
      presetId: 'p1',
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 25)),
      durationSeconds: 1500,
      status: 'completed',
      memo: '집중 잘됨',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    test('SessionRow를 snake_case JSON으로 변환한다', () {
      final json = SupabaseMappers.sessionRowToSupabase(row, 'user-123');

      expect(json['id'], 's1');
      expect(json['user_id'], 'user-123');
      expect(json['preset_id'], 'p1');
      expect(json['duration_seconds'], 1500);
      expect(json['status'], 'completed');
      expect(json['memo'], '집중 잘됨');
    });

    test('nullable memo가 null인 경우 null을 포함한다', () {
      final rowNoMemo = SessionRow(
        id: 's2',
        presetId: 'p1',
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 25)),
        durationSeconds: 1500,
        status: 'completed',
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      final json = SupabaseMappers.sessionRowToSupabase(rowNoMemo, 'user-123');
      expect(json['memo'], isNull);
    });
  });

  group('sessionFromSupabase', () {
    test('snake_case JSON을 Session 모델로 변환한다', () {
      final json = {
        'id': 's1',
        'preset_id': 'p1',
        'started_at': '2026-03-22T10:00:00.000Z',
        'ended_at': '2026-03-22T10:25:00.000Z',
        'duration_seconds': 1500,
        'status': 'completed',
        'memo': '집중 잘됨',
        'created_at': '2026-03-22T10:00:00.000Z',
        'updated_at': '2026-03-22T10:25:00.000Z',
      };

      final session = SupabaseMappers.sessionFromSupabase(json);

      expect(session.id, 's1');
      expect(session.presetId, 'p1');
      expect(session.durationSeconds, 1500);
      expect(session.status, SessionStatus.completed);
      expect(session.memo, '집중 잘됨');
    });

    test('잘못된 status 문자열에 대해 completed로 fallback한다', () {
      final json = {
        'id': 's1',
        'preset_id': 'p1',
        'started_at': '2026-03-22T10:00:00.000Z',
        'ended_at': '2026-03-22T10:25:00.000Z',
        'duration_seconds': 1500,
        'status': 'invalid_status',
        'memo': null,
        'created_at': '2026-03-22T10:00:00.000Z',
        'updated_at': '2026-03-22T10:25:00.000Z',
      };

      final session = SupabaseMappers.sessionFromSupabase(json);
      expect(session.status, SessionStatus.completed);
    });

    test('null status에 대해 completed로 fallback한다', () {
      final json = {
        'id': 's1',
        'preset_id': 'p1',
        'started_at': '2026-03-22T10:00:00.000Z',
        'ended_at': '2026-03-22T10:25:00.000Z',
        'duration_seconds': 1500,
        'status': null,
        'memo': null,
        'created_at': '2026-03-22T10:00:00.000Z',
        'updated_at': '2026-03-22T10:25:00.000Z',
      };

      final session = SupabaseMappers.sessionFromSupabase(json);
      expect(session.status, SessionStatus.completed);
    });

    test('stopped status를 올바르게 파싱한다', () {
      final json = {
        'id': 's1',
        'preset_id': 'p1',
        'started_at': '2026-03-22T10:00:00.000Z',
        'ended_at': '2026-03-22T10:10:00.000Z',
        'duration_seconds': 600,
        'status': 'stopped',
        'memo': null,
        'created_at': '2026-03-22T10:00:00.000Z',
        'updated_at': '2026-03-22T10:10:00.000Z',
      };

      final session = SupabaseMappers.sessionFromSupabase(json);
      expect(session.status, SessionStatus.stopped);
    });
  });
}
