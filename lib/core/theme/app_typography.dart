import 'package:flutter/material.dart';

/// 앱 전체의 텍스트 스타일 정의.
///
/// 시스템 기본 폰트를 사용하며 (iOS: San Francisco, Android: Roboto),
/// MVP에서는 3가지 크기만 사용하여 일관성을 유지한다.
///
/// Flutter의 TextTheme에는 다양한 스타일 슬롯이 있지만,
/// 이 앱에서 실제로 사용하는 것은 3가지뿐이다:
/// - titleLarge (20sp) — 화면 제목, 타이머 숫자 등 큰 텍스트
/// - bodyLarge (16sp) — 일반 본문 텍스트, 버튼 라벨
/// - bodySmall (12sp) — 캡션, 부가 정보, 타임스탬프
abstract final class AppTypography {
  static const textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );
}
