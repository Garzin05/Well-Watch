import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projetowell/main.dart';
import 'package:projetowell/utils/constants.dart';

void main() {
  testWidgets('Login selects doctor and navigates to Home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter username into first TextFormField
    final usernameField = find.byType(TextFormField).first;
    await tester.enterText(usernameField, 'testuser');

    // Select doctor chip
    final doctorChip = find.byKey(const Key('chip_doctor'));
    expect(doctorChip, findsOneWidget);
    await tester.tap(doctorChip);
    await tester.pumpAndSettle();

    // Tap login
    final loginButton = find.text(AppStrings.loginButton);
    expect(loginButton, findsOneWidget);
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    // Wait for navigation (telas usam animações e delays)
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // HomePage should show 'Monitoramento' in bottom nav for doctor
    expect(find.text('Monitoramento'), findsWidgets);
  });
}
