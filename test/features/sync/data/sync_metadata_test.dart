import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taptime/features/sync/data/sync_metadata.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('lastPullTimestamp', () {
    test('초기 상태에서 null을 반환한다', () async {
      final result = await SyncMetadata.getLastPullTimestamp();
      expect(result, isNull);
    });

    test('set 후 get이 같은 값을 반환한다', () async {
      final timestamp = DateTime.utc(2026, 3, 22, 10, 0, 0);
      await SyncMetadata.setLastPullTimestamp(timestamp);

      final result = await SyncMetadata.getLastPullTimestamp();
      expect(result, isNotNull);
      expect(result!.isAtSameMomentAs(timestamp), isTrue);
    });

    test('UTC로 저장되고 UTC로 반환된다', () async {
      final timestamp = DateTime.utc(2026, 3, 22, 10, 0, 0);
      await SyncMetadata.setLastPullTimestamp(timestamp);

      final result = await SyncMetadata.getLastPullTimestamp();
      expect(result!.isUtc, isTrue);
    });
  });

  group('lastSyncTime', () {
    test('초기 상태에서 null을 반환한다', () async {
      final result = await SyncMetadata.getLastSyncTime();
      expect(result, isNull);
    });

    test('set 후 get이 같은 값을 반환한다', () async {
      final timestamp = DateTime.utc(2026, 3, 22, 12, 30, 0);
      await SyncMetadata.setLastSyncTime(timestamp);

      final result = await SyncMetadata.getLastSyncTime();
      expect(result, isNotNull);
      expect(result!.isAtSameMomentAs(timestamp), isTrue);
    });
  });

  group('clear', () {
    test('모든 메타데이터를 초기화한다', () async {
      await SyncMetadata.setLastPullTimestamp(DateTime.utc(2026, 3, 22));
      await SyncMetadata.setLastSyncTime(DateTime.utc(2026, 3, 22));

      await SyncMetadata.clear();

      expect(await SyncMetadata.getLastPullTimestamp(), isNull);
      expect(await SyncMetadata.getLastSyncTime(), isNull);
    });
  });
}
