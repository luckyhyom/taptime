import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 상수 정의.
///
/// 기본 프리셋, 아이콘 목록, 타이머 범위 등
/// 비즈니스 로직에 필요한 고정값들을 모아둔다.
abstract final class AppConstants {
  // ── 기본 프리셋 ──────────────────────────────────────────────
  // 앱 최초 실행 시 자동으로 생성되는 프리셋 3개.
  // 각 항목은 {이름, 시간(분), 아이콘 키, 색상}으로 구성된다.
  // 아이콘 키는 아래 presetIcons 맵의 키와 대응된다.

  static const defaultPresets = [
    {'name': 'Study', 'durationMin': 25, 'icon': 'menu_book', 'color': '#4A90D9', 'dailyGoalMin': 120},
    {'name': 'Exercise', 'durationMin': 30, 'icon': 'fitness_center', 'color': '#E94560', 'dailyGoalMin': 60},
    {'name': 'Reading', 'durationMin': 20, 'icon': 'auto_stories', 'color': '#2ECC71', 'dailyGoalMin': 60},
  ];

  // ── 프리셋 아이콘 ─────────────────────────────────────────────
  // 사용자가 프리셋을 만들 때 선택할 수 있는 아이콘 목록.
  // 문자열 키 → Material Icon으로 매핑한다.
  // DB에는 문자열 키('menu_book')를 저장하고,
  // UI에서 이 맵을 통해 실제 아이콘으로 변환한다.

  static const presetIcons = <String, IconData>{
    'menu_book': Icons.menu_book,
    'fitness_center': Icons.fitness_center,
    'code': Icons.code,
    'brush': Icons.brush,
    'music_note': Icons.music_note,
    'translate': Icons.translate,
    'work': Icons.work,
    'self_improvement': Icons.self_improvement,
    'edit_note': Icons.edit_note,
    'coffee': Icons.coffee,
    'auto_stories': Icons.auto_stories,
    'school': Icons.school,
    'science': Icons.science,
    'sports_esports': Icons.sports_esports,
    'restaurant': Icons.restaurant,
    'directions_run': Icons.directions_run,
    'palette': Icons.palette,
    'headphones': Icons.headphones,
    'calculate': Icons.calculate,
    'pets': Icons.pets,
  };

  // ── 프리셋 색상 팔레트 ────────────────────────────────────────
  // 사용자가 프리셋을 만들 때 선택할 수 있는 색상 목록.
  // DB에는 hex 문자열('#4A90D9')을 저장하고,
  // UI에서 Color 객체로 변환하여 사용한다.
  // AppColors.presetPalette와 동일한 색상이지만,
  // 여기서는 hex 문자열 형태로 제공한다 (DB 저장용).

  static const presetColorHexes = [
    '#4A90D9', // 블루
    '#E94560', // 코랄
    '#2ECC71', // 그린
    '#F39C12', // 오렌지
    '#9B59B6', // 퍼플
    '#1ABC9C', // 틸
    '#E74C3C', // 레드
    '#34495E', // 차콜
  ];

  // ── 타이머 범위 ──────────────────────────────────────────────
  // 프리셋 생성 시 설정할 수 있는 타이머 시간의 최소/최대값 (분 단위).

  /// 0 = 무제한(스톱워치) 모드
  static const timerMinMinutes = 0;
  static const timerMaxMinutes = 180;
  static const timerDefaultMinutes = 25;

  // ── 프리셋 이름 ──────────────────────────────────────────────

  static const presetNameMaxLength = 20;

  // ── 위치 트리거 ──────────────────────────────────────────────

  static const locationNameMaxLength = 40;

  /// UI에서 허용하는 최소 지오펜스 반경 (미터)
  static const locationRadiusMin = 50;

  /// UI에서 허용하는 최대 지오펜스 반경 (미터).
  /// 모델은 5000m까지 허용하지만, UX상 1000m로 제한한다.
  static const locationRadiusMax = 1000;

  /// 지오펜스 반경 기본값 (미터)
  static const locationRadiusDefault = 200;

  // ── 세션 ────────────────────────────────────────────────────

  static const sessionMemoMaxLength = 200;

  // ── 브레이크 타이머 ────────────────────────────────────────────

  /// 짧은 휴식 시간 (5분)
  static const shortBreakSeconds = 300;

  /// 긴 휴식 시간 (15분)
  static const longBreakSeconds = 900;
}
