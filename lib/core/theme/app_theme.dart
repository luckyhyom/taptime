import 'package:flutter/material.dart';

import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/theme/app_typography.dart';

/// 라이트/다크 테마를 생성하는 팩토리.
///
/// Material 3의 [ColorScheme.fromSeed]를 사용하여 seed color 하나로
/// 전체 색상 팔레트를 자동 생성한다. 여기에 앱 고유의 surface 색상과
/// 타이포그래피를 오버라이드하여 브랜드 느낌을 준다.
abstract final class AppTheme {
  /// 라이트 모드 테마.
  ///
  /// [AppColors.navy]를 seed로 사용하며,
  /// surface와 텍스트 색상은 디자인 시스템에서 정의한 값으로 덮어쓴다.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
    );

    return _buildTheme(colorScheme);
  }

  /// 다크 모드 테마.
  ///
  /// 같은 seed color를 사용하되 [Brightness.dark]로 설정하여
  /// Material 3가 다크 모드에 맞는 팔레트를 생성하게 한다.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
    );

    return _buildTheme(colorScheme);
  }

  /// 라이트/다크 공통 테마 빌드 로직.
  ///
  /// colorScheme만 다르고 나머지 설정(타이포그래피, 카드 모양 등)은
  /// 동일하므로 공통 메서드로 추출했다.
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      // Material 3 디자인 시스템 활성화
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,

      // ── 컴포넌트별 기본 스타일 ──────────────────────────────
      // 개별 위젯에서 매번 스타일을 지정하지 않아도
      // 테마에서 정의한 기본값이 적용된다.
      cardTheme: CardThemeData(
        elevation: 0, // 플랫 디자인: 그림자 제거
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
      ),
    );
  }
}
