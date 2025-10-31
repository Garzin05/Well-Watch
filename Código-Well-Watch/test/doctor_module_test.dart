import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:projetowell/screens/doctor/doctor_menu_page.dart';
import 'package:projetowell/screens/doctor/doctor_patients_page.dart';
import 'package:projetowell/screens/doctor/doctor_appointments_page.dart';
import 'package:projetowell/screens/doctor/doctor_medical_records_page.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('Doctor Module Integration Tests', () {
    testWidgets('Doctor menu page displays correctly', (tester) async {
      final authService = AuthService();
      await authService.login('admin', '123456');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: const DoctorMenuPage(),
          ),
        ),
      );

      expect(find.text('Dr. admin'), findsOneWidget);
      expect(find.text('Menu Principal'), findsOneWidget);
      expect(find.text('Atalhos Rápidos'), findsOneWidget);
    });

    testWidgets('Doctor patients page shows patient list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorPatientsPage(),
        ),
      );

      expect(find.text('Meus Pacientes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search field
      expect(find.byType(FloatingActionButton),
          findsOneWidget); // Add patient button
    });

    testWidgets('Doctor appointments page shows calendar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorAppointmentsPage(),
        ),
      );

      expect(find.text('Agenda'), findsOneWidget);
      // Should show today's date
      expect(find.text(DateTime.now().day.toString()), findsOneWidget);
    });

    testWidgets('Doctor medical records page shows search', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorMedicalRecordsPage(),
        ),
      );

      expect(find.text('Prontuários'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search field
      expect(find.byIcon(Icons.filter_list), findsOneWidget); // Filter button
    });

    testWidgets('Navigation between doctor pages works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/doctor/menu',
          routes: {
            '/doctor/menu': (context) => const DoctorMenuPage(),
            '/doctor/patients': (context) => const DoctorPatientsPage(),
            '/doctor/appointments': (context) => const DoctorAppointmentsPage(),
            '/doctor/medical-records': (context) =>
                const DoctorMedicalRecordsPage(),
          },
        ),
      );

      // Tap on the Patients menu item
      await tester.tap(find.text('Pacientes'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorPatientsPage), findsOneWidget);
    });
  });
}
