import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/patient_registration_screen.dart';
import 'screens/doctor_registration_screen.dart';
import 'screens/login_screen.dart';

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
    return MaterialApp(
      title: 'Well Watch',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Use ThemeMode.system para seguir o tema do sistema
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Começa direto na tela de login
      routes: {
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/patient-registration': (context) => const PatientRegistrationScreen(),
        '/doctor-registration': (context) => const DoctorRegistrationScreen(),
      },
    );
  }
}
