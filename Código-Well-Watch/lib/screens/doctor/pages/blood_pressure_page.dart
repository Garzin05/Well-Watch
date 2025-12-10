import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projetowell/models/app_data.dart';
import 'package:projetowell/widgets/patient_selector.dart';
import 'package:projetowell/services/api_service.dart';

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  Patient? _selectedPatient;

  static const primaryColor = Color.fromARGB(255, 2, 31, 48);
  static const accentColor = Color(0xFFE94E77);

  void _handlePatientSelected(Patient patient) {
    setState(() => _selectedPatient = patient);
    _loadPressureMeasurements(patient.id);
  }

  Future<void> _loadPressureMeasurements(String patientId) async {
    try {
      final measurements = await ApiService.getPressureMeasurements(patientId);
      if (mounted && measurements.isNotEmpty) {
        setState(() {
          if (_selectedPatient != null) {
            _selectedPatient = Patient(
              id: _selectedPatient!.id,
              name: _selectedPatient!.name,
              records: [
                ..._selectedPatient!.records.where((r) => r.systolic == null),
                ...measurements,
              ],
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[BloodPressurePage] Erro ao carregar medições: $e');
    }
  }

  void _addBloodPressureDialog() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um paciente primeiro")),
      );
      return;
    }

    final systolicCtrl = TextEditingController();
    final diastolicCtrl = TextEditingController();
    final heartRateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Adicionar Pressão Arterial",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: systolicCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Sistólica (mmHg)",
                  labelStyle: const TextStyle(color: primaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diastolicCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Diastólica (mmHg)",
                  labelStyle: const TextStyle(color: primaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heartRateCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Frequência Cardíaca (bpm)",
                  labelStyle: const TextStyle(color: primaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                final systolic = int.tryParse(systolicCtrl.text);
                final diastolic = int.tryParse(diastolicCtrl.text);

                if (systolic != null && diastolic != null) {
                  appData.addVital(
                    patientId: _selectedPatient!.id,
                    date: DateTime.now(),
                    systolic: systolic,
                    diastolic: diastolic,
                  );
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Registro adicionado com sucesso!")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pressão Arterial'),
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
          if (_selectedPatient != null)
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registros de ${_selectedPatient!.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedPatient!.records
                        .where((r) => r.systolic != null)
                        .isNotEmpty)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildChart(),
                        ),
                      )
                    else
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Nenhum registro',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 16),
                    Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRecords(),
                  ],
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
      floatingActionButton: _selectedPatient != null
          ? FloatingActionButton.extended(
              onPressed: _addBloodPressureDialog,
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            )
          : null,
    );
  }

  Widget _buildChart() {
    final records =
        _selectedPatient!.records.where((r) => r.systolic != null).toList();
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(records.length,
                  (i) => FlSpot(i.toDouble(), records[i].systolic!.toDouble())),
              isCurved: true,
              color: accentColor,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final records =
        _selectedPatient!.records.where((r) => r.systolic != null).toList();
    if (records.isEmpty) return const SizedBox.shrink();

    final systolic = records.map((r) => r.systolic!.toDouble()).toList();
    final avg = systolic.reduce((a, b) => a + b) / systolic.length;

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text('Média',
                      style: TextStyle(fontSize: 12, color: primaryColor)),
                  const SizedBox(height: 8),
                  Text(
                    '${avg.toStringAsFixed(0)} mmHg',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecords() {
    final records = _selectedPatient!.records
        .where((r) => r.systolic != null)
        .toList()
        .reversed
        .toList();
    if (records.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.favorite),
            ),
            title: Text(
              '${record.systolic}/${record.diastolic} mmHg',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: primaryColor),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(record.date),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }
}
