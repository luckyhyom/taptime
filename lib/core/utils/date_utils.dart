/// DateTime 관련 유틸리티.
///
/// Dart의 extension을 사용하여 DateTime에 편의 메서드를 추가한다.
/// extension은 기존 클래스를 수정하지 않고 메서드를 추가하는 Dart 문법이다.
/// 사용 예: DateTime.now().startOfDay
extension DateTimeX on DateTime {
  /// 해당 날짜의 시작 시각 (00:00:00).
  /// 날짜별 세션 조회 시 범위의 시작점으로 사용한다.
  DateTime get startOfDay => DateTime(year, month, day);

  /// 해당 날짜의 마지막 시각 (23:59:59.999).
  /// 날짜별 세션 조회 시 범위의 끝점으로 사용한다.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// 두 DateTime이 같은 날인지 비교.
  /// 시간은 무시하고 년/월/일만 비교한다.
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  /// 해당 월의 첫째 날 (1일 00:00:00).
  DateTime get startOfMonth => DateTime(year, month);

  /// 해당 월의 마지막 시각.
  /// month + 1의 0일 = 현재 월의 마지막 날 (Dart DateTime 관례).
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// 해당 월의 일수 (28~31).
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// 해당 주의 월요일 (ISO 8601 기준 주 시작).
  DateTime get startOfWeek => DateTime(year, month, day - (weekday - 1));
}

/// 시간 포맷 유틸리티.
abstract final class TimeFormatter {
  /// 초를 MM:SS 형식으로 변환.
  /// 타이머 카운트다운 표시에 사용한다.
  /// 예: 125초 → "02:05", 3600초 → "60:00"
  static String mmss(int totalSeconds) {
    final minutes = totalSeconds ~/ 60; // ~/ 는 정수 나눗셈 연산자
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 과거 시각을 상대적 표현으로 변환한다.
  /// 예: 30초 전 → "방금", 5분 전 → "5분 전", 3시간 전 → "3시간 전"
  static String relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  /// 분을 시:분 형식의 읽기 쉬운 문자열로 변환.
  /// 통계 화면에서 총 시간을 표시할 때 사용한다.
  /// 예: 125분 → "2h 5m", 45분 → "45m", 0분 → "0m"
  static String humanize(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
