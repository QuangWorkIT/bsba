import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/app/home_screen.dart';
import 'package:project/app/settings_provider.dart';
import 'package:project/ui/booking/booking_screen.dart';

void main() {
  testWidgets('Bookings navigation destination opens booking history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.tap(find.text('Bookings'));
    await tester.pump();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text("The Dragon's Lair - VIP Room"), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cyber Command Station'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Cyber Command Station'), findsOneWidget);
  });

  testWidgets('QR button opens the booking QR dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookingScreen())),
    );

    final qrButton = find.byIcon(Icons.qr_code).first;
    await tester.scrollUntilVisible(qrButton, 250);
    await tester.tap(qrButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Booking QR Code'), findsOneWidget);
    expect(
      find.text('Show this QR code to staff when you arrive for check-in.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Booking QR Code'), findsNothing);
  });
}
