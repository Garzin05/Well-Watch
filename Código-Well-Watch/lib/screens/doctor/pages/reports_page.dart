import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {

  // Dados fictícios e independentes de pacientes
  final List<FlSpot> glucose = [
    FlSpot(0, 110), FlSpot(1, 90), FlSpot(2, 105),
    FlSpot(3, 130), FlSpot(4, 95), FlSpot(5, 100)
  ];

  final List<FlSpot> pressure = [
    FlSpot(0, 120), FlSpot(1, 118), FlSpot(2, 125),
    FlSpot(3, 130), FlSpot(4, 115), FlSpot(5, 122)
  ];

  final List<double> weight = [72.0, 72.1, 72.3, 72.2, 72.4, 72.6];
  final List<double> bmi = [23.5, 23.6, 23.7, 23.5, 23.6, 23.7];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
            child: _simpleLineChart(glucose, pressure),
          ),

          const SizedBox(height: 16),

          _Card(
            title: 'Peso e IMC (Tendência)',
            trailing: _Legend(
              labels: const ['Peso', 'IMC'],
              colors: [scheme.primary, scheme.secondary],
            ),
            child: _simpleBarChart(weight, bmi),
          ),

          const SizedBox(height: 16),

          _Card(
            title: 'Histórico Diário',
            child: _HistoryTableClean(), // tabela limpa
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary),
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
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Glicose')),
        DataColumn(label: Text('Pressão')),
        DataColumn(label: Text('Peso')),
      ],
      rows: const [], // tabela vazia
    );
  }
}
