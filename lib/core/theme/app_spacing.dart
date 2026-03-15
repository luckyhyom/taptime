/// 앱 전체의 간격(spacing)과 크기 상수.
///
/// 8px 그리드 시스템을 기반으로 한다.
/// 모든 간격을 상수로 관리하면 UI의 일관성을 유지하기 쉽고,
/// 나중에 디자인을 조정할 때 한 곳만 수정하면 된다.
abstract final class AppSpacing {
  // ── 기본 간격 ──────────────────────────────────────────────

  /// 8px 그리드의 기본 단위
  static const double grid = 8;

  /// 컴포넌트 사이의 작은 간격 (프리셋 그리드 내 카드 간 간격 등)
  static const double gap = 12;

  /// 카드 내부 여백, 화면 좌우 마진
  static const double padding = 16;

  /// 섹션 간 넓은 간격
  static const double sectionGap = 24;

  // ── 보더 라디우스 ─────────────────────────────────────────

  /// 카드, 다이얼로그 등의 모서리 둥글기
  static const double cardRadius = 12;

  /// 버튼의 모서리 둥글기
  static const double buttonRadius = 24;
}
