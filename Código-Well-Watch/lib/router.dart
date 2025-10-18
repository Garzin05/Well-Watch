import 'package:flutter/widgets.dart';
import 'package:projetowell/screens/auth.dart' as auth_screens;
import 'package:projetowell/screens/main_screens.dart' as main_screens;

class AppRoutes {
  static const login = '/login';
  static const welcome = '/welcome';
  static const patientRegistration = '/patient-registration';
  static const doctorRegistration = '/doctor-registration';
  static const home = '/home';
}

Map<String, WidgetBuilder> appRoutes() {
  return {
    AppRoutes.login: (context) => const auth_screens.LoginScreen(),
    AppRoutes.welcome: (context) => const auth_screens.WelcomeScreen(),
    AppRoutes.patientRegistration: (context) =>
        const auth_screens.PatientRegistrationScreen(),
    AppRoutes.doctorRegistration: (context) =>
        const auth_screens.DoctorRegistrationScreen(),
    AppRoutes.home: (context) => const main_screens.HomePage(),
  };
}
