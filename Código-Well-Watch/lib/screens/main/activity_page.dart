import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/utils/constants.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final List<Map<String, String>> _activities = [];

  void _addActivity() async {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar atividade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration:
                  const InputDecoration(labelText: 'Tipo (ex: Corrida)'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zá-ú\s]')),
              ],
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duração (min)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar')),
        ],
      ),
    );

    if (result == true && typeController.text.isNotEmpty) {
      setState(() {
        _activities.insert(0, {
          'type': typeController.text,
          'duration': durationController.text,
          'time': DateTime.now().toIso8601String(),
        });
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividade Física'),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      body: _activities.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_run, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhuma atividade registrada',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _activities[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(item['type'] ?? ''),
                  subtitle: Text(
                      '${item['duration'] ?? ''} min • ${DateTime.parse(item['time']!).toLocal()}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}
