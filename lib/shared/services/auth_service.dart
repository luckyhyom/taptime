import 'package:taptime/shared/models/auth_user.dart';

/// 인증 서비스 인터페이스.
///
/// Supabase Auth를 추상화하여 UI 레이어가 인증 구현에 의존하지 않도록 한다.
/// v2.0에서 SupabaseAuthService로 구현된다.
abstract class AuthService {
  /// 현재 인증 상태를 실시간으로 관찰한다.
  /// 로그인/로그아웃 시 새 값을 방출한다.
  Stream<AuthUser?> watchAuthState();

  /// 현재 로그인된 사용자를 반환한다. 없으면 null.
  Future<AuthUser?> getCurrentUser();

  /// Google 계정으로 로그인한다.
  Future<AuthUser> signInWithGoogle();

  /// Apple 계정으로 로그인한다.
  Future<AuthUser> signInWithApple();

  /// 로그아웃한다.
  Future<void> signOut();
}
