// Copied from lib/pages/home_page.dart
// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/theme.dart';
import 'package:projetowell/screens/main/diabetes_page.dart';
import 'package:projetowell/screens/main/blood_pressure_page.dart';
import 'package:projetowell/screens/main/weight_page.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Home selecionado por padrão
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final healthService = Provider.of<HealthService>(context);
    final username = authService.username ?? 'Usuário';

    // Obtém os últimos registros para exibição no dashboard
    final lastGlucose = healthService.glucoseRecords.isNotEmpty
        ? healthService.glucoseRecords.first
        : null;
    final lastBP = healthService.bpRecords.isNotEmpty
        ? healthService.bpRecords.first
        : null;
    final lastWeight = healthService.weightRecords.isNotEmpty
        ? healthService.weightRecords.first
        : null;

    // Data e hora formatadas
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final formattedDate = dateFormat.format(now);
    final formattedTime = timeFormat.format(now);

    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Cabeçalho do perfil
              _buildProfileHeader(username, formattedDate, formattedTime),

              // Barra de pesquisa
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Pesquisar',
                            hintStyle: TextStyle(
                              color:
                                  Colors.white.withAlpha((0.7 * 255).round()),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Conteúdo do menu
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Últimas medições
                      if (lastGlucose != null ||
                          lastBP != null ||
                          lastWeight != null) ...[
                        _buildSectionHeader('Últimas Medições'),
                        const SizedBox(height: 12),
                        if (lastGlucose != null)
                          HealthDataCard(
                            title: 'Glicose',
                            value: lastGlucose.formattedGlucose,
                            subtitle: 'Hoje, ${lastGlucose.time}',
                            icon: Icons.bloodtype,
                            valueColor: _getGlucoseColor(
                              lastGlucose.glucoseLevel,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DiabetesPage(),
                              ),
                            ),
                          ),
                        if (lastBP != null)
                          HealthDataCard(
                            title: 'Pressão Arterial',
                            value:
                                '${lastBP.systolic}/${lastBP.diastolic} mmHg',
                            subtitle: 'Hoje, ${lastBP.time}',
                            icon: Icons.favorite,
                            valueColor: _getBPColor(
                              lastBP.systolic,
                              lastBP.diastolic,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BloodPressurePage(),
                              ),
                            ),
                          ),
                        if (lastWeight != null)
                          HealthDataCard(
                            title: 'Peso',
                            value: lastWeight.formattedWeight,
                            subtitle: 'Hoje, ${lastWeight.time}',
                            icon: Icons.monitor_weight,
                            valueColor: AppColors.darkBlueBackground,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WeightPage(),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Seção pessoal
                      _buildSectionHeader('Monitoramento'),
                      const SizedBox(height: 12),
                      _buildHealthMonitoringGrid(),
                      const SizedBox(height: 24),

                      // Seção de atividade semanal
                      _buildSectionHeader('Atividade Semanal'),
                      const SizedBox(height: 12),
                      _buildWeeklyActivitySection(),
                    ],
                  ),
                ),
              ),

              // Navegação inferior
              Container(
                color: Colors.white,
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.person, 'Perfil'),
                      _buildNavItem(1, Icons.home, 'Início'),
                      _buildNavItem(2, Icons.message, 'Mensagens'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      String username, String formattedDate, String formattedTime) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Hero(
            tag: 'profile_image',
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.person,
                    color: AppColors.darkBlueBackground, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$formattedDate • $formattedTime',
                style: TextStyle(
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Row(
              children: [
                Text(
                  'Dados Cadastrais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkGrayText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (title == 'Monitoramento')
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.info_outline, color: Colors.grey[400], size: 18),
          ),
      ],
    );
  }

  Widget _buildHealthMonitoringGrid() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        MenuGridItem(
          icon: Icons.calendar_today,
          label: 'Agenda',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          },
        ),
        MenuGridItem(
          icon: Icons.favorite,
          label: 'Pressão Arterial',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BloodPressurePage(),
              ),
            );
          },
        ),
        MenuGridItem(
          icon: Icons.medical_services,
          label: 'Diabetes',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiabetesPage()),
            );
          },
        ),
        MenuGridItem(
          icon: Icons.monitor_weight,
          label: 'Peso',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeightPage()),
            );
          },
        ),
        MenuGridItem(
          icon: Icons.description,
          label: 'Relatórios',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          },
        ),
        MenuGridItem(
          icon: Icons.more_horiz,
          label: 'Outros',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyActivitySection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.lightBlueAccent.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActivityCard(
              'Atividade Física',
              Icons.directions_run,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildActivityCard(
              'Alimentação',
              Icons.restaurant_menu,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title: Funcionalidade em desenvolvimento')),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrayText,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Adicionar',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index != 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label: Funcionalidade em desenvolvimento'),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.darkBlueBackground : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkBlueBackground : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGlucoseColor(double level) {
    if (level < 70) return Colors.red; // Hipoglicemia
    if (level > 180) return Colors.orange; // Hiperglicemia
    return Colors.green; // Normal
  }

  Color _getBPColor(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) return Colors.red; // Hipertensão
    if (systolic >= 130 || diastolic >= 85) {
      return Colors.orange; // Pré-hipertensão
    }
    if (systolic < 90 || diastolic < 60) return Colors.red; // Hipotensão
    return Colors.green; // Normal
  }
}
