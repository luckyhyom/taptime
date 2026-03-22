import 'package:flutter/material.dart';

import 'package:taptime/core/utils/enum_utils.dart';

/// 사용자 설정 모델.
///
/// 앱 전체에서 하나만 존재하는 설정값 (싱글턴 패턴).
/// DB에도 단일 행(id=1)으로 저장된다.
@immutable
class UserSettings {
  const UserSettings({
    required this.themeMode,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.locationTrackingEnabled = false,
  });

  /// Map에서 UserSettings 인스턴스를 생성한다.
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      themeMode: safeEnumByName(ThemeMode.values, map['themeMode'] as String?) ?? ThemeMode.system,
      soundEnabled: map['soundEnabled'] as bool,
      vibrationEnabled: map['vibrationEnabled'] as bool,
      locationTrackingEnabled: map['locationTrackingEnabled'] as bool? ?? false,
    );
  }

  /// 기본값으로 생성하는 팩토리.
  /// 앱 최초 실행 시 또는 설정이 아직 저장되지 않았을 때 사용한다.
  factory UserSettings.defaults() {
    return const UserSettings(themeMode: ThemeMode.system, soundEnabled: true, vibrationEnabled: true);
  }

  /// 테마 모드 — light, dark, system(기기 설정 따름)
  final ThemeMode themeMode;

  /// 타이머 완료 시 알림음 재생 여부
  final bool soundEnabled;

  /// 타이머 완료 시 진동 여부
  final bool vibrationEnabled;

  /// 위치 기반 자동 트래킹 활성화 여부
  final bool locationTrackingEnabled;

  UserSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? locationTrackingEnabled,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
    );
  }

  /// JSON 직렬화용 Map으로 변환한다.
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'locationTrackingEnabled': locationTrackingEnabled,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      other.themeMode == themeMode &&
      other.soundEnabled == soundEnabled &&
      other.vibrationEnabled == vibrationEnabled &&
      other.locationTrackingEnabled == locationTrackingEnabled;

  @override
  int get hashCode => Object.hash(themeMode, soundEnabled, vibrationEnabled, locationTrackingEnabled);

  @override
  String toString() =>
      'UserSettings(theme: $themeMode, sound: $soundEnabled, vibration: $vibrationEnabled, location: $locationTrackingEnabled)';
}
