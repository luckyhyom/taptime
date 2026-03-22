import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/utils/enum_utils.dart';
import 'package:taptime/shared/models/location_trigger.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';

/// Dart 모델/Drift Row ↔ Supabase JSON 변환.
///
/// Dart는 camelCase, Supabase(PostgreSQL)는 snake_case를 사용하므로
/// 키 이름을 변환하고, DateTime을 ISO 8601 문자열로 직렬화한다.
class SupabaseMappers {
  SupabaseMappers._();

  // ── Preset ──────────────────────────────────────────────────

  /// Drift PresetRow → Supabase UPSERT용 snake_case JSON.
  /// 중간에 Preset 모델을 생성하지 않고 Row에서 직접 변환한다.
  static Map<String, dynamic> presetRowToSupabase(PresetRow row, String userId) {
    return {
      'id': row.id,
      'user_id': userId,
      'name': row.name,
      'duration_min': row.durationMin,
      'icon': row.icon,
      'color': row.color,
      'daily_goal_min': row.dailyGoalMin,
      'sort_order': row.sortOrder,
      'created_at': row.createdAt.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
      'location_trigger_id': row.locationTriggerId,
    };
  }

  /// Supabase snake_case JSON → Preset.
  static Preset presetFromSupabase(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      durationMin: json['duration_min'] as int,
      icon: json['icon'] as String,
      color: json['color'] as String,
      dailyGoalMin: json['daily_goal_min'] as int,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      locationTriggerId: json['location_trigger_id'] as String?,
    );
  }

  // ── Session ─────────────────────────────────────────────────

  /// Drift SessionRow → Supabase UPSERT용 snake_case JSON.
  static Map<String, dynamic> sessionRowToSupabase(SessionRow row, String userId) {
    return {
      'id': row.id,
      'user_id': userId,
      'preset_id': row.presetId,
      'started_at': row.startedAt.toUtc().toIso8601String(),
      'ended_at': row.endedAt.toUtc().toIso8601String(),
      'duration_seconds': row.durationSeconds,
      'status': row.status,
      'memo': row.memo,
      'created_at': row.createdAt.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Supabase snake_case JSON → Session.
  static Session sessionFromSupabase(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      presetId: json['preset_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
      durationSeconds: json['duration_seconds'] as int,
      status: safeEnumByName(SessionStatus.values, json['status'] as String?) ?? SessionStatus.completed,
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // ── LocationTrigger ───────────────────────────────────────────

  /// Drift LocationTriggerRow → Supabase UPSERT용 snake_case JSON.
  static Map<String, dynamic> locationTriggerRowToSupabase(LocationTriggerRow row, String userId) {
    return {
      'id': row.id,
      'user_id': userId,
      'place_name': row.placeName,
      'latitude': row.latitude,
      'longitude': row.longitude,
      'radius_meters': row.radiusMeters,
      'notify_on_entry': row.notifyOnEntry,
      'notify_on_exit': row.notifyOnExit,
      'auto_start': row.autoStart,
      'created_at': row.createdAt.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Supabase snake_case JSON → LocationTrigger.
  static LocationTrigger locationTriggerFromSupabase(Map<String, dynamic> json) {
    return LocationTrigger(
      id: json['id'] as String,
      placeName: json['place_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: json['radius_meters'] as int,
      notifyOnEntry: json['notify_on_entry'] as bool? ?? true,
      notifyOnExit: json['notify_on_exit'] as bool? ?? false,
      autoStart: json['auto_start'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
