// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:projetowell/main.dart';

void main() {
  testWidgets('App shows Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The initial route is the Login screen; check for the Login title
    expect(find.text('Login'), findsWidgets);
    // App name should be visible in the top branding area
    expect(find.text('Well Watch'), findsWidgets);
  });
}
