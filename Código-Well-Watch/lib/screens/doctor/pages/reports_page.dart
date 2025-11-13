import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projetowell/models/app_data.dart';
import 'package:projetowell/widgets/charts/health_charts.dart';



class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = appData.selectedPatient ?? appData.patients.first;

    final recent = [...p.records]
      ..sort((a, b) => a.date.compareTo(b.date));
    final last7 = recent.length > 7 ? recent.sublist(recent.length - 7) : recent;

    final glucose = <FlSpot>[];
    final systolic = <FlSpot>[];
    final weight = <double>[];
    final bmi = <double>[];
    for (var i = 0; i < last7.length; i++) {
      final r = last7[i];
      glucose.add(FlSpot(i.toDouble(), r.glucoseMgDl!.toDouble()));
      systolic.add(FlSpot(i.toDouble(), r.systolic!.toDouble()));
      weight.add(r.weightKg!);
      bmi.add(double.parse((r.weightKg! / 3.0625).toStringAsFixed(1))); // ~1.75m
        }

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderPatientPicker(scheme: scheme, onChange: () async {
            await _pickPatient();
            if (!mounted) return;
            setState(() {});
          }),
          const SizedBox(height: 16),
          _Card(
            title: 'Glicose e Pressão (Últimos 7 dias)',
            trailing: _Legend(labels: const ['Glicose', 'Sistólica'], colors: [scheme.primary, scheme.secondary]),
            child: GlucosePressureLineChart(glucose: glucose, pressure: systolic),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Peso e IMC (Semanas recentes)',
            trailing: _Legend(labels: const ['Peso', 'IMC'], colors: [scheme.primary, scheme.secondary]),
            child: WeightBmiBarChart(weight: weight, bmi: bmi),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Histórico Diário',
            child: _HistoryTable(p: p),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.insights_rounded), label: const Text('Ver Relatório Completo')),
              OutlinedButton.icon(onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportação em PDF simulada.')));
              }, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Exportar PDF')),
              OutlinedButton.icon(onPressed: () { setState(() {}); }, icon: const Icon(Icons.refresh_rounded), label: const Text('Atualizar Dados')),
              OutlinedButton.icon(onPressed: () { _contactPatient(context, p); }, icon: const Icon(Icons.chat_bubble_rounded), label: const Text('Contatar Paciente')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickPatient() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: [
            const ListTile(title: Text('Selecionar paciente', style: TextStyle(fontWeight: FontWeight.w600))),
            const Divider(height: 1),
            ...appData.patients.map((p) => ListTile(
                  leading: CircleAvatar(child: Text(p.initials)),
                  title: Text(p.name),
                  onTap: () {
                    appData.selectPatient(p);
                    Navigator.pop(context);
                  },
                )),
          ],
        );
      },
    );
  }

  void _contactPatient(BuildContext context, Patient p) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text('Enviar mensagem para ${p.name.split(' ').first}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Escreva sua mensagem...')),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensagem enviada (simulado).')));
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Enviar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}


  

class _HeaderPatientPicker extends StatelessWidget {
  const _HeaderPatientPicker({required this.scheme, this.onChange});
  final ColorScheme scheme;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final p = appData.selectedPatient ?? (appData.patients.isNotEmpty ? appData.patients.first : null);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: scheme.primary.withValues(alpha: 0.12), child: Icon(Icons.person_rounded, color: scheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: Text('Paciente: ${p?.name ?? '—'}')),
            TextButton.icon(onPressed: onChange, icon: const Icon(Icons.swap_horiz_rounded), label: const Text('Trocar')),
          ],
        ),
      ),
    );
  }
}

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
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary)),
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
            child: Row(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(labels[i]),
            ]),
          ),
      ],
    );
  }
}

class _HistoryTable extends StatelessWidget {
  final Patient p;
  const _HistoryTable({required this.p});

  @override
  Widget build(BuildContext context) {
    final recs = [...p.records]..sort((a, b) => b.date.compareTo(a.date));
    final rows = recs.take(12).map((r) {
      final d = r.date;
      String dd = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      final g = r.glucoseMgDl != null ? '${r.glucoseMgDl!.toStringAsFixed(0)} mg/dL' : '—';
      final pr = (r.systolic != null && r.diastolic != null) ? '${r.systolic}/${r.diastolic}' : '—';
      final w = r.weightKg != null ? '${r.weightKg!.toStringAsFixed(1)} kg' : '—';
      return DataRow(cells: [
        DataCell(Text(dd)),
        DataCell(Text(g)),
        DataCell(Text(pr)),
        DataCell(Text(w)),
      ]);
    }).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: const [
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Glicose')),
        DataColumn(label: Text('Pressão')),
        DataColumn(label: Text('Peso')),
      ], rows: rows),
    );
  }
}
