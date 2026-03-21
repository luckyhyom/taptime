/// Supabase 프로젝트 설정.
///
/// Supabase 대시보드에서 프로젝트 생성 후
/// Settings > API에서 URL과 anon key를 복사하여 입력한다.
/// anon key는 RLS로 보호되는 공개 키이므로 코드에 포함해도 안전하다.
class SupabaseConfig {
  SupabaseConfig._();

  // TODO(v2.0): Supabase 프로젝트 생성 후 실제 값으로 교체
  static const url = 'https://YOUR_PROJECT.supabase.co';
  static const anonKey = 'YOUR_ANON_KEY';

  /// Supabase가 설정되었는지 확인한다.
  /// placeholder 값이면 false를 반환하여 초기화를 건너뛴다.
  static bool get isConfigured => url != 'https://YOUR_PROJECT.supabase.co';
}
