import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/app.dart';

void main() {
  testWidgets('앱이 정상적으로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // 홈 화면이 표시되는지 확인
    expect(find.text('Taptime'), findsOneWidget);
  });
}
