import 'package:flutter/material.dart';
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
  int _selectedIndex = 0; // Monitoramento selecionado por padrão
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controller e estado para busca na Home
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

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
    _searchController.dispose();
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
                          controller: _searchController,
                          onChanged: (v) =>
                              setState(() => _searchTerm = v.trim()),
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
                      // Últimas medições (não exibe quando há busca ativa)
                      if (_searchTerm.isEmpty &&
                          (lastGlucose != null ||
                              lastBP != null ||
                              lastWeight != null)) ...[
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
                            iconColor: _getGlucoseColor(
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
                            iconColor: _getBPColor(
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
                            valueColor:
                                const Color.fromARGB(255, 110, 142, 177),
                            iconColor: AppColors.weightColor,
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

              // Navegação inferior (removido botão "Início")
              Builder(builder: (context) {
                final authService = Provider.of<AuthService>(context);
                final isDoctor = authService.role == 'doctor';
                return Container(
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
                        _buildNavItem(0, Icons.monitor_heart, 'Monitoramento'),
                        if (isDoctor)
                          _buildNavItem(1, Icons.description, 'Relatórios'),
                      ],
                    ),
                  ),
                );
              }),
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
              child: Center(
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 16),
                  SizedBox(width: 6),
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
            color: Color.fromARGB(255, 124, 122, 122),
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
    final authService = Provider.of<AuthService>(context);
    final isDoctor = authService.role == 'doctor';

    // Construir lista de itens e aplicar filtro de busca quando houver
    final items = <Widget>[];

    void addItem(IconData icon, String label, Color color, VoidCallback onTap) {
      if (_searchTerm.isEmpty ||
          label.toLowerCase().contains(_searchTerm.toLowerCase())) {
        items.add(MenuGridItem(
            icon: icon, label: label, iconColor: color, onTap: onTap));
      }
    }

    addItem(Icons.calendar_today, 'Agenda', AppColors.agenda, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AgendaPage()),
      );
    });

    addItem(Icons.favorite, 'Pressão Arterial', AppColors.bpHigh, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodPressurePage()),
      );
    });

    // Mostrar como 'Glicose' no grid (apenas label exibida)
    addItem(Icons.medical_services, 'Glicose', AppColors.diabetes, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiabetesPage()),
      );
    });

    addItem(Icons.monitor_weight, 'Peso', AppColors.weightColor, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeightPage()),
      );
    });

    // Novas seções solicitadas
    addItem(Icons.directions_run, 'Atividade Física', Colors.blue, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActivityPage()),
      );
    });

    addItem(Icons.restaurant_menu, 'Alimentação', Colors.green, () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AlimentacaoPage()),
      );
    });

    // Para médico, permitir relatórios via grid; para paciente, mostrar opção de ver relatórios
    if (isDoctor) {
      addItem(Icons.description, 'Relatórios', AppColors.reports, () {
        Navigator.pushNamed(context, AppRoutes.reports);
      });
    } else {
      addItem(Icons.description, 'Ver Relatórios', AppColors.reports, () {
        Navigator.pushNamed(context, AppRoutes.reports);
      });
    }

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: items,
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityPage()),
                );
              },
            ),
          ),
          Expanded(
            child: _buildActivityCard(
              'Alimentação',
              Icons.restaurant_menu,
              Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AlimentacaoPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('$title: Funcionalidade em desenvolvimento')),
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

        // Navega para páginas específicas conforme o rótulo (mais resiliente que índices)
        final lower = label.toLowerCase();
        if (lower.contains('relat')) {
          Navigator.pushNamed(context, AppRoutes.reports);
        } else if (lower.contains('início') || lower.contains('inicio')) {
          Navigator.pushNamed(context, AppRoutes.inicio);
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

