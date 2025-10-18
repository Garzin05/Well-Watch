import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/theme.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/screens/auth/welcome_screen.dart';
import 'package:projetowell/screens/auth/patient_registration_screen.dart';
import 'package:projetowell/screens/auth/doctor_registration_screen.dart';
import 'package:projetowell/screens/auth/login_screen.dart';

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
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<HealthService>(create: (_) => HealthService()),
      ],
      child: MaterialApp(
        title: 'Well Watch',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode
            .dark, // Use ThemeMode.system para seguir o tema do sistema
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Começa direto na tela de login
        routes: {
          '/login': (context) => const LoginScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/patient-registration': (context) =>
              const PatientRegistrationScreen(),
          '/doctor-registration': (context) => const DoctorRegistrationScreen(),
        },
      ),
    );
  }
}
