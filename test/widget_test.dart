import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumluay_pos/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LumluayApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sales Screen'), findsOneWidget);
  });
}
