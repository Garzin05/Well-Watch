import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projetowell/models/app_data.dart';
import 'package:projetowell/widgets/patient_selector.dart';
import 'package:projetowell/services/api_service.dart';

class DiabetesPage extends StatefulWidget {
  const DiabetesPage({super.key});

  @override
  State<DiabetesPage> createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> {
  Patient? _selectedPatient;
  final TextEditingController _glucoseController = TextEditingController();

  // Standardized colors
  static const primaryColor = Color.fromARGB(255, 2, 31, 48); // Dark Navy Blue
  static const accentColor = Color(0xFF00B8A9); // Teal

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  void _handlePatientSelected(Patient patient) {
    setState(() {
      _selectedPatient = patient;
    });

    // Carrega medições de glicose do paciente da API
    _loadGlucoseMeasurements(patient.id);
  }

  Future<void> _loadGlucoseMeasurements(String patientId) async {
    try {
      final measurements = await ApiService.getGlucoseMeasurements(patientId);
      if (mounted && measurements.isNotEmpty) {
        setState(() {
          if (_selectedPatient != null) {
            _selectedPatient = Patient(
              id: _selectedPatient!.id,
              name: _selectedPatient!.name,
              records: [
                ..._selectedPatient!.records
                    .where((r) => r.glucoseMgDl == null),
                ...measurements,
              ],
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[DiabetesPage] Erro ao carregar medições: $e');
    }
  }

  void _addGlucoseDialog() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um paciente primeiro")),
      );
      return;
    }

    _glucoseController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Adicionar Glicose",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: _glucoseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Glicose (mg/dL)",
              labelStyle: const TextStyle(color: primaryColor),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                final value = double.tryParse(
                  _glucoseController.text.replaceAll(",", "."),
                );
                if (value != null && value > 0) {
                  final appData = Patient(
                    id: _selectedPatient!.id,
                    name: _selectedPatient!.name,
                    records: [
                      ..._selectedPatient!.records,
                      VitalRecord(
                        date: DateTime.now(),
                        glucoseMgDl: value,
                      ),
                    ],
                  );

                  setState(() {
                    _selectedPatient = appData;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Registro adicionado com sucesso!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Valor inválido")),
                  );
                }
              },
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  List<VitalRecord> _getGlucoseRecords() {
    if (_selectedPatient == null) return [];
    return _selectedPatient!.records
        .where((r) => r.glucoseMgDl != null)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> _calculateStatistics() {
    final records = _getGlucoseRecords();
    if (records.isEmpty) return {'average': 0, 'max': 0, 'min': 0};

    final values = records.map((r) => r.glucoseMgDl!).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return {
      'average': average,
      'max': max,
      'min': min,
    };
  }

  Widget _buildGlucoseChart() {
    final records = _getGlucoseRecords();
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Nenhum registro de glicose',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort by date (ascending for chart)
    final sortedRecords = [...records]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Limit to last 30 records for chart clarity
    final chartRecords = sortedRecords.length > 30
        ? sortedRecords.sublist(sortedRecords.length - 30)
        : sortedRecords;

    final spots = <FlSpot>[];
    for (int i = 0; i < chartRecords.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), chartRecords[i].glucoseMgDl!),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 50,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 0.5,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (chartRecords.length / 6).ceil().toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartRecords.length) {
                    final date = chartRecords[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('d/M').format(date),
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accentColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: accentColor,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: accentColor.withOpacity(0.2),
              ),
            ),
          ],
          minY: 0,
          maxY: (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final stats = _calculateStatistics();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          label: 'Média',
          value: stats['average']!.toStringAsFixed(1),
          icon: Icons.trending_up,
        ),
        _buildStatCard(
          label: 'Máxima',
          value: stats['max']!.toStringAsFixed(0),
          icon: Icons.arrow_upward,
        ),
        _buildStatCard(
          label: 'Mínima',
          value: stats['min']!.toStringAsFixed(0),
          icon: Icons.arrow_downward,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final records = _getGlucoseRecords();

    if (records.isEmpty) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Nenhum registro',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.bloodtype,
                color: accentColor,
              ),
            ),
            title: Text(
              '${record.glucoseMgDl!.toStringAsFixed(1)} mg/dL',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(record.date),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              _getGlucoseStatus(record.glucoseMgDl!),
              color: _getGlucoseStatusColor(record.glucoseMgDl!),
            ),
          ),
        );
      },
    );
  }

  IconData _getGlucoseStatus(double glucose) {
    if (glucose < 70) return Icons.arrow_downward;
    if (glucose > 180) return Icons.arrow_upward;
    return Icons.check_circle;
  }

  Color _getGlucoseStatusColor(double glucose) {
    if (glucose < 70) return Colors.blue; // Low
    if (glucose > 180) return Colors.red; // High
    return Colors.green; // Normal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diabetes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Patient selector
          PatientSelector(
            patients: appData.patients,
            selectedPatient: _selectedPatient,
            onPatientSelected: _handlePatientSelected,
          ),
          // Main content
          if (_selectedPatient != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient title
                    Text(
                      'Registros de ${_selectedPatient!.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Chart
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildGlucoseChart(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Statistics
                    _buildStatisticsCards(),
                    const SizedBox(height: 16),
                    // History header
                    const Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Records list
                    _buildRecordsList(),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  'Selecione um paciente para visualizar dados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedPatient != null
          ? FloatingActionButton.extended(
              onPressed: _addGlucoseDialog,
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            )
          : null,
    );
  }
}
