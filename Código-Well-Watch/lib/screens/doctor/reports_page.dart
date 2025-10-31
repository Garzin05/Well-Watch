import 'package:flutter/material.dart';
import './doctor_theme.dart';
import '../../models/patient_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  final Patient? patient;

  const ReportsPage({super.key, this.patient});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<String> _periods = [
    '7 dias',
    '30 dias',
    '3 meses',
    '6 meses',
    '1 ano'
  ];
  String _selectedPeriod = '7 dias';
  Patient? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.patient;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: DoctorTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizada
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relatórios',
                          style: DoctorTheme.titleStyle,
                        ),
                        if (_selectedPatient != null)
                          Text(
                            'Paciente: ${_selectedPatient!.name}',
                            style: DoctorTheme.subtitleStyle,
                          ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.person_search, color: Colors.white),
                      onPressed: _showPatientSelector,
                    ),
                  ],
                ),
              ),
              // Seletor de período
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    final isSelected = period == _selectedPeriod;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(period),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPeriod = period);
                          }
                        },
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: DoctorTheme.primaryBlue,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Conteúdo principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _selectedPatient == null
                      ? _buildPatientSelector()
                      : _buildReports(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione um paciente',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no ícone de busca acima',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReports() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildGlucoseChart(),
        const SizedBox(height: 20),
        _buildPressureChart(),
        const SizedBox(height: 20),
        _buildWeightChart(),
        const SizedBox(height: 20),
        _buildHistoryTable(),
      ],
    );
  }

  Widget _buildGlucoseChart() {
    return _buildChartCard(
      title: 'Glicose',
      subtitle: 'mg/dL',
      chart: LineChart(
        LineChartData(
            // TODO: Implementar dados do gráfico
            ),
      ),
    );
  }

  Widget _buildPressureChart() {
    return _buildChartCard(
      title: 'Pressão Arterial',
      subtitle: 'mmHg',
      chart: LineChart(
        LineChartData(
            // TODO: Implementar dados do gráfico
            ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return _buildChartCard(
      title: 'Peso',
      subtitle: 'kg',
      chart: LineChart(
        LineChartData(
            // TODO: Implementar dados do gráfico
            ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: DoctorTheme.cardTitleStyle,
                ),
                const SizedBox(width: 8),
                Text(
                  '($subtitle)',
                  style: DoctorTheme.cardSubtitleStyle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico Diário',
              style: DoctorTheme.cardTitleStyle,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Glicose')),
                  DataColumn(label: Text('Pressão')),
                  DataColumn(label: Text('Peso')),
                ],
                rows: [], // TODO: Implementar dados da tabela
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientSelector() {
    // TODO: Implementar seletor de paciente
  }
}
