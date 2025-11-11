import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projetowell/widgets/app_logo.dart';

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

// Mock dos dados (substitua pelo seu AppData)
class AppData extends ChangeNotifier {
  int get alertsCount => 3;
  int get todayAppointmentsCount => 5;
  List<String> get patients => ['Paciente 1', 'Paciente 2'];

  get appointments => null;

  get selectedPatient => null;

  get notifications => null;

  void addAppointment({required DateTime dateTime, required String patientId, required String note}) {}

  void addVital({required patientId, required DateTime date, required int systolic, required int diastolic, required double glucoseMgDl}) {}

  void selectPatient(String p) {}
}

final appData = AppData();

class DoctorMenuPage extends StatelessWidget {
  const DoctorMenuPage({super.key});

  // Paleta de cores médicas
  static const healthColors = {
    'primary': Color.fromARGB(255, 2, 31, 48),     // Azul médico principal
    'accent': Color(0xFF00B8A9),      // Verde água hospitalar
    'warning': Color(0xFFE94E77),     // Rosa alerta
    'info': Color(0xFF1BA6B8),        // Azul informação
    'surface': Color(0xFFF5F9FF),     // Fundo suave
    'cardLight': Color(0xFFFFFFFF),   // Branco cartões
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: healthColors['surface'],
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 32), // Substituindo o ícone pelo logo
            const SizedBox(height: 8), // Espaçamento entre o logo e o texto
            Text(
              'Well Watch',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
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
      drawer: _MainDrawer(onNavigate: (route) {
        switch (route) {
          case 'relatorios':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ReportsPage()));
            break;
          case 'agenda':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AgendaPage()));
            break;
          case 'pacientes':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PatientsPage()));
            break;
          case 'notificacoes':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()));
            break;
          case 'config':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            break;
          case 'perfil':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
          case 'sair':
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Sessão encerrada.')));
            break;
        }
      }),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ReportsPage()));
          } else if (i == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AgendaPage()));
          } else if (i == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PatientsPage()));
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Relatórios'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(
              icon: Icon(Icons.people), label: 'Pacientes'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeader(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(
                  onChanged: (v) {},
                  onSubmitted: (v) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PatientsPage(initialQuery: v)));
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                            context, MaterialPageRoute(builder: (_) => const AgendaPage()))),
                    RoundedFeatureButton(
                        label: 'Relatórios',
                        icon: Icons.bar_chart,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const ReportsPage()))),
                    RoundedFeatureButton(
                        label: 'Diabetes',
                        icon: Icons.show_chart,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const DiabetesPage()))),
                    RoundedFeatureButton(
                        label: 'Pressão\nArterial',
                        icon: Icons.favorite,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const BloodPressurePage()))),
                    RoundedFeatureButton(
                        label: 'Peso',
                        icon: Icons.monitor_weight,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const WeightPage()))),
                    RoundedFeatureButton(
                        label: 'Pacientes',
                        icon: Icons.people,
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const PatientsPage()))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Atividade Semanal',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: DoctorMenuPage.healthColors['primary'])),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const _WeeklyActivityCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
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
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BlobPainter(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, Dr. Silva',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitore seus pacientes e agenda',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _HeroChip(
                      icon: Icons.calendar_today,
                      label: '${appData.todayAppointmentsCount} consultas hoje',
                    ),
                    const SizedBox(width: 12),
                    _HeroChip(
                      icon: Icons.warning,
                      label: '${appData.alertsCount} alertas',
                      isWarning: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;

  const _HeroChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning
            ? DoctorMenuPage.healthColors['warning']!.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthStatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const HealthStatCard({super.key, 
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  State<HealthStatCard> createState() => _HealthStatCardState();
}

class _HealthStatCardState extends State<HealthStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DoctorMenuPage.healthColors['cardLight'],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 24),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final Function(String) onChanged;
  final Function(String) onSubmitted;

  const _SearchField({required this.onChanged, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Buscar pacientes...',
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class RoundedFeatureButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const RoundedFeatureButton({super.key, 
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<RoundedFeatureButton> createState() => _RoundedFeatureButtonState();
}

class _RoundedFeatureButtonState extends State<RoundedFeatureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = DoctorMenuPage.healthColors['primary']!;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: _ActivityPill(
                  day: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'][index],
                  value: [0.3, 0.5, 0.8, 0.4, 0.6, 0.9, 0.7][index],
                  color: DoctorMenuPage.healthColors['primary']!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityPill extends StatelessWidget {
  final String day;
  final double value;
  final Color color;

  const _ActivityPill({
    required this.day,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100 * value,
              width: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const _MainDrawer({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: DoctorMenuPage.healthColors['primary'],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dr. Silva',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Cardiologista',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
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
          // Outros itens de menu...
        ],
      ),
    );
  }
}
