import 'package:flutter/material.dart';
import 'package:projetowell/models/app_data.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {

  @override
  Widget build(BuildContext context) {
    final items = [...appData.appointments]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final a = items[index];
          final p = appData.patients.firstWhere((e) => e.id == a.patientId, orElse: () => appData.patients.first);
          return ListTile(
            leading: CircleAvatar(child: Text('${a.dateTime.day}')),
            title: Text(p.name),
            subtitle: Text('${_formatDate(a.dateTime)} • ${a.note}'),
            trailing: IconButton(icon: const Icon(Icons.notifications_active_outlined), onPressed: () {}),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar evento'),
      ),
    );
  }

  void _addEvent() async {
    final controllerNote = TextEditingController();
    DateTime when = DateTime.now().add(const Duration(hours: 3));
    String patientId = appData.selectedPatient?.id ?? (appData.patients.isNotEmpty ? appData.patients.first.id : '');
    // ignore: use_build_context_synchronously
    await showModalBottomSheet(
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
                Row(
                  children: [
                    const Expanded(
                      child: Text('Novo evento', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: patientId.isEmpty ? null : patientId,
                  items: appData.patients
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => patientId = v ?? patientId,
                  decoration: const InputDecoration(labelText: 'Paciente'),
                ),
                const SizedBox(height: 8),
                TextField(controller: controllerNote, decoration: const InputDecoration(labelText: 'Nota')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Data: ${_formatDate(when)}')),
                    IconButton(
                      tooltip: 'Escolher data e hora',
                      onPressed: () async {
                        // ignore: use_build_context_synchronously
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDate: when,
                        );
                        if (picked != null) {
                          // ignore: use_build_context_synchronously
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                          if (t != null && mounted) {
                            setState(() {
                              when = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (patientId.isEmpty && appData.patients.isNotEmpty) {
                        patientId = appData.patients.first.id;
                      }
                      appData.addAppointment(dateTime: when, patientId: patientId, note: controllerNote.text);
                      Navigator.pop(context);
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

// Legacy private class removed; using Appointment from AppData
