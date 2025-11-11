import 'package:flutter/material.dart';
import 'package:projetowell/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/models/health_data.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:intl/intl.dart';

class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Pressão Arterial',
      dataDisplay: const BloodPressureDataDisplay(),
      actionButton: AnimatedActionButton(
        text: 'Adicionar Registro',
        icon: Icons.add,
        onPressed: () => _showAddBPDialog(context),
      ),
    );
  }

  void _showAddBPDialog(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final heartRateController = TextEditingController();
    final timeController = TextEditingController(
      text: DateFormat('HH:mm').format(DateTime.now()),
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => HealthDataEntryDialog(
        title: 'Adicionar Pressão Arterial',
        formFields: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: systolicController,
                        label: 'Sistólica',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          final systolic = int.tryParse(value);
                          if (systolic == null || systolic <= 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: diastolicController,
                        label: 'Diastólica',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          final diastolic = int.tryParse(value);
                          if (diastolic == null || diastolic <= 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: heartRateController,
                  label: 'Frequência Cardíaca (bpm)',
                  hint: 'Opcional',
                  keyboardType: TextInputType.number,
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
            final systolic = int.parse(systolicController.text);
            final diastolic = int.parse(diastolicController.text);
            int? heartRate;
            if (heartRateController.text.isNotEmpty) {
              heartRate = int.tryParse(heartRateController.text);
            }

            final healthService = Provider.of<HealthService>(
              context,
              listen: false,
            );
            healthService.addBloodPressureRecord(
              BloodPressureRecord(
                date: DateTime.now(),
                time: timeController.text,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro de pressão arterial adicionado'),
              ),
            );
          }
        },
      ),
    );
  }
  
  HealthDataEntryDialog({required String title, required List<Form> formFields, required Null Function() onSave}) {}
}

class BloodPressureDataDisplay extends StatelessWidget {
  const BloodPressureDataDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final healthService = Provider.of<HealthService>(context);
    final DateTime today = DateTime.now();
    final List<BloodPressureRecord> todayRecords = healthService.getBPForDate(
      today,
    );

    Color getBPColor(int systolic, int diastolic) {
      if (systolic >= 140 || diastolic >= 90) return AppColors.bpHigh;
      if (systolic >= 130 || diastolic >= 85) {
        return AppColors.bpPre;
      }
      if (systolic < 90 || diastolic < 60) return AppColors.bpHigh;
      return AppColors.bpNormal;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MONITORAMENTO PRESSÃO ARTERIAL',
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
                Icon(Icons.favorite_border, size: 48, color: Colors.grey),
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
              final bpColor = getBPColor(record.systolic, record.diastolic);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                        color: bpColor.withAlpha((0.3 * 255).round()),
                        width: 2,
                      ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: bpColor, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pressão Arterial',
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
                          Row(
                            children: [
                              Text(
                                '${record.systolic}/${record.diastolic} mmHg',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: bpColor,
                                ),
                              ),
                              if (record.heartRate != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${record.heartRate} bpm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.bpHigh,
                      ),
                      onPressed: () {
                        Provider.of<HealthService>(
                          context,
                          listen: false,
                        ).removeBloodPressureRecord(record);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Classificação da Pressão Arterial:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Normal: <120/80 mmHg',
                style: TextStyle(fontSize: 14, color: AppColors.bpNormal),
              ),
              Text(
                'Pré-hipertensão: 120-139/80-89 mmHg',
                style: TextStyle(fontSize: 14, color: AppColors.bpPre),
              ),
              Text(
                'Hipertensão: ≥140/90 mmHg',
                style: TextStyle(fontSize: 14, color: AppColors.bpHigh),
              ),
              Text(
                'Hipotensão: <90/60 mmHg',
                style: TextStyle(fontSize: 14, color: AppColors.bpHigh),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
