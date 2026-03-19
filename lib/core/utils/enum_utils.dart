/// 안전한 enum 파싱 유틸리티.
///
/// DB에 저장된 문자열이 유효하지 않은 enum 값일 수 있다.
/// 예: 앱 업데이트로 enum 값이 변경되었거나, DB가 손상된 경우.
/// `Enum.values.byName()`은 `StateError`를 던지지만,
/// 이 함수는 null을 반환하여 호출자가 fallback 값을 결정하게 한다.
///
/// [values]: enum의 values 리스트 (예: SessionStatus.values)
/// [name]: 파싱할 문자열 (예: 'completed')
/// 반환: 매칭되는 enum 값, 없으면 null
T? safeEnumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
