import 'package:taptime/shared/models/location_trigger.dart';

/// 위치 트리거 데이터 접근 인터페이스.
abstract class LocationTriggerRepository {
  /// 모든 위치 트리거를 가져온다.
  Future<List<LocationTrigger>> getAllTriggers();

  /// 모든 위치 트리거를 실시간으로 관찰한다.
  Stream<List<LocationTrigger>> watchAllTriggers();

  /// 특정 위치 트리거를 가져온다.
  Future<LocationTrigger?> getTriggerById(String id);

  /// 새 위치 트리거를 생성한다.
  Future<void> createTrigger(LocationTrigger trigger);

  /// 위치 트리거를 수정한다.
  Future<void> updateTrigger(LocationTrigger trigger);

  /// 위치 트리거를 삭제한다 (소프트 삭제).
  Future<void> deleteTrigger(String id);

  /// 모든 위치 트리거를 삭제한다 (데이터 초기화용).
  Future<void> deleteAllTriggers();
}
