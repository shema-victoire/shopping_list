import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_list/main.dart';

void main() {
  testWidgets('Shopping List smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShoppingApp());

    // Verify initial items are present
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);

    // Verify title is present
    expect(find.text('Shopping List+ (3 left)'), findsOneWidget);
  });
}
