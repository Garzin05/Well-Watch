import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<Map<String, String>> _reports = [];

  Future<void> _createReport() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Relatório'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newTitle = titleController.text.isEmpty
          ? 'Relatório ${_reports.length + 1}'
          : titleController.text;
      final newDesc = descController.text;

      if (!mounted) return;

      setState(() {
        _reports.insert(0, {'title': newTitle, 'desc': newDesc});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório criado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createReport,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  const Icon(Icons.description,
                      size: 42, color: Colors.black54),
                  const SizedBox(height: 8),
                  const Text('Relatórios', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_reports.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Nenhum relatório encontrado',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _createReport,
                        child: const Text('Criar relatório'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.separated(
                  itemCount: _reports.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final title = _reports[index]['title'] ?? 'Relatório';
                    final subtitle = _reports[index]['desc'] ?? '';
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('$title: visualização rápida')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
