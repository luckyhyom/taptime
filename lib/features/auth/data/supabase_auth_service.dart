import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// Supabase도 AuthUser를 export하므로 hide로 충돌을 방지한다.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:taptime/shared/models/auth_user.dart';
import 'package:taptime/shared/services/auth_service.dart';

/// Supabase Auth 기반 인증 서비스 구현.
///
/// Google/Apple 소셜 로그인을 지원하며,
/// 네이티브 토큰을 받아 Supabase `signInWithIdToken`으로 인증한다.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService({SupabaseClient? client, GoogleSignIn? googleSignIn})
      : _client = client ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  // ── 조회 ───────────────────────────────────────────────────

  @override
  Stream<AuthUser?> watchAuthState() {
    return _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user != null ? _toAuthUser(user) : null;
    });
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user != null ? _toAuthUser(user) : null;
  }

  // ── Google 로그인 ──────────────────────────────────────────

  @override
  Future<AuthUser> signInWithGoogle() async {
    // 1. Google Sign-In SDK로 네이티브 로그인 → 토큰 획득
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google 로그인이 취소되었습니다.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException('Google ID 토큰을 가져올 수 없습니다.');
    }

    // 2. Supabase에 토큰 전달하여 세션 생성
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Supabase 인증에 실패했습니다.');
    }

    return _toAuthUser(user);
  }

  // ── Apple 로그인 ───────────────────────────────────────────

  @override
  Future<AuthUser> signInWithApple() async {
    // 1. nonce 생성: Apple은 SHA-256 해시된 nonce를 받고,
    //    Supabase에는 원본(raw) nonce를 전달해야 한다.
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    // 2. Apple Sign-In SDK로 네이티브 로그인
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Apple ID 토큰을 가져올 수 없습니다.');
    }

    // 3. Supabase에 토큰 + 원본 nonce 전달
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Supabase 인증에 실패했습니다.');
    }

    return _toAuthUser(user);
  }

  // ── 로그아웃 ───────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── 변환 ───────────────────────────────────────────────────

  /// Supabase [User]를 앱 내부 [AuthUser] 모델로 변환한다.
  AuthUser _toAuthUser(User user) {
    // provider 정보는 appMetadata에 'provider' 키로 들어온다.
    final provider = user.appMetadata['provider'] as String?;

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name'] as String?,
      provider: provider,
    );
  }

  /// Apple Sign-In에 필요한 랜덤 nonce 문자열을 생성한다.
  /// 32바이트 랜덤 → URL-safe Base64 인코딩.
  String _generateNonce([int length = 32]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
