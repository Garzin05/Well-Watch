import 'package:flutter/material.dart';

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  final List<Map<String, dynamic>> _records = [];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pressão Arterial')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPressure,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar PA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Paciente: —')),
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
                  Text(
                    'Registros de Pressão',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  if (_records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Nenhum registro adicionado.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ..._records.reversed.map((r) {
                    return ListTile(
                      leading: const Icon(Icons.monitor_heart),
                      title: Text('${r["s"]}/${r["d"]} mmHg'),
                      subtitle: Text(r["date"]),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addPressure() {
    final sCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    DateTime when = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  const Expanded(
                    child: Text(
                      'Adicionar Pressão',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ]),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Sistólica'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: dCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Diastólica'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                    onPressed: () {
                      final s = int.tryParse(sCtrl.text);
                      final d = int.tryParse(dCtrl.text);

                      if (s == null || d == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Informe sistólica e diastólica'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _records.add({
                          "s": s,
                          "d": d,
                          "date":
                              "${when.day}/${when.month}/${when.year} ${when.hour}:${when.minute.toString().padLeft(2, '0')}"
                        });
                      });

                      Navigator.pop(context);
                    },
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
