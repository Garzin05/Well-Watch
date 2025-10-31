import 'package:flutter/widgets.dart';
import 'package:projetowell/screens/auth.dart' as auth_screens;
import 'package:projetowell/screens/main_screens.dart' as main_screens;
import 'package:projetowell/screens/doctor/doctor_menu_page.dart';
import 'package:projetowell/screens/doctor/patients_page.dart';
import 'package:projetowell/screens/doctor/notifications_page.dart';
import 'package:projetowell/screens/doctor/profile_page.dart';

class AppRoutes {
  static const login = '/login';
  static const welcome = '/welcome';
  static const patientRegistration = '/patient-registration';
  static const doctorRegistration = '/doctor-registration';
  static const passwordRecovery = '/password-recovery';
  static const reports = '/reports';
  static const home = '/home';
  static const agenda = '/agenda';
  static const atividade = '/atividade';
  static const alimentacao = '/alimentacao';
  static const perfil = '/perfil';
  static const mensagem = '/mensagem';
  static const inicio = '/inicio';

  // Doctor routes
  static const doctorMenu = '/doctor/menu';
  static const doctorPatients = '/doctor/patients';
  static const doctorAppointments = '/doctor/appointments';
  static const doctorMedicalRecords = '/doctor/medical-records';
  static const doctorProfile = '/doctor/profile';
  static const addPatient = '/doctor/add-patient';
  static const scheduleAppointment = '/doctor/schedule-appointment';
  static const notifications = '/notifications';
}

Map<String, WidgetBuilder> appRoutes() {
  return {
    AppRoutes.login: (context) => const auth_screens.LoginScreen(),
    AppRoutes.welcome: (context) => const auth_screens.WelcomeScreen(),
    AppRoutes.patientRegistration: (context) =>
        const auth_screens.PatientRegistrationScreen(),
    AppRoutes.doctorRegistration: (context) =>
        const auth_screens.DoctorRegistrationScreen(),
    AppRoutes.passwordRecovery: (context) =>
        const auth_screens.PasswordRecoveryScreen(),
    AppRoutes.reports: (context) => const main_screens.ReportsPage(),
    AppRoutes.home: (context) => const main_screens.HomePage(),
    AppRoutes.agenda: (context) => const main_screens.AgendaPage(),
    AppRoutes.atividade: (context) => const main_screens.ActivityPage(),
    AppRoutes.alimentacao: (context) => const main_screens.AlimentacaoPage(),
    AppRoutes.perfil: (context) => const main_screens.PerfilPage(),
    AppRoutes.mensagem: (context) => const main_screens.MensagemPage(),
    AppRoutes.inicio: (context) => const main_screens.InicioPage(),

    // Doctor routes
    AppRoutes.doctorMenu: (context) => const DoctorMenuPage(),
    AppRoutes.doctorPatients: (context) => const PatientsPage(),
    AppRoutes.doctorProfile: (context) => const ProfilePage(),
    AppRoutes.notifications: (context) => const NotificationsPage(),
  };
}
