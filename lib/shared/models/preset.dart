import 'package:flutter/foundation.dart';

/// 프리셋(활동 템플릿) 모델.
///
/// 사용자가 만드는 타이머 활동의 설정을 담는 불변(immutable) 클래스.
/// 예: "Study" 프리셋 — 25분, 책 아이콘, 파란색, 일일목표 120분
///
/// 이 클래스는 Drift(DB)와 완전히 독립된 순수 Dart 클래스이다.
/// UI 레이어는 이 모델만 사용하고, Drift를 직접 import하지 않는다.
/// DB 행(PresetRow) ↔ Preset 변환은 Repository 구현체가 담당한다.
@immutable
class Preset {
  Preset({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.icon,
    required this.color,
    required this.dailyGoalMin,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(durationMin >= 0 && durationMin <= 180, 'durationMin must be 0~180 (0 = unlimited)'),
        assert(name.isNotEmpty && name.length <= 20, 'name must be 1~20 chars'),
        assert(dailyGoalMin >= 0, 'dailyGoalMin must be >= 0');

  /// Map에서 Preset 인스턴스를 생성한다.
  ///
  /// Supabase JSON, 내보내기/가져오기 등에서 사용한다.
  /// DateTime 필드는 DateTime 객체와 ISO 8601 문자열 모두 허용한다.
  factory Preset.fromMap(Map<String, dynamic> map) {
    return Preset(
      id: map['id'] as String,
      name: map['name'] as String,
      durationMin: map['durationMin'] as int,
      icon: map['icon'] as String,
      color: map['color'] as String,
      dailyGoalMin: map['dailyGoalMin'] as int,
      sortOrder: map['sortOrder'] as int,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  /// UUID v4 — 기기 간 충돌 없는 고유 식별자
  final String id;

  /// 프리셋 이름 (예: "Study", "Exercise")
  final String name;

  /// 타이머 시간 (분 단위, 1~180)
  final int durationMin;

  /// 아이콘 키 — AppConstants.presetIcons 맵의 키와 대응
  final String icon;

  /// 색상 hex 문자열 (예: "#4A90D9")
  final String color;

  /// 일일 목표 시간 (분 단위, 0이면 목표 없음)
  final int dailyGoalMin;

  /// 홈 화면 그리드에서의 정렬 순서
  final int sortOrder;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// 일부 필드만 변경한 새 인스턴스를 반환.
  ///
  /// 불변 객체이므로 직접 수정할 수 없고,
  /// 변경이 필요하면 copyWith로 새 객체를 만든다.
  /// null 체크가 아닌 sentinel 패턴이 필요하지만,
  /// 이 앱에서는 모든 필드가 non-nullable이므로 단순하게 구현한다.
  Preset copyWith({
    String? name,
    int? durationMin,
    String? icon,
    String? color,
    int? dailyGoalMin,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Preset(
      id: id,
      name: name ?? this.name,
      durationMin: durationMin ?? this.durationMin,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// id 기반 동등성 — 같은 id면 같은 프리셋으로 취급한다.
  @override
  bool operator ==(Object other) => other is Preset && other.id == id;

  @override
  int get hashCode => id.hashCode;

  /// JSON 직렬화용 Map으로 변환한다.
  ///
  /// DateTime은 ISO 8601 문자열로 변환한다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationMin': durationMin,
      'icon': icon,
      'color': color,
      'dailyGoalMin': dailyGoalMin,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Preset(id: $id, name: $name, durationMin: $durationMin)';
}
