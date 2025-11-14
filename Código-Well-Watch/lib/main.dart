import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';

import 'package:projetowell/router.dart';
import 'package:projetowell/theme.dart';

// PÁGINAS DO MÉDICO
import 'package:projetowell/screens/doctor/pages/agenda_page.dart';
import 'package:projetowell/screens/doctor/pages/notifications_page.dart';
import 'package:projetowell/screens/doctor/pages/patients_page.dart';
import 'package:projetowell/screens/doctor/pages/profile_page.dart';
import 'package:projetowell/screens/doctor/pages/reports_page.dart';
import 'package:projetowell/screens/doctor/pages/settings_page.dart';
import 'package:projetowell/screens/doctor/pages/doctor_menu_page.dart'; // <-- IMPORTANTE


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Permitir app apenas em portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<HealthService>(create: (_) => HealthService()),
      ],

      child: MaterialApp(
        title: 'Well Watch',

        // ------------------------------
        // TEMAS
        // ------------------------------
        theme: lightTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        darkTheme: darkTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,

        // ------------------------------
        // ROTA INICIAL
        // ------------------------------
        initialRoute: AppRoutes.login,

        // ------------------------------
        // ROTAS REGISTRADAS
        // ------------------------------
        routes: {
          ...appRoutes(),

          // ROTA QUE FALTAVA — ESSENCIAL!
          '/doctor_menu': (_) => const DoctorMenuPage(),

          // Rotas do menu médico
          '/reports': (_) => const ReportsPage(),
          '/agenda': (_) => const AgendaPage(),
          '/patients': (_) => const PatientsPage(),
          '/notifications': (_) => const NotificationsPage(),
          '/settings': (_) => const SettingsPage(),
          '/profile': (_) => const ProfilePage(),
        },
      ),
    );
  }
}
