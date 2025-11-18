import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/utils/constants.dart';

class AlimentacaoPage extends StatefulWidget {
  const AlimentacaoPage({super.key});

  @override
  State<AlimentacaoPage> createState() => _AlimentacaoPageState();
}

class _AlimentacaoPageState extends State<AlimentacaoPage> {
  final List<Map<String, dynamic>> _meals = [];

  int _getTotalCalories() {
    int total = 0;
    for (var meal in _meals) {
      total += (meal['calories'] as int?) ?? 0;
    }
    return total;
  }

  void _addMeal() async {
    final TextEditingController mealTypeController = TextEditingController();
    final TextEditingController foodController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Refeição'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Tipo de Refeição'),
                items: const [
                  DropdownMenuItem(
                      value: 'Café da Manhã', child: Text('Café da Manhã')),
                  DropdownMenuItem(value: 'Almoço', child: Text('Almoço')),
                  DropdownMenuItem(value: 'Lanche', child: Text('Lanche')),
                  DropdownMenuItem(value: 'Jantar', child: Text('Jantar')),
                  DropdownMenuItem(value: 'Ceia', child: Text('Ceia')),
                ],
                onChanged: (value) => mealTypeController.text = value ?? '',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: foodController,
                decoration: const InputDecoration(labelText: 'Alimentos'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caloriesController,
                decoration:
                    const InputDecoration(labelText: 'Calorias (opcional)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlueBackground,
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );

    if (result == true &&
        mealTypeController.text.isNotEmpty &&
        foodController.text.isNotEmpty) {
      setState(() {
        _meals.insert(0, {
          'type': mealTypeController.text,
          'food': foodController.text,
          'calories': caloriesController.text.isEmpty
              ? null
              : int.tryParse(caloriesController.text),
          'time': DateTime.now(),
        });
      });
    }
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    IconData getMealIcon(String type) {
      switch (type) {
        case 'Café da Manhã':
          return Icons.coffee;
        case 'Almoço':
          return Icons.restaurant;
        case 'Lanche':
          return Icons.cake;
        case 'Jantar':
          return Icons.dinner_dining;
        case 'Ceia':
          return Icons.nightlight;
        default:
          return Icons.food_bank;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(getMealIcon(meal['type']),
                    color: AppColors.darkBlueBackground),
                const SizedBox(width: 8),
                Text(
                  meal['type'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${meal['time'].hour.toString().padLeft(2, '0')}:${meal['time'].minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(meal['food'], style: const TextStyle(fontSize: 16)),
            if (meal['calories'] != null) ...[
              const SizedBox(height: 8),
              Text('${meal['calories']} kcal',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentação'),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      body: _meals.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Nenhuma refeição registrada hoje',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Clique no + para adicionar',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _meals.length,
              itemBuilder: (context, index) => _buildMealCard(_meals[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        backgroundColor: const Color.fromARGB(255, 220, 225, 230),
        child: const Icon(Icons.add),
      ),
    );
  }
}
