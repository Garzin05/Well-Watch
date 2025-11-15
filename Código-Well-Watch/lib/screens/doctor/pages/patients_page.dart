import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/models/app_data.dart';

class PatientsPage extends StatefulWidget {
  final String? initialQuery;
  const PatientsPage({super.key, this.initialQuery});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  String _query = '';
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _loadPatients();
  }

  /// Carrega apenas pacientes do médico logado
  void _loadPatients() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final health = Provider.of<HealthService>(context, listen: false);

    // Filtra pacientes do médico
    void _loadPatients() {
  _patients = List.from(appData.patients); // pega todos os pacientes
  _patients.sort((a, b) => a.name.compareTo(b.name));
  setState(() {});
}

    // Se quiser ordenar por nome:
    _patients.sort((a, b) => a.name.compareTo(b.name));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _patients
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Pesquisar paciente',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(p.initials)),
                  title: Text(p.name),
                  subtitle: Text(_latestSubtitle(p)),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Relatórios',
                        onPressed: () => _openReports(p),
                        icon: const Icon(Icons.insights_rounded),
                      ),
                      IconButton(
                        tooltip: 'Contatar',
                        onPressed: () => _contactPatient(p),
                        icon: const Icon(Icons.chat_bubble_rounded),
                      ),
                      IconButton(
                        tooltip: 'Adicionar medição',
                        onPressed: () => _addVital(p),
                        icon: const Icon(Icons.add_chart_rounded),
                      ),
                    ],
                  ),
                  onTap: () => _openReports(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _latestSubtitle(Patient p) {
    final last = p.latestRecord();
    if (last == null) return 'Sem dados';
    final d = last.date;
    String two(int n) => n.toString().padLeft(2, '0');
    final when = '${two(d.day)}/${two(d.month)}/${d.year}';
    final g = last.glucoseMgDl != null ? '${last.glucoseMgDl!.toStringAsFixed(0)} mg/dL' : '-';
    final pr = (last.systolic != null && last.diastolic != null) ? '${last.systolic}/${last.diastolic}' : '-';
    final w = last.weightKg != null ? '${last.weightKg!.toStringAsFixed(1)} kg' : '-';
    return 'Último: $when • Glicose $g • PA $pr • Peso $w';
  }

  void _openReports(Patient p) async {
    appData.selectPatient(p);
    await Navigator.pushNamed(context, '/reports');
    if (!mounted) return;
    setState(() {});
  }

  void _contactPatient(Patient p) {
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
            padding: const EdgeInsets.all(16),
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

  void _addVital(Patient p) {
    final gCtrl = TextEditingController();
    final sCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    final wCtrl = TextEditingController();
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text('Adicionar medição — ${p.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: gCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Glicose (mg/dL)')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: sCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sistólica'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: dCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diastólica'))),
                ]),
                const SizedBox(height: 8),
                TextField(controller: wCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text('Data: ${_formatDate(when)}')),
                  IconButton(
                    tooltip: 'Escolher data e hora',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: when,
                      );
                      if (picked != null) {
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
                      double? g = double.tryParse(gCtrl.text.replaceAll(',', '.'));
                      int? s = int.tryParse(sCtrl.text);
                      int? d = int.tryParse(dCtrl.text);
                      double? w = double.tryParse(wCtrl.text.replaceAll(',', '.'));
                      if (g == null && s == null && d == null && w == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe ao menos um valor.')));
                        return;
                      }
                      appData.addVital(
                        patientId: p.id,
                        date: when,
                        glucoseMgDl: g,
                        systolic: s,
                        diastolic: d,
                        weightKg: w,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medição adicionada.')));
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
