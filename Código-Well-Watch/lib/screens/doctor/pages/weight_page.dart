import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projetowell/models/app_data.dart';
import 'package:projetowell/widgets/patient_selector.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  Patient? _selectedPatient;

  static const primaryColor = Color.fromARGB(255, 2, 31, 48);
  static const accentColor = Color(0xFF00B8A9);

  void _handlePatientSelected(Patient patient) {
    setState(() => _selectedPatient = patient);
  }

  void _addWeightDialog() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um paciente primeiro")),
      );
      return;
    }

    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Adicionar Peso",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Peso (kg)",
              labelStyle: const TextStyle(color: primaryColor),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                final value =
                    double.tryParse(weightCtrl.text.replaceAll(",", "."));
                if (value != null && value > 0) {
                  appData.addVital(
                    patientId: _selectedPatient!.id,
                    date: DateTime.now(),
                    weightKg: value,
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
        title: const Text('Peso'),
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
                        .where((r) => r.weightKg != null)
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
              onPressed: _addWeightDialog,
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            )
          : null,
    );
  }

  Widget _buildChart() {
    final records =
        _selectedPatient!.records.where((r) => r.weightKg != null).toList();
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(records.length,
                  (i) => FlSpot(i.toDouble(), records[i].weightKg!)),
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
        _selectedPatient!.records.where((r) => r.weightKg != null).toList();
    if (records.isEmpty) return const SizedBox.shrink();

    final weights = records.map((r) => r.weightKg!).toList();
    final avg = weights.reduce((a, b) => a + b) / weights.length;
    final max = weights.reduce((a, b) => a > b ? a : b);
    final min = weights.reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Média', '${avg.toStringAsFixed(1)} kg')),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard('Máximo', '${max.toStringAsFixed(1)} kg')),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard('Mínimo', '${min.toStringAsFixed(1)} kg')),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: primaryColor)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecords() {
    final records = _selectedPatient!.records
        .where((r) => r.weightKg != null)
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
              child: const Icon(Icons.monitor_weight),
            ),
            title: Text(
              '${record.weightKg!.toStringAsFixed(1)} kg',
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
