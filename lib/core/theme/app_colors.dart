import 'dart:ui';

/// 앱 전체에서 사용하는 색상 상수.
///
/// Material 3의 ColorScheme.fromSeed()가 자동으로 생성하는 색상 팔레트 외에,
/// 앱 고유의 시맨틱 색상을 여기서 정의한다.
/// 실제 테마 적용은 AppTheme에서 이 값들을 사용해 처리한다.
abstract final class AppColors {
  // ── 브랜드 색상 ──────────────────────────────────────────────
  // seed color로 사용되며, Material 3가 이 색상을 기반으로
  // primary, secondary, tertiary 등의 전체 팔레트를 자동 생성한다.

  /// 딥 네이비 — 라이트 모드의 seed color
  static const navy = Color(0xFF1A1A2E);

  /// 코랄 레드 — 타이머, 활성 상태, FAB 등 강조 요소에 사용
  static const coral = Color(0xFFE94560);

  // ── 라이트 모드 ─────────────────────────────────────────────

  /// 라이트 모드 배경색 (오프 화이트)
  static const lightSurface = Color(0xFFFAFAFA);

  /// 라이트 모드 보조 텍스트 색상
  static const lightOnSurface = Color(0xFF333333);

  // ── 다크 모드 ──────────────────────────────────────────────

  /// 다크 모드 배경색 (다크 블루)
  static const darkSurface = Color(0xFF16213E);

  /// 다크 모드 보조 텍스트 색상
  static const darkOnSurface = Color(0xFFCCCCCC);

  // ── 프리셋 색상 팔레트 ────────────────────────────────────────
  // 사용자가 프리셋(활동)을 만들 때 선택할 수 있는 색상 목록.
  // 라이트/다크 모드 모두에서 잘 보이는 중간 채도의 색상을 선택했다.

  static const presetPalette = [
    Color(0xFF4A90D9), // 블루
    coral, // 코랄
    Color(0xFF2ECC71), // 그린
    Color(0xFFF39C12), // 오렌지
    Color(0xFF9B59B6), // 퍼플
    Color(0xFF1ABC9C), // 틸
    Color(0xFFE74C3C), // 레드
    Color(0xFF34495E), // 차콜
  ];
}
