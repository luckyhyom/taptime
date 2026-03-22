import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:taptime/core/config/supabase_config.dart';
import 'package:taptime/features/auth/data/supabase_auth_service.dart';
import 'package:taptime/shared/models/auth_user.dart';
import 'package:taptime/shared/services/auth_service.dart';

/// 인증 서비스 프로바이더.
///
/// Supabase가 설정되지 않은 경우 null을 반환한다.
/// 앱은 인증 없이도 완전히 동작하며, 로그인은 Settings에서 선택적으로 한다.
final authServiceProvider = Provider<AuthService?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  return SupabaseAuthService(
    googleSignIn: GoogleSignIn(
      clientId: SupabaseConfig.googleIosClientId,
      serverClientId: SupabaseConfig.googleWebClientId,
    ),
  );
});

/// 현재 인증 상태를 실시간으로 관찰하는 스트림 프로바이더.
///
/// Supabase 미설정 시 항상 null을 방출한다.
/// 로그인/로그아웃 시 새 [AuthUser] 또는 null이 방출된다.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  if (authService == null) return Stream.value(null);
  return authService.watchAuthState();
});

/// 현재 로그인 여부를 간편하게 확인하는 프로바이더.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});
