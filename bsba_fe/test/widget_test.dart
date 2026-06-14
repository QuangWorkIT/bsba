import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/app/app.dart';

void main() {
  testWidgets('BoardNest App navigation smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BoardGameBookingApp());

    // Verify that Explore tab is shown by default and contains "Hello Dart".
    expect(find.text('Hello Dart'), findsOneWidget);

    // Tap the 'Map' navigation destination.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();

    // Verify that the MapScreen is now active and MapCanvas is built.
    expect(find.text('Downtown Hub'), findsNWidgets(2));
    expect(find.text('Hello Dart'), findsNothing);
  });
}
