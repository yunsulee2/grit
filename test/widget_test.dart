import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grit/main.dart';

void main() {
  testWidgets('App renders with bottom navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify bottom tab labels are present
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('카테고리'), findsOneWidget);
    expect(find.text('판매'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);

    // Verify home tab icons
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
