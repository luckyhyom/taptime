import 'package:taptime/shared/models/preset.dart';

/// 프리셋 데이터 접근 인터페이스.
///
/// 추상 클래스로 정의하여 UI 레이어가 구현체(Drift)에 의존하지 않게 한다.
/// 현재는 Drift 기반 로컬 구현만 있지만, 나중에 클라우드(Supabase) 구현으로
/// 교체할 때 이 인터페이스를 그대로 유지하면 UI 코드를 수정할 필요가 없다.
abstract class PresetRepository {
  /// 모든 프리셋을 sortOrder 순으로 가져온다.
  Future<List<Preset>> getAllPresets();

  /// 모든 프리셋의 실시간 스트림.
  /// Riverpod의 StreamProvider와 함께 사용하면
  /// DB 변경 시 UI가 자동으로 업데이트된다.
  Stream<List<Preset>> watchAllPresets();

  /// id로 단일 프리셋을 조회한다.
  Future<Preset?> getPresetById(String id);

  /// 새 프리셋을 생성한다.
  Future<void> createPreset(Preset preset);

  /// 기존 프리셋을 수정한다.
  Future<void> updatePreset(Preset preset);

  /// 프리셋을 삭제한다.
  Future<void> deletePreset(String id);

  /// 프리셋 정렬 순서를 일괄 업데이트한다.
  /// 홈 화면에서 드래그 앤 드롭으로 순서를 변경할 때 사용한다.
  /// Map의 key는 프리셋 id, value는 새 sortOrder.
  Future<void> updateSortOrder(Map<String, int> idToSortOrder);

  /// 모든 프리셋을 삭제한다 (설정 > 데이터 초기화에 사용).
  /// CASCADE로 인해 관련 세션과 활성 타이머도 함께 삭제된다.
  Future<void> deleteAllPresets();
}
