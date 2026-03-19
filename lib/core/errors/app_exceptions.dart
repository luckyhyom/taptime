/// 앱 전체에서 사용하는 예외 계층 구조.
///
/// Repository 구현체에서 Drift 등의 raw 예외를 잡아서
/// 이 계층의 예외로 변환한 뒤 UI 레이어로 전달한다.
/// sealed class이므로 switch 문에서 exhaustive 검사가 가능하다.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// 사용자에게 표시할 수 있는 에러 메시지
  final String message;

  @override
  String toString() => message;
}

/// DB 조회/저장 실패 시 발생하는 예외.
class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

/// 입력값 검증 실패 시 발생하는 예외.
///
/// 폼 입력, API 응답 등 외부 데이터의 유효성 검사에서 사용한다.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// 요청한 리소스를 찾을 수 없을 때 발생하는 예외.
///
/// 존재하지 않는 프리셋 id로 조회하는 경우 등.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
