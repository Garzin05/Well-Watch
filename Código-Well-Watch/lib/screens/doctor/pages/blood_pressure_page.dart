import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projetowell/models/app_data.dart';

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = appData.selectedPatient ?? appData.patients.first;

    final recent = [...p.records]..sort((a, b) => a.date.compareTo(b.date));
    final last7 = recent.length > 7 ? recent.sublist(recent.length - 7) : recent;
    final systolic = <FlSpot>[];
    final diastolic = <FlSpot>[];
    for (var i = 0; i < last7.length; i++) {
      final r = last7[i];
      systolic.add(FlSpot(i.toDouble(), r.systolic!.toDouble()));
      diastolic.add(FlSpot(i.toDouble(), r.diastolic!.toDouble()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pressão Arterial')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPressure(p),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar PA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PatientHeader(onChange: () async {
            await _pickPatient();
            if (!mounted) return;
            setState(() {});
          }),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text('Pressão — últimos 7 dias', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary))),
                    _Legend(labels: const ['Sistólica', 'Diastólica'], colors: [scheme.primary, scheme.secondary]),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black.withValues(alpha: 0.08))),
                        lineBarsData: [
                          LineChartBarData(isCurved: true, color: scheme.primary, barWidth: 3, dotData: const FlDotData(show: false), spots: systolic),
                          LineChartBarData(isCurved: true, color: scheme.secondary, barWidth: 3, dotData: const FlDotData(show: false), spots: diastolic),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Histórico recente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary)),
                  const SizedBox(height: 8),
                  ...[...p.records].reversed.take(12).map((r) {
                    final d = r.date;
                    String two(int n) => n.toString().padLeft(2, '0');
                    final when = '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
                    final pr = (r.systolic != null && r.diastolic != null) ? '${r.systolic}/${r.diastolic}' : '—';
                    return ListTile(leading: const Icon(Icons.monitor_heart_rounded), title: Text(pr), subtitle: Text(when));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPatient() async {
    // ignore: use_build_context_synchronously
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
                  onTap: () { appData.selectPatient(p); Navigator.pop(context); },
                )),
          ],
        );
      },
    );
  }

  void _addPressure(Patient p) {
    final sCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    DateTime when = DateTime.now();
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
                  Expanded(child: Text('Adicionar pressão — ${p.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: sCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sistólica'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: dCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diastólica'))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text('Data: ${_formatDate(when)}')),
                  IconButton(
                    tooltip: 'Escolher data e hora',
                    onPressed: () async {
                        // ignore: use_build_context_synchronously
                        final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: when,
                      );
                      if (picked != null) {
                          // ignore: use_build_context_synchronously
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                        if (t != null) {
                          when = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded),
                  ),
                ]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      final s = int.tryParse(sCtrl.text);
                      final d = int.tryParse(dCtrl.text);
                      if (s == null || d == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe pressão sistólica e diastólica.')));
                        return;
                      }
                      appData.addVital(patientId: p.id, date: when, systolic: s, diastolic: d);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pressão adicionada.')));
                      setState(() {});
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Salvar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _PatientHeader extends StatelessWidget {
  final VoidCallback? onChange;
  const _PatientHeader({this.onChange});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
