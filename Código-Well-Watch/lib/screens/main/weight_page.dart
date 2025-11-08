import 'package:flutter/material.dart';
import 'package:projetowell/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/models/health_data.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:intl/intl.dart';

class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Controle de Peso',
      dataDisplay: const WeightDataDisplay(),
      actionButton: AnimatedActionButton(
        text: 'Adicionar Registro',
        icon: Icons.add,
        onPressed: () => _showAddWeightDialog(context),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final weightController = TextEditingController();
    final timeController = TextEditingController(
      text: DateFormat('HH:mm').format(DateTime.now()),
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => HealthDataEntryDialog(
        title: 'Adicionar Registro de Peso',
        formFields: [
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: weightController,
                  label: 'Peso (kg)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o peso';
                    }
                    value = value.replaceAll(',', '.');
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                  prefixIcon: Icons.monitor_weight,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: timeController,
                  label: 'Horário',
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o horário';
                    }
                    final RegExp timeRegex =
                        RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
                    if (!timeRegex.hasMatch(value)) {
                      return 'Use o formato HH:MM';
                    }
                    return null;
                  },
                  prefixIcon: Icons.access_time,
                ),
              ],
            ),
          ),
        ],
        onSave: () {
          if (formKey.currentState!.validate()) {
            String normalizedValue = weightController.text.replaceAll(',', '.');
            final weight = double.parse(normalizedValue);
            final healthService = Provider.of<HealthService>(
              context,
              listen: false,
            );
            healthService.addWeightRecord(
              WeightRecord(
                date: DateTime.now(),
                time: timeController.text,
                weight: weight,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro de peso adicionado')),
            );
          }
        },
      ),
    );
  }
}

class WeightDataDisplay extends StatelessWidget {
  const WeightDataDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final healthService = Provider.of<HealthService>(context);
    final DateTime today = DateTime.now();
    final List<WeightRecord> todayRecords = healthService.getWeightForDate(
      today,
    );

    final allWeightRecords = healthService.weightRecords;
    final List<WeightRecord> recentRecords = allWeightRecords.length > 1
        ? allWeightRecords.take(5).toList()
        : allWeightRecords;

    double? weightChange;
    String? changeText;

    if (recentRecords.length >= 2) {
      final latestWeight = recentRecords.first.weight;
      final previousWeight = recentRecords.last.weight;
      weightChange = latestWeight - previousWeight;

      final changeAbs = weightChange.abs();
      final changeSign = weightChange > 0 ? '+' : '';
      changeText = '$changeSign${changeAbs.toStringAsFixed(1)} kg';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REGISTROS DE PESO',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        if (todayRecords.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(Icons.monitor_weight_outlined,
                    size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Nenhum registro para hoje',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Adicione um registro usando o botão abaixo',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: todayRecords.map((record) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.darkBlueBackground
                        .withAlpha((0.3 * 255).round()),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monitor_weight,
                      color: AppColors.darkBlueBackground,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Peso',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                record.time,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.formattedWeight,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlueBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Provider.of<HealthService>(
                          context,
                          listen: false,
                        ).removeWeightRecord(record);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registro removido'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (recentRecords.length >= 2) ...[
          const SizedBox(height: 20),
          const Text(
            'EVOLUÇÃO RECENTE',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Última variação: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      changeText!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: weightChange! > 0
                            ? Colors.red
                            : weightChange < 0
                                ? Colors.green
                                : Colors.black,
                      ),
                    ),
                    if (weightChange != 0) ...[
                      const SizedBox(width: 4),
                      Icon(
                        weightChange > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: weightChange > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < recentRecords.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${recentRecords[i].formattedDate}: ${recentRecords[i].formattedWeight}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            i == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
