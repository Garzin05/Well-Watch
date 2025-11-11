// ==============================================
// lib/screens/main/home_page.dart (versão premium atualizada)
// ==============================================

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projetowell/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/screens/main/diabetes_page.dart';
import 'package:projetowell/screens/main/blood_pressure_page.dart';
import 'package:projetowell/screens/main/weight_page.dart';
import 'package:projetowell/screens/main/agenda_page.dart';
import 'package:projetowell/screens/main/activity_page.dart';
import 'package:projetowell/screens/main/alimentacao_page.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:projetowell/router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final healthService = Provider.of<HealthService>(context);
    final username = authService.username ?? 'Usuário';

    final lastGlucose = healthService.glucoseRecords.isNotEmpty ? healthService.glucoseRecords.first : null;
    final lastBP = healthService.bpRecords.isNotEmpty ? healthService.bpRecords.first : null;
    final lastWeight = healthService.weightRecords.isNotEmpty ? healthService.weightRecords.first : null;

    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildProfileHeader(username, formattedDate, formattedTime),

              // 🔍 Barra de pesquisa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(Icons.search, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchTerm = v.trim()),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Pesquisar...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🩺 Conteúdo principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      if (_searchTerm.isEmpty && (lastGlucose != null || lastBP != null || lastWeight != null)) ...[
                        _buildSectionHeader('Últimas Medições'),
                        const SizedBox(height: 16),

                        if (lastGlucose != null)
                          HealthDataCard(
                            title: 'Glicose',
                            value: lastGlucose.formattedGlucose,
                            subtitle: 'Hoje, ${lastGlucose.time}',
                            icon: Lottie.asset('assets/lottie/diabetes.json', height: 120, fit: BoxFit.contain),
                            valueColor: _getGlucoseColor(lastGlucose.glucoseLevel),
                            iconColor: _getGlucoseColor(lastGlucose.glucoseLevel),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DiabetesPage())),
                          ),

                        if (lastBP != null)
                          HealthDataCard(
                            title: 'Pressão Arterial',
                            value: '${lastBP.systolic}/${lastBP.diastolic} mmHg',
                            subtitle: 'Hoje, ${lastBP.time}',
                            icon: Lottie.asset('assets/lottie/heart.json', height: 120, fit: BoxFit.contain),
                            valueColor: _getBPColor(lastBP.systolic, lastBP.diastolic),
                            iconColor: _getBPColor(lastBP.systolic, lastBP.diastolic),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BloodPressurePage())),
                          ),

                        if (lastWeight != null)
                          HealthDataCard(
                            title: 'Peso',
                            value: lastWeight.formattedWeight,
                            subtitle: 'Hoje, ${lastWeight.time}',
                            icon: Lottie.asset('assets/lottie/weigth.json', height: 120, fit: BoxFit.contain),
                            valueColor: const Color(0xFF6E8EB1),
                            iconColor: AppColors.weightColor,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeightPage())),
                          ),
                        const SizedBox(height: 28),
                      ],

                      _buildSectionHeader('Monitoramento'),
                      const SizedBox(height: 16),
                      _buildHealthMonitoringGrid(),
                      const SizedBox(height: 28),

                      _buildSectionHeader('Atividade Semanal'),
                      const SizedBox(height: 16),
                      _buildWeeklyActivitySection(),
                    ],
                  ),
                ),
              ),

              _buildBottomNav(authService),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // 🔹 Cabeçalho do perfil
  // =====================================================
  Widget _buildProfileHeader(String username, String date, String time) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Hero(
            tag: 'profile_image',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.person, color: AppColors.darkBlueBackground, size: 34),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('$date • $time', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 🔹 Seções e cards
  // =====================================================
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.darkGrayText, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
      ],
    );
  }

  Widget _buildHealthMonitoringGrid() {
    final authService = Provider.of<AuthService>(context);
    final isDoctor = authService.role == 'doctor';

    final items = <Widget>[];

    void addItem(String label, String asset, VoidCallback onTap) {
      if (_searchTerm.isEmpty || label.toLowerCase().contains(_searchTerm.toLowerCase())) {
        items.add(MenuGridItem(label: label, lottieAsset: asset, onTap: onTap, lottieHeight: 140));
      }
    }

    addItem('Agenda', 'assets/lottie/agenda.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaPage())));
    addItem('Pressão Arterial', 'assets/lottie/heart.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodPressurePage())));
    addItem('Glicose', 'assets/lottie/diabetes.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiabetesPage())));
    addItem('Peso', 'assets/lottie/weigth.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightPage())));
    addItem('Atividade Física', 'assets/lottie/activity.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityPage())));
    addItem('Alimentação', 'assets/lottie/nutrition.json', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlimentacaoPage())));

    addItem(isDoctor ? 'Relatórios Médicos' : 'Ver Relatórios', 'assets/lottie/doctor.json',
        () => Navigator.pushNamed(context, AppRoutes.reports));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      children: items,
    );
  }

  Widget _buildWeeklyActivitySection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: AppColors.lightBlueAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _buildActivityCard('Atividade Física', 'assets/lottie/activity.json', Colors.blue, const ActivityPage())),
          Expanded(child: _buildActivityCard('Alimentação', 'assets/lottie/nutrition.json', Colors.green, const AlimentacaoPage())),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String asset, Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(asset, height: 100, width: 100, repeat: true, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.withOpacity(0.9))),
            const SizedBox(height: 8),
            Text('Adicionar', style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AuthService authService) {
    final isDoctor = authService.role == 'doctor';
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'assets/lottie/monitoring.json', 'Monitoramento'),
          if (isDoctor) _buildNavItem(1, 'assets/lottie/doctor.json', 'Relatórios'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String asset, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (label.toLowerCase().contains('relat')) {
          Navigator.pushNamed(context, AppRoutes.reports);
        } else {
          Navigator.pushNamed(context, AppRoutes.inicio);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 35, width: 35, child: Lottie.asset(asset, repeat: true, fit: BoxFit.contain)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkBlueBackground : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 🔹 Funções de cor
  // =====================================================
  Color _getGlucoseColor(double level) {
    if (level < 70) return Colors.red;
    if (level > 180) return Colors.orange;
    return Colors.green;
  }

  Color _getBPColor(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) return Colors.red;
    if (systolic >= 130 || diastolic >= 85) return Colors.orange;
    if (systolic < 90 || diastolic < 60) return Colors.red;
    return Colors.green;
  }
}
