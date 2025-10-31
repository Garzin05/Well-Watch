import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/theme.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _reports = [];
  String _selectedPeriod = 'Semana';
  String _selectedMetric = 'Todos';
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    // Adicionar alguns relatórios de exemplo
    _reports.addAll([
      {
        'title': 'Relatório Mensal - Maio 2024',
        'type': 'Completo',
        'date': '01/05/2024',
        'metrics': ['Glicose', 'Pressão', 'Peso'],
      },
      {
        'title': 'Análise de Glicemia - Abril 2024',
        'type': 'Específico',
        'date': '30/04/2024',
        'metrics': ['Glicose'],
      },
      {
        'title': 'Evolução Trimestral',
        'type': 'Completo',
        'date': '31/03/2024',
        'metrics': ['Glicose', 'Pressão', 'Peso', 'Atividades'],
      },
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildMetricFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          'Todos',
          'Glicose',
          'Pressão',
          'Peso',
          'Atividades',
          'Alimentação',
        ].map((metric) {
          final isSelected = _selectedMetric == metric;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(metric),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMetric = metric;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.darkBlueBackground,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          'Hoje',
          'Semana',
          'Mês',
          'Trimestre',
          'Ano',
        ].map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.darkBlueBackground,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildReportCard(
          title: 'Média de Glicose',
          value: '120 mg/dL',
          trend: '↓ 5% em relação ao período anterior',
          icon: Icons.bloodtype,
          color: Colors.red,
        ),
        _buildReportCard(
          title: 'Média de Pressão Arterial',
          value: '120/80 mmHg',
          trend: '↔ Estável em relação ao período anterior',
          icon: Icons.favorite,
          color: Colors.red,
        ),
        _buildReportCard(
          title: 'Peso Médio',
          value: '75.5 kg',
          trend: '↑ 1% em relação ao período anterior',
          icon: Icons.monitor_weight,
          color: AppColors.weightColor,
        ),
        _buildReportCard(
          title: 'Atividades Físicas',
          value: '3.5h/semana',
          trend: '↑ 15% em relação ao período anterior',
          icon: Icons.directions_run,
          color: Colors.blue,
        ),
        _buildReportCard(
          title: 'Refeições Registradas',
          value: '21 refeições',
          trend: '↔ Estável em relação ao período anterior',
          icon: Icons.restaurant_menu,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return ListView.builder(
      itemCount: _reports.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final report = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              report['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Tipo: ${report['type']}'),
                Text('Data: ${report['date']}'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: (report['metrics'] as List<String>).map((metric) {
                    return Chip(
                      label: Text(
                        metric,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Download do relatório iniciado')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? AppColors.darkBlueBackground),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createReport() async {
    final titleController = TextEditingController();
    final List<String> selectedMetrics = [];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Criar Novo Relatório'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Título do Relatório'),
              ),
              const SizedBox(height: 16),
              const Text('Selecione as Métricas:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'Glicose',
                  'Pressão',
                  'Peso',
                  'Atividades',
                  'Alimentação',
                ].map((metric) {
                  return FilterChip(
                    label: Text(metric),
                    selected: selectedMetrics.contains(metric),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedMetrics.add(metric);
                        } else {
                          selectedMetrics.remove(metric);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    selectedMetrics.isNotEmpty) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Preencha o título e selecione ao menos uma métrica'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlueBackground,
              ),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      setState(() {
        _reports.insert(0, {
          'title': titleController.text,
          'type': selectedMetrics.length > 2 ? 'Completo' : 'Específico',
          'date': DateTime.now().toString().split(' ')[0],
          'metrics': selectedMetrics,
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório criado com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDoctor = authService.role == 'doctor';

    // Todos os usuários podem visualizar o conteúdo dos relatórios, mas apenas médicos
    // podem criar novos relatórios (FAB visível somente para médicos)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: AppColors.darkBlueBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Relatórios'),
          ],
        ),
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton(
              onPressed: _createReport,
              backgroundColor: AppColors.darkBlueBackground,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          if (_currentTab == 0) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Período',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildPeriodFilter(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Métricas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildMetricFilter(),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
