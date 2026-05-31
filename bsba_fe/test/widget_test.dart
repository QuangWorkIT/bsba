import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/app/app.dart';
import 'package:project/ui/map/widgets/map_canvas.dart';

void main() {
  testWidgets('BoardNest App navigation smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BoardGameBookingApp());

    // Verify that Explore tab is shown by default and contains "Hello Dart".
    expect(find.text('Hello Dart'), findsOneWidget);
    expect(find.byType(MapCanvas), findsNothing);

    // Tap the 'Map' navigation destination.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();

    // Verify that the MapScreen is now active and MapCanvas is built.
    expect(find.byType(MapCanvas), findsOneWidget);
    expect(find.text('Downtown Hub'), findsNWidgets(2));
    expect(find.text('Hello Dart'), findsNothing);
  });
}
