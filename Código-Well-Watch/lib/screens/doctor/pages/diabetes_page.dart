import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DiabetesPage extends StatefulWidget {
  const DiabetesPage({super.key});

  @override
  State<DiabetesPage> createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> {
  final List<double> _glucoseRecords = [];
  final TextEditingController _controller = TextEditingController();

  void _addGlucose() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Adicionar glicose', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Glicose (mg/dL)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(_controller.text.replaceAll(',', '.'));
                if (value != null) {
                  setState(() => _glucoseRecords.add(value));
                  _controller.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = List.generate(
        _glucoseRecords.length, (i) => FlSpot(i.toDouble(), _glucoseRecords[i]));

    return Scaffold(
      appBar: AppBar(title: const Text('Diabetes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGlucose,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar glicose'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Glicose — últimos registros', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black.withOpacity(0.08))),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: scheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            spots: spots,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _glucoseRecords.isEmpty
                  ? const Center(child: Text('Nenhum registro de glicose', style: TextStyle(color: Colors.grey)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_glucoseRecords.length, (i) {
                        final value = _glucoseRecords[i];
                        return ListTile(
                          leading: const Icon(Icons.bloodtype_rounded, color: Colors.redAccent),
                          title: Text('${value.toStringAsFixed(0)} mg/dL'),
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
