import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taptime/app.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/features/home/ui/preset_providers.dart';
import 'package:taptime/shared/models/user_settings.dart';

void main() {
  testWidgets('앱이 정상적으로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // App이 watch하는 모든 DB 의존 프로바이더를 override하여
        // 실제 Drift DB 없이 렌더링할 수 있게 한다.
        overrides: [
          appInitProvider.overrideWith((_) async {}),
          presetListProvider.overrideWith((_) => const Stream.empty()),
          userSettingsStreamProvider.overrideWith(
            (_) => Stream.value(UserSettings.defaults()),
          ),
        ],
        child: const App(),
      ),
    );
    // GoRouter 내부 애니메이션이 끝나지 않아 pumpAndSettle은 타임아웃된다.
    // pump()로 첫 프레임만 렌더링하여 위젯 트리를 확인한다.
    await tester.pump();

    expect(find.text('Taptime'), findsOneWidget);
  });
}
