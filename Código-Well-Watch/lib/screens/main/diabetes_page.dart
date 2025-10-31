import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/models/health_data.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:projetowell/theme.dart';
import 'package:intl/intl.dart';

class DiabetesPage extends StatelessWidget {
  const DiabetesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Glicose',
      dataDisplay: const DiabetesDataDisplay(),
      actionButton: AnimatedActionButton(
        text: 'Adicionar Registro',
        icon: Icons.add,
        onPressed: () => _showAddGlucoseDialog(context),
      ),
    );
  }

  void _showAddGlucoseDialog(BuildContext context) {
    final glucoseController = TextEditingController();
    final timeController = TextEditingController(
      text: DateFormat('HH:mm').format(DateTime.now()),
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => HealthDataEntryDialog(
        title: 'Adicionar Nível de Glicose',
        formFields: [
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: glucoseController,
                  label: 'Nível de Glicose (mg/dl)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o nível de glicose';
                    }
                    final glucoseLevel = double.tryParse(value);
                    if (glucoseLevel == null || glucoseLevel <= 0) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                  prefixIcon: Icons.bloodtype,
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
                        RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]\$');
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
            final glucoseValue = double.parse(glucoseController.text);
            final healthService = Provider.of<HealthService>(
              context,
              listen: false,
            );
            healthService.addGlucoseRecord(
              GlucoseRecord(
                date: DateTime.now(),
                time: timeController.text,
                glucoseLevel: glucoseValue,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro de glicose adicionado'),
              ),
            );
          }
        },
      ),
    );
  }
}

class DiabetesDataDisplay extends StatelessWidget {
  const DiabetesDataDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final healthService = Provider.of<HealthService>(context);
    final DateTime today = DateTime.now();
    final List<GlucoseRecord> todayRecords = healthService.getGlucoseForDate(
      today,
    );

    Color getGlucoseColor(double level) {
      if (level < 70) return AppColors.glucoseLow;
      if (level > 180) return AppColors.glucoseHigh;
      return AppColors.glucoseNormal;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NÍVEL DE GLICOSE',
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
                Icon(Icons.bloodtype_outlined, size: 48, color: Colors.grey),
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
                    color: getGlucoseColor(record.glucoseLevel)
                        .withAlpha((0.3 * 255).round()),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bloodtype,
                      color: getGlucoseColor(record.glucoseLevel),
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
                                'Glicose',
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
                            record.formattedGlucose,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: getGlucoseColor(record.glucoseLevel),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.glucoseLow,
                      ),
                      onPressed: () {
                        Provider.of<HealthService>(
                          context,
                          listen: false,
                        ).removeGlucoseRecord(record);
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
        const SizedBox(height: 20),
        const Text(
          'INFORMAÇÕES',
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valores de Referência:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Em jejum: 70-100 mg/dl', style: TextStyle(fontSize: 14)),
              Text('Pós-prandial: <140 mg/dl', style: TextStyle(fontSize: 14)),
              Text(
                'Hipoglicemia: <70 mg/dl',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              Text(
                'Hiperglicemia: >180 mg/dl',
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
