import 'dart:ui';

/// hex 문자열 → Color 변환 유틸리티.
///
/// DB에는 '#4A90D9' 형태의 문자열로 색상을 저장하고,
/// UI에서는 Flutter의 Color 객체가 필요하다.
/// 이 클래스가 그 변환을 담당한다.
abstract final class ColorUtils {
  /// '#RRGGBB' 또는 'RRGGBB' 형식의 hex 문자열을 Color로 변환한다.
  ///
  /// Color는 0xAARRGGBB 형식의 32비트 정수를 받으므로,
  /// 알파값(FF = 불투명)을 앞에 붙여야 한다.
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
