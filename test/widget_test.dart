import 'package:flutter_test/flutter_test.dart';
import 'package:project/app/app.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BoardGameBookingApp());

    // Verify that our application logo/title 'Tabletop Haven' is present.
    expect(find.text('Tabletop Haven'), findsOneWidget);

    // Verify that the 'Welcome back' greeting is present.
    expect(find.text('Welcome back'), findsOneWidget);

    // Verify that the email and password fields / labels are present.
    expect(find.text('Email or Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify that the Log In button is present.
    expect(find.text('Log In'), findsOneWidget);

    // Verify that the social sign-in options are present.
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}
