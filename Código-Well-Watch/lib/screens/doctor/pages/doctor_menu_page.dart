import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/widgets/app_logo.dart';
import 'package:projetowell/services/auth_service.dart';

// Importar suas páginas
import 'reports_page.dart';
import 'agenda_page.dart';
import 'patients_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'diabetes_page.dart';
import 'blood_pressure_page.dart';
import 'weight_page.dart';

// Mock de dados (para estatísticas, pode substituir por backend real)
class AppData extends ChangeNotifier {
  int get alertsCount => 3;
  int get todayAppointmentsCount => 5;
  List<String> get patients => ['Paciente 1', 'Paciente 2'];
}

final appData = AppData();

class DoctorMenuPage extends StatelessWidget {
  const DoctorMenuPage({super.key});

  static const healthColors = {
    'primary': Color.fromARGB(255, 2, 31, 48),
    'accent': Color(0xFF00B8A9),
    'warning': Color(0xFFE94E77),
    'info': Color(0xFF1BA6B8),
    'surface': Color(0xFFF5F9FF),
    'cardLight': Color(0xFFFFFFFF),
  };

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context); // pega usuário logado
    final doctorName = auth.username ?? 'Médico';
    final specialty = auth.specialty ?? '';

    return Scaffold(
      backgroundColor: healthColors['surface'],
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 32),
            const SizedBox(height: 8),
            Text(
              'Well Watch',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'Notificações',
          ),
        ],
        backgroundColor: healthColors['primary'],
      ),
      drawer: _MainDrawer(
        doctorName: doctorName,
        specialty: specialty,
        onNavigate: (route) {
          switch (route) {
            case 'relatorios':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportsPage()));
              break;
            case 'agenda':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AgendaPage()));
              break;
            case 'pacientes':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PatientsPage()));
              break;
            case 'notificacoes':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()));
              break;
            case 'config':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
              break;
            case 'perfil':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              break;
            case 'sair':
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeader(doctorName: doctorName, specialty: specialty),
              const SizedBox(height: 16),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedBuilder(
                    animation: appData,
                    builder: (context, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: HealthStatCard(
                              icon: Icons.people,
                              label: 'Pacientes',
                              value: appData.patients.length.toString(),
                              color: const Color(0xFF1BA6B8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HealthStatCard(
                              icon: Icons.warning,
                              label: 'Alertas',
                              value: appData.alertsCount.toString(),
                              color: const Color(0xFFE94E77),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HealthStatCard(
                              icon: Icons.calendar_today,
                              label: 'Hoje',
                              value: appData.todayAppointmentsCount.toString(),
                              color: const Color(0xFF00B8A9),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    RoundedFeatureButton(
                        label: 'Agenda',
                        icon: Icons.calendar_month,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AgendaPage()))),
                    RoundedFeatureButton(
                        label: 'Relatórios',
                        icon: Icons.bar_chart,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ReportsPage()))),
                    RoundedFeatureButton(
                        label: 'Diabetes',
                        icon: Icons.show_chart,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const DiabetesPage()))),
                    RoundedFeatureButton(
                        label: 'Pressão\nArterial',
                        icon: Icons.favorite,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const BloodPressurePage()))),
                    RoundedFeatureButton(
                        label: 'Peso',
                        icon: Icons.monitor_weight,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const WeightPage()))),
                    RoundedFeatureButton(
                        label: 'Pacientes',
                        icon: Icons.people,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PatientsPage()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------
// Drawer
// --------------------------
class _MainDrawer extends StatelessWidget {
  final Function(String) onNavigate;
  final String doctorName;
  final String specialty;

  const _MainDrawer(
      {required this.onNavigate,
      required this.doctorName,
      required this.specialty});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: DoctorMenuPage.healthColors['primary']),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 40, color: Colors.blue)),
                const SizedBox(height: 12),
                Text(doctorName,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Text(specialty,
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('relatorios');
              }),
          ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Agenda'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('agenda');
              }),
          ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Pacientes'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('pacientes');
              }),
          ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('notificacoes');
              }),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('config');
              }),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                onNavigate('perfil');
              }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              onNavigate('sair');
            },
          ),
        ],
      ),
    );
  }
}

// --------------------------
// Header
// --------------------------
class _HeroHeader extends StatelessWidget {
  final String doctorName;
  final String specialty;

  const _HeroHeader({required this.doctorName, required this.specialty});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DoctorMenuPage.healthColors['primary']!,
            DoctorMenuPage.healthColors['primary']!.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, $doctorName',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Especialidade: ${specialty.isNotEmpty ? specialty : "Não informada"}',
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --------------------------
// Estatísticas
// --------------------------
class HealthStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const HealthStatCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600, color: color)),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// --------------------------
// Botões do menu
// --------------------------
class RoundedFeatureButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const RoundedFeatureButton(
      {super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: DoctorMenuPage.healthColors['primary']!.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: DoctorMenuPage.healthColors['primary']),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
