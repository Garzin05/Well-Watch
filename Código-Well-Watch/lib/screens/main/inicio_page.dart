import 'package:flutter/material.dart';
import 'package:projetowell/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/router.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: color ?? AppColors.darkBlueBackground, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================
  // RESUMO DE SAÚDE — CORRIGIDO 
  // =======================================================
  Widget _buildHealthSummaryCard(
      BuildContext context, HealthService healthService) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = int.tryParse(auth.userId ?? '0') ?? 0;

    final glucoseList = healthService.getGlucoseForDate(userId, DateTime.now());
    final bpList = healthService.getBPForDate(userId, DateTime.now());
    final weightList = healthService.getWeightForDate(userId, DateTime.now());

    final lastGlucose = glucoseList.isNotEmpty ? glucoseList.first : null;
    final lastBP = bpList.isNotEmpty ? bpList.first : null;
    final lastWeight = weightList.isNotEmpty ? weightList.first : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo do dia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (lastGlucose != null)
              _buildHealthMetric(
                'Glicose',
                lastGlucose.formattedGlucose,
                Icons.bloodtype,
                Colors.red,
              ),

            if (lastBP != null)
              _buildHealthMetric(
                'Pressão Arterial',
                '${lastBP.systolic}/${lastBP.diastolic} mmHg',
                Icons.favorite,
                Colors.red,
              ),

            if (lastWeight != null)
              _buildHealthMetric(
                'Peso',
                lastWeight.formattedWeight,
                Icons.monitor_weight,
                AppColors.weightColor,
              ),

            if (lastGlucose == null && lastBP == null && lastWeight == null)
              const Text(
                'Nenhuma medição registrada hoje',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDoctor) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        if (isDoctor) ...[
          _buildActionCard(
            title: 'Relatórios',
            icon: Icons.assessment,
            description: 'Visualize relatórios e análises dos pacientes',
            onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
            color: AppColors.reports,
          ),
          _buildActionCard(
            title: 'Agenda',
            icon: Icons.calendar_today,
            description: 'Gerencie suas consultas e compromissos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.agenda),
            color: AppColors.agenda,
          ),
        ] else ...[
          _buildActionCard(
            title: 'Monitoramento',
            icon: Icons.monitor_heart,
            description: 'Registre e acompanhe seus dados de saúde',
            onTap: () => Navigator.pushNamed(context, AppRoutes.home),
            color: Colors.red,
          ),
          _buildActionCard(
            title: 'Atividades',
            icon: Icons.directions_run,
            description: 'Registre suas atividades físicas',
            onTap: () => Navigator.pushNamed(context, AppRoutes.atividade),
            color: Colors.blue,
          ),
        ],
        _buildActionCard(
          title: 'Alimentação',
          icon: Icons.restaurant_menu,
          description: 'Registre suas refeições diárias',
          onTap: () => Navigator.pushNamed(context, AppRoutes.alimentacao),
          color: Colors.green,
        ),
        _buildActionCard(
          title: 'Perfil',
          icon: Icons.person,
          description: 'Atualize suas informações pessoais',
          onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
          color: Colors.purple,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final healthService = Provider.of<HealthService>(context);
    final isDoctor = auth.role == 'doctor';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkBlueBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Bem-vindo, ${auth.username ?? 'Usuário'}'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.darkBlueBackground,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDoctor ? 'Perfil Médico' : 'Perfil Paciente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDoctor) _buildHealthSummaryCard(context, healthService),
                  const SizedBox(height: 24),
                  const Text(
                    'Acesso Rápido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, isDoctor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
