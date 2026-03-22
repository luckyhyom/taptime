/// Supabase 및 OAuth 프로젝트 설정.
///
/// credentials는 `.env` 파일에 저장하고, 빌드 시 `--dart-define-from-file`로 주입한다.
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  // ── Supabase ─────────────────────────────────────────────

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Supabase가 설정되었는지 확인한다.
  /// 환경변수가 주입되지 않으면 빈 문자열이므로 false를 반환한다.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  // ── Google OAuth ─────────────────────────────────────────

  /// iOS용 Google OAuth 클라이언트 ID.
  /// Google Cloud Console에서 "iOS" 유형으로 생성한 클라이언트 ID.
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// 웹용 Google OAuth 클라이언트 ID.
  /// Google Cloud Console에서 "웹 애플리케이션" 유형으로 생성한 클라이언트 ID.
  /// Supabase Auth에 등록하는 ID와 동일해야 한다.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
}
