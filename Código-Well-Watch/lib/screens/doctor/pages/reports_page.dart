import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projetowell/models/app_data.dart';
import 'package:projetowell/widgets/patient_selector.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Patient? _selectedPatient;

  static const primaryColor = Color.fromARGB(255, 2, 31, 48);
  static const accentColor = Color(0xFFE94E77);

  void _handlePatientSelected(Patient patient) {
    setState(() => _selectedPatient = patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 0,
            child: PatientSelector(
              patients: appData.patients,
              selectedPatient: _selectedPatient,
              onPatientSelected: _handlePatientSelected,
            ),
          ),
          if (_selectedPatient != null && _selectedPatient!.records.isNotEmpty)
            Expanded(
              flex: 1,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGlucosePressureCard(),
                  const SizedBox(height: 16),
                  _buildWeightCard(),
                  const SizedBox(height: 16),
                  _buildHistoryCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            )
          else if (_selectedPatient != null)
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Sem registros de saúde',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Selecione um paciente',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlucosePressureCard() {
    final glucoseRecords =
        _selectedPatient!.records.where((r) => r.glucoseMgDl != null).toList();
    final pressureRecords =
        _selectedPatient!.records.where((r) => r.systolic != null).toList();

    if (glucoseRecords.isEmpty && pressureRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Sem registros de glicose/pressão',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Glicose e Pressão',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    if (glucoseRecords.isNotEmpty)
                      LineChartBarData(
                        spots: List.generate(
                            glucoseRecords.length,
                            (i) => FlSpot(i.toDouble(),
                                glucoseRecords[i].glucoseMgDl!.toDouble())),
                        isCurved: true,
                        barWidth: 2,
                        color: const Color(0xFF00B8A9),
                      ),
                    if (pressureRecords.isNotEmpty)
                      LineChartBarData(
                        spots: List.generate(
                            pressureRecords.length,
                            (i) => FlSpot(i.toDouble(),
                                pressureRecords[i].systolic!.toDouble())),
                        isCurved: true,
                        barWidth: 2,
                        color: accentColor,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard() {
    final weightRecords =
        _selectedPatient!.records.where((r) => r.weightKg != null).toList();

    if (weightRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Sem registros de peso',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendência de Peso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          weightRecords.length,
                          (i) =>
                              FlSpot(i.toDouble(), weightRecords[i].weightKg!)),
                      isCurved: true,
                      barWidth: 2,
                      color: const Color(0xFF00B8A9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    final records = _selectedPatient!.records.toList().reversed.toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Glicose')),
                  DataColumn(label: Text('Pressão')),
                  DataColumn(label: Text('Peso')),
                ],
                rows: records.map((record) {
                  final date = DateFormat('dd/MM/yyyy').format(record.date);
                  final glucose = record.glucoseMgDl?.toStringAsFixed(0) ?? '-';
                  final pressure =
                      (record.systolic != null && record.diastolic != null)
                          ? '${record.systolic}/${record.diastolic}'
                          : '-';
                  final weight = record.weightKg?.toStringAsFixed(1) ?? '-';

                  return DataRow(cells: [
                    DataCell(Text(date)),
                    DataCell(Text('$glucose mg/dL')),
                    DataCell(Text(pressure)),
                    DataCell(Text('$weight kg')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.insights_rounded),
          label: const Text('Relatório Completo'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exportação simulada.')),
            );
          },
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Exportar PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Atualizar'),
        ),
      ],
    );
  }
}
