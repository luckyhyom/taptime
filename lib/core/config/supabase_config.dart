/// Supabase 및 OAuth 프로젝트 설정.
///
/// credentials는 `.env` 파일에 저장하고, 빌드 시 `--dart-define-from-file`로 주입한다.
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  // ── Supabase ─────────────────────────────────────────────

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Supabase가 설정되었는지 확인한다.
  /// 환경변수가 주입되지 않으면 빈 문자열이므로 false를 반환한다.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  // ── Google OAuth ─────────────────────────────────────────
  // String.fromEnvironment는 미설정 시 빈 문자열을 반환하므로,
  // nullable getter로 변환하여 소비자가 이 규칙을 몰라도 되게 한다.

  static const String _googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const String _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// iOS용 Google OAuth 클라이언트 ID. 미설정 시 null.
  static String? get googleIosClientId => _googleIosClientId.isNotEmpty ? _googleIosClientId : null;

  /// 웹용 Google OAuth 클라이언트 ID. 미설정 시 null.
  /// Supabase Auth에 등록하는 ID와 동일해야 한다.
  static String? get googleWebClientId => _googleWebClientId.isNotEmpty ? _googleWebClientId : null;
}
