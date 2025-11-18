import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projetowell/models/app_data.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Gera dados do gráfico a partir dos registros do paciente selecionado
  List<FlSpot> _getGlucoseData() {
    final patient = appData.selectedPatient;
    if (patient == null || patient.records.isEmpty) return [];

    return patient.records
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), e.value.glucoseMgDl?.toDouble() ?? 0))
        .where((spot) => spot.y > 0)
        .toList();
  }

  List<FlSpot> _getPressureData() {
    final patient = appData.selectedPatient;
    if (patient == null || patient.records.isEmpty) return [];

    return patient.records
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.systolic?.toDouble() ?? 0))
        .where((spot) => spot.y > 0)
        .toList();
  }

  List<double> _getWeightData() {
    final patient = appData.selectedPatient;
    if (patient == null || patient.records.isEmpty) return [];

    return patient.records.map((r) => r.weightKg ?? 0).toList();
  }

  List<double> _getBmiData() {
    final patient = appData.selectedPatient;
    if (patient == null || patient.records.isEmpty) return [];

    return patient.records.map((r) {
      if (r.weightKg == null) return 0.0;
      // IMC simplificado (altura não está nos dados)
      return 22.0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final patient = appData.selectedPatient;

    // Se não houver paciente selecionado
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relatórios')),
        body: const Center(
          child: Text('Nenhum paciente selecionado'),
        ),
      );
    }

    // Se não houver registros
    if (patient.records.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relatórios')),
        body: Center(
          child: Text('${patient.name} não possui registros de saúde'),
        ),
      );
    }

    final glucoseData = _getGlucoseData();
    final pressureData = _getPressureData();
    final weightData = _getWeightData();
    final bmiData = _getBmiData();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(
            title: 'Glicose e Pressão (Últimos dias)',
            trailing: _Legend(
              labels: const ['Glicose', 'Sistólica'],
              colors: [scheme.primary, scheme.secondary],
            ),
            child: _simpleLineChart(glucoseData, pressureData),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Peso e IMC (Tendência)',
            trailing: _Legend(
              labels: const ['Peso', 'IMC'],
              colors: [scheme.primary, scheme.secondary],
            ),
            child: _simpleBarChart(weightData, bmiData),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Histórico Diário',
            child: _HistoryTableClean(patient: patient),
          ),
          const SizedBox(height: 16),
          Wrap(
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
                label: const Text('Atualizar Dados'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------- GRÁFICO LINHA SIMPLES ----------
  Widget _simpleLineChart(List<FlSpot> g, List<FlSpot> p) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: g,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
            ),
            LineChartBarData(
              spots: p,
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
            )
          ],
        ),
      ),
    );
  }

  // --------- GRÁFICO BARRAS SIMPLES ----------
  Widget _simpleBarChart(List<double> w, List<double> b) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(w.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: w[i], width: 10, color: Colors.blue),
                BarChartRodData(toY: b[i], width: 10, color: Colors.green),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// --------- COMPONENTES AUXILIARES ----------
class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Card({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: scheme.primary),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<String> labels;
  final List<Color> colors;

  const _Legend({required this.labels, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(labels[i]),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryTableClean extends StatelessWidget {
  final Patient patient;

  const _HistoryTableClean({required this.patient});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Glicose')),
        DataColumn(label: Text('Pressão')),
        DataColumn(label: Text('Peso')),
      ],
      rows: patient.records.map((record) {
        String two(int n) => n.toString().padLeft(2, '0');
        final date =
            '${two(record.date.day)}/${two(record.date.month)}/${record.date.year}';
        final glucose = record.glucoseMgDl?.toStringAsFixed(0) ?? '-';
        final pressure = (record.systolic != null && record.diastolic != null)
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
    );
  }
}
