import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/widgets/app_logo.dart';
import 'package:projetowell/models/app_data.dart';

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

class DoctorMenuPage extends StatelessWidget {
  const DoctorMenuPage({super.key});

  static const healthColors = {
    'primary': Color.fromARGB(255, 2, 31, 48), // SEU AZUL ESCURO
    'accent': Color(0xFF00B8A9),
    'warning': Color(0xFFE94E77),
    'info': Color(0xFF1BA6B8),
    'surface': Color(0xFFF5F9FF),
    'cardLight': Color(0xFFFFFFFF),
  };

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    final doctorName = auth.username ?? 'Médico';
    final specialty = auth.specialty ?? '';

    return Scaffold(
      backgroundColor: healthColors['surface'],
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
              const SizedBox(height: 8),

              // Cards Estatísticas (posicionados abaixo do cabeçalho)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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

              const SizedBox(height: 16),

              // MENU GRID
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
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AgendaPage())),
                    ),
                    RoundedFeatureButton(
                      label: 'Relatórios',
                      icon: Icons.bar_chart,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReportsPage())),
                    ),
                    RoundedFeatureButton(
                      label: 'Diabetes',
                      icon: Icons.show_chart,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DiabetesPage())),
                    ),
                    RoundedFeatureButton(
                      label: 'Pressão\nArterial',
                      icon: Icons.favorite,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BloodPressurePage())),
                    ),
                    RoundedFeatureButton(
                      label: 'Peso',
                      icon: Icons.monitor_weight,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WeightPage())),
                    ),
                    RoundedFeatureButton(
                      label: 'Pacientes',
                      icon: Icons.people,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PatientsPage())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomMenuBar(),
    );
  }
}

// ==========================
// DRAWER
// ==========================
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
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Agenda'),
            onTap: () {
              Navigator.pop(context);
              onNavigate('agenda');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Pacientes'),
            onTap: () {
              Navigator.pop(context);
              onNavigate('pacientes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            onTap: () {
              Navigator.pop(context);
              onNavigate('notificacoes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              onNavigate('config');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              onNavigate('perfil');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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

// ==========================
// HEADER
// ==========================
class _HeroHeader extends StatelessWidget {
  final String doctorName;
  final String specialty;

  const _HeroHeader({required this.doctorName, required this.specialty});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final baseHeight = 180.0;
    final height = baseHeight + topPad;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DoctorMenuPage.healthColors['primary']!,
              DoctorMenuPage.healthColors['primary']!.withOpacity(0.85),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top row: menu, small centered logo, notifications
              Row(
                children: [
                  Builder(builder: (ctx) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    );
                  }),
                  const Spacer(),
                  const AppLogo(size: 36),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage())),
                    icon: const Icon(Icons.notifications, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Welcome texts
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, $doctorName',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Especialidade: ${specialty.isNotEmpty ? specialty : "Não informada"}',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14),
                    ),
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

// ==========================
// ESTATÍSTICAS
// ==========================
class HealthStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const HealthStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// BOTÕES DO MENU
// ==========================
class RoundedFeatureButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const RoundedFeatureButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DoctorMenuPage.healthColors['primary']!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: DoctorMenuPage.healthColors['primary'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DoctorMenuPage.healthColors['primary']),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// BOTTOM MENU
// ==========================
class BottomMenuBar extends StatelessWidget {
  const BottomMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = DoctorMenuPage.healthColors['primary']!;
    return BottomAppBar(
      elevation: 8,
      color: Colors.white,
      notchMargin: 6,
      child: SizedBox(
        height: 72,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Settings
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Configurações',
                  icon: Icon(Icons.settings, color: primary),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()));
                  },
                ),
              ),
            ),

            // Center: Home as circular button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Right: Back
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Voltar',
                  icon: Icon(Icons.arrow_back, color: primary),
                  onPressed: () {
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
