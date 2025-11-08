import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/screens/doctor/pages/agenda_page.dart';
import 'package:projetowell/screens/doctor/pages/notifications_page.dart';
import 'package:projetowell/screens/doctor/pages/patients_page.dart';
import 'package:projetowell/screens/doctor/pages/profile_page.dart';
import 'package:projetowell/screens/doctor/pages/reports_page.dart';
import 'package:projetowell/screens/doctor/pages/settings_page.dart';

import 'package:projetowell/theme.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        theme: lightTheme.copyWith(
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        darkTheme: darkTheme.copyWith(
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        themeMode: ThemeMode.dark, // Mantido
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: {
          ...appRoutes(),
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

extension on Future<ThemeData> {
  ThemeData? copyWith({required bool useMaterial3, required PageTransitionsTheme pageTransitionsTheme}) {
    return null;
  }
}
