import 'package:flutter/material.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final List<double> _weights = [];
  final TextEditingController _controller = TextEditingController();

  void _addWeight() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Adicionar registro de peso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  _controller.text.replaceAll(',', '.'),
                );

                if (value != null && value > 0) {
                  setState(() => _weights.add(value));
                  _controller.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _remove(int index) {
    setState(() => _weights.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _weights.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Peso')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWeight,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monitor_weight, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum registro de peso',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicione registros usando o botão abaixo',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _weights.length,
              itemBuilder: (context, index) {
                final w = _weights[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.monitor_weight, color: Colors.green),
                    title: Text(
                      '${w.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _remove(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
