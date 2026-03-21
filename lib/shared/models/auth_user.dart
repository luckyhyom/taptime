import 'package:flutter/foundation.dart';

/// 인증된 사용자 정보.
///
/// Supabase Auth에서 반환되는 사용자를 앱 내부 모델로 변환한 것.
/// UI와 동기화 로직에서 사용한다.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.provider,
  });

  /// Supabase user UUID
  final String id;

  /// 이메일 주소
  final String email;

  /// 표시 이름 (Google/Apple 프로필에서 가져옴)
  final String? displayName;

  /// 인증 제공자: 'google' 또는 'apple'
  final String? provider;

  /// UI에 표시할 이름. displayName이 없으면 email을 사용한다.
  String get displayLabel => displayName ?? email;

  @override
  bool operator ==(Object other) => other is AuthUser && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, email: $email, provider: $provider)';
}
