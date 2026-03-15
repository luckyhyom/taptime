import 'package:flutter/material.dart';

/// 사용자 설정 모델.
///
/// 앱 전체에서 하나만 존재하는 설정값 (싱글턴 패턴).
/// DB에도 단일 행(id=1)으로 저장된다.
@immutable
class UserSettings {
  const UserSettings({required this.themeMode, required this.soundEnabled, required this.vibrationEnabled});

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

  UserSettings copyWith({ThemeMode? themeMode, bool? soundEnabled, bool? vibrationEnabled}) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      other.themeMode == themeMode &&
      other.soundEnabled == soundEnabled &&
      other.vibrationEnabled == vibrationEnabled;

  @override
  int get hashCode => Object.hash(themeMode, soundEnabled, vibrationEnabled);

  @override
  String toString() => 'UserSettings(theme: $themeMode, sound: $soundEnabled, vibration: $vibrationEnabled)';
}
