// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:client_deployment_app/main.dart';

void main() {
  // MODIFIED: The test description is updated to reflect its new purpose.
  testWidgets('Welcome page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // FIXED: Replaced the incorrect 'MyApp' with the actual app widget 'ClientDeploymentApp'.
    await tester.pumpWidget(const ClientDeploymentApp());

    // Pump a frame to allow the app to render the welcome page.
    await tester.pumpAndSettle();

    // MODIFIED: The test now verifies that the welcome page content is visible,
    // instead of looking for a counter.
    expect(find.text('Deploy 360'), findsOneWidget);
    expect(find.text('Start New Onboarding'), findsOneWidget);

    // Verify that the initial counter text from the template is not present.
    expect(find.text('0'), findsNothing);
  });
}
