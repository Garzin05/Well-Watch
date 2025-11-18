import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/models/health_data.dart';
import 'package:projetowell/screens/main/calendar_base_page.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/widgets/health_data_entry_dialog.dart';
import 'package:projetowell/widgets/health_widgets.dart';
import 'package:projetowell/utils/constants.dart';

class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Pressão Arterial',
      dataDisplay: const BloodPressureDisplay(),
      actionButton: AnimatedActionButton(
        text: 'Adicionar Pressão',
        icon: Icons.add,
        onPressed: () => _showAddBpDialog(context),
      ),
    );
  }

  void _showAddBpDialog(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final heartRateController = TextEditingController();
    final timeController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => HealthDataEntryDialog(
        title: 'Adicionar Pressão Arterial',
        formFields: [
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: systolicController,
                  label: 'Sistólica (mmHg)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a sistólica' : null,
                  prefixIcon: Icons.favorite,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: diastolicController,
                  label: 'Diastólica (mmHg)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a diastólica' : null,
                  prefixIcon: Icons.favorite_border,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: heartRateController,
                  label: 'Frequência Cardíaca (bpm) — opcional',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hint: 'Opcional',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: timeController,
                  label: 'Horário',
                  keyboardType: TextInputType.datetime,
                  validator: (v) {
                    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
                    if (v == null || v.isEmpty) return 'Informe o horário';
                    if (!regex.hasMatch(v)) return 'Use formato HH:MM';
                    return null;
                  },
                  prefixIcon: Icons.access_time,
                ),
              ],
            ),
          )
        ],
        onSave: () {
          if (!formKey.currentState!.validate()) return;

          final auth = Provider.of<AuthService>(context, listen: false);
          final userId = int.tryParse(auth.userId ?? '') ?? 0;

          if (userId == 0) {
            Navigator.pop(context);
            return;
          }

          final healthService =
              Provider.of<HealthService>(context, listen: false);

          final int? heartRate = heartRateController.text.isNotEmpty
              ? int.tryParse(heartRateController.text)
              : null;

          healthService.addBloodPressureRecord(
            userId,
            BloodPressureRecord(
              date: DateTime.now(),
              time: timeController.text,
              systolic: int.parse(systolicController.text),
              diastolic: int.parse(diastolicController.text),
              heartRate: heartRate,
            ),
          );

          Navigator.pop(context);
        },
      ),
    );
  }
}

class BloodPressureDisplay extends StatelessWidget {
  const BloodPressureDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final healthService = Provider.of<HealthService>(context);

    final userId = int.tryParse(auth.userId ?? '') ?? 0;
    final today = DateTime.now();

    if (userId == 0) {
      return const Text(
        "Carregando dados...",
        style: TextStyle(color: Colors.grey),
      );
    }

    final todayRecords = healthService.getBPForDate(userId, today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REGISTROS DE PRESSÃO',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (todayRecords.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Nenhum registro hoje',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          Column(
            children: todayRecords
                .map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkBlueBackground.withAlpha(80),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${r.systolic}/${r.diastolic} mmHg - ${r.time}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors
                                  .darkBlueBackground, // <-- COR ALTERADA
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            healthService.removeBloodPressureRecord(userId, r);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registro removido'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
