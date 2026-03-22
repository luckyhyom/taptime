import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:taptime/features/auth/data/supabase_auth_service.dart';
import 'package:taptime/shared/models/auth_user.dart';

import '../../../mocks/mock_repositories.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  FakeSupabaseClient(this._auth);

  final GoTrueClient _auth;

  @override
  GoTrueClient get auth => _auth;
}

void main() {
  late MockGoTrueClient mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FakeSupabaseClient fakeClient;
  late SupabaseAuthService authService;

  setUp(() {
    mockAuth = MockGoTrueClient();
    mockGoogleSignIn = MockGoogleSignIn();
    fakeClient = FakeSupabaseClient(mockAuth);
    authService = SupabaseAuthService(
      googleSignIn: mockGoogleSignIn,
      client: fakeClient,
    );
  });

  /// MockUser를 생성하고 필요한 stub을 설정한다.
  /// when() 밖에서 호출해야 nested when 에러를 피할 수 있다.
  MockUser createMockUser({
    String id = 'user-123',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
    String? provider = 'google',
  }) {
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn(id);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.appMetadata).thenReturn(
      provider != null ? {'provider': provider} : {},
    );
    when(() => mockUser.userMetadata).thenReturn(
      displayName != null ? {'full_name': displayName} : null,
    );
    return mockUser;
  }

  group('getCurrentUser', () {
    test('로그인 상태에서 AuthUser를 반환한다', () async {
      final mockUser = createMockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final user = await authService.getCurrentUser();

      expect(user, isNotNull);
      expect(user!.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.provider, 'google');
    });

    test('비로그인 상태에서 null을 반환한다', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final user = await authService.getCurrentUser();

      expect(user, isNull);
    });

    test('email이 null인 경우 빈 문자열을 사용한다', () async {
      final mockUser = createMockUser(email: null);
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final user = await authService.getCurrentUser();

      expect(user!.email, '');
    });

    test('displayName이 없는 경우 null을 반환한다', () async {
      final mockUser = createMockUser(displayName: null);
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final user = await authService.getCurrentUser();

      expect(user!.displayName, isNull);
    });
  });

  group('signInWithGoogle', () {
    test('Google 토큰으로 Supabase 인증에 성공한다', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.idToken).thenReturn('google-id-token');
      when(() => mockGoogleAuth.accessToken).thenReturn('google-access-token');

      final mockUser = createMockUser();
      when(() => mockAuth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: 'google-id-token',
            accessToken: 'google-access-token',
          )).thenAnswer((_) async => AuthResponse(user: mockUser));

      final user = await authService.signInWithGoogle();

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
    });

    test('Google 로그인 취소 시 AuthException을 던진다', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Google ID 토큰이 없으면 AuthException을 던진다', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.idToken).thenReturn(null);

      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Supabase 인증 실패(user null) 시 AuthException을 던진다', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.idToken).thenReturn('google-id-token');
      when(() => mockGoogleAuth.accessToken).thenReturn('google-access-token');
      when(() => mockAuth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: 'google-id-token',
            accessToken: 'google-access-token',
          )).thenAnswer((_) async => AuthResponse(user: null));

      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('Supabase signOut을 호출한다', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('watchAuthState', () {
    test('Supabase auth 상태 변경을 AuthUser 스트림으로 변환한다', () async {
      final controller = StreamController<AuthState>();
      when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final mockUser = createMockUser();
      final session = Session(
        accessToken: 'fake-token',
        tokenType: 'bearer',
        user: mockUser,
      );

      final results = <AuthUser?>[];
      final sub = authService.watchAuthState().listen(results.add);

      controller.add(AuthState(AuthChangeEvent.signedIn, session));
      await Future.delayed(Duration.zero);

      expect(results, hasLength(1));
      expect(results.first!.id, 'user-123');

      await sub.cancel();
      await controller.close();
    });

    test('로그아웃 시 null을 emit한다', () async {
      final controller = StreamController<AuthState>();
      when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final results = <AuthUser?>[];
      final sub = authService.watchAuthState().listen(results.add);

      controller.add(AuthState(AuthChangeEvent.signedOut, null));
      await Future.delayed(Duration.zero);

      expect(results, hasLength(1));
      expect(results.first, isNull);

      await sub.cancel();
      await controller.close();
    });
  });
}
