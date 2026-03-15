import 'package:taptime/shared/models/user_settings.dart';

/// 사용자 설정 데이터 접근 인터페이스.
///
/// 설정은 앱에 하나만 존재하므로 id 파라미터가 없다.
/// DB에서는 단일 행(id=1)으로 관리된다.
abstract class UserSettingsRepository {
  /// 현재 설정을 가져온다.
  /// 저장된 설정이 없으면 기본값을 반환한다.
  Future<UserSettings> getSettings();

  /// 설정 변경을 실시간으로 관찰한다.
  /// 테마 변경 시 앱 전체에 즉시 반영하는 데 사용한다.
  Stream<UserSettings> watchSettings();

  /// 설정을 저장한다 (없으면 생성, 있으면 업데이트).
  Future<void> updateSettings(UserSettings settings);
}
