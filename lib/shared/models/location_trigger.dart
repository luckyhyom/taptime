import 'package:flutter/foundation.dart';

/// 위치 트리거(지오펜스 장소) 모델.
///
/// 사용자가 등록한 장소의 좌표와 반경, 알림/자동시작 설정을 담는다.
/// 하나의 장소에 여러 프리셋을 연결할 수 있다.
@immutable
class LocationTrigger {
  LocationTrigger({
    required this.id,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.createdAt,
    this.notifyOnEntry = true,
    this.notifyOnExit = false,
    this.autoStart = false,
    DateTime? updatedAt,
  })  : assert(placeName.isNotEmpty && placeName.length <= 40, 'placeName must be 1~40 chars'),
        assert(latitude >= -90 && latitude <= 90, 'latitude must be -90~90'),
        assert(longitude >= -180 && longitude <= 180, 'longitude must be -180~180'),
        assert(radiusMeters >= 50 && radiusMeters <= 5000, 'radiusMeters must be 50~5000'),
        updatedAt = updatedAt ?? createdAt;

  factory LocationTrigger.fromMap(Map<String, dynamic> map) {
    return LocationTrigger(
      id: map['id'] as String,
      placeName: map['placeName'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: map['radiusMeters'] as int,
      notifyOnEntry: map['notifyOnEntry'] as bool? ?? true,
      notifyOnExit: map['notifyOnExit'] as bool? ?? false,
      autoStart: map['autoStart'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] == null ? null : _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  final String id;
  final String placeName;
  final double latitude;
  final double longitude;

  /// 지오펜스 반경 (미터, 50~5000)
  final int radiusMeters;

  /// 장소 진입 시 알림 여부
  final bool notifyOnEntry;

  /// 장소 퇴장 시 알림 여부
  final bool notifyOnExit;

  /// 확인 없이 타이머 자동 시작 여부
  final bool autoStart;

  final DateTime createdAt;
  final DateTime updatedAt;

  LocationTrigger copyWith({
    String? placeName,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    bool? notifyOnEntry,
    bool? notifyOnExit,
    bool? autoStart,
    DateTime? updatedAt,
  }) {
    return LocationTrigger(
      id: id,
      placeName: placeName ?? this.placeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      notifyOnEntry: notifyOnEntry ?? this.notifyOnEntry,
      notifyOnExit: notifyOnExit ?? this.notifyOnExit,
      autoStart: autoStart ?? this.autoStart,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is LocationTrigger && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placeName': placeName,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'notifyOnEntry': notifyOnEntry,
      'notifyOnExit': notifyOnExit,
      'autoStart': autoStart,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'LocationTrigger(id: $id, placeName: $placeName)';
}
