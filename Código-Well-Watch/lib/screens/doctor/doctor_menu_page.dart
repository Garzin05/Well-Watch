import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import './doctor_theme.dart';
import 'package:intl/intl.dart';

class DoctorMenuPage extends StatefulWidget {
  const DoctorMenuPage({super.key});

  @override
  State<DoctorMenuPage> createState() => _DoctorMenuPageState();
}

class _DoctorMenuPageState extends State<DoctorMenuPage> {
  late String formattedDate;
  late String formattedTime;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    formattedDate = dateFormat.format(now);
    formattedTime = timeFormat.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final username = authService.username ?? 'Doutor';

    return Scaffold(
      backgroundColor: DoctorTheme.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(username),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Menu Principal'),
                      const SizedBox(height: 16),
                      _buildMenuGrid(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Atalhos Rápidos'),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: DoctorTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dr. $username',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$formattedDate • $formattedTime',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 28),
            onPressed: () {
              // Navegar para NotificationsPage
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: DoctorTheme.primaryBlue,
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'title': 'Pacientes',
        'icon': Icons.people,
        'color': Colors.blue,
        'route': '/patients',
      },
      {
        'title': 'Agenda',
        'icon': Icons.calendar_today,
        'color': Colors.green,
        'route': '/agenda',
      },
      {
        'title': 'Relatórios',
        'icon': Icons.insert_chart,
        'color': Colors.orange,
        'route': '/reports',
      },
      {
        'title': 'Configurações',
        'icon': Icons.settings,
        'color': Colors.purple,
        'route': '/settings',
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems.map((item) {
        return _buildMenuItem(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
          onTap: () {
            Navigator.pushNamed(context, item['route'] as String);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            title: 'Adicionar\nPaciente',
            icon: Icons.person_add,
            color: Colors.cyan,
            onTap: () {
              // Navegar para tela de adicionar paciente
              Navigator.pushNamed(context, '/add-patient');
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickAction(
            title: 'Agendar\nConsulta',
            icon: Icons.add_circle_outline,
            color: Colors.amber,
            onTap: () {
              // Navegar para tela de agendamento
              Navigator.pushNamed(context, '/schedule-appointment');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
