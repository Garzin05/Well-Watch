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

class DiabetesPage extends StatelessWidget {
  const DiabetesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarBasePage(
      title: 'Glicemia',
      dataDisplay: const DiabetesDisplay(),
      actionButton: AnimatedActionButton(
        text: 'Adicionar Glicemia',
        icon: Icons.add,
        onPressed: () => _showAddGlucoseDialog(context),
      ),
    );
  }

  void _showAddGlucoseDialog(BuildContext context) {
    final glucoseController = TextEditingController();
    final timeController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => HealthDataEntryDialog(
        title: 'Adicionar registro de glicose',
        formFields: [
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: glucoseController,
                  label: 'Glicose (mg/dL)',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o valor' : null,
                  prefixIcon: Icons.water_drop,
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
          ),
        ],
        onSave: () {
          if (!formKey.currentState!.validate()) return;

          final auth = Provider.of<AuthService>(context, listen: false);
          debugPrint('[DIABETES_PAGE] 🔐 auth.userId (raw): ${auth.userId}');

          final userId = int.tryParse(auth.userId ?? '') ?? 0;
          debugPrint('[DIABETES_PAGE] 🔐 userId (converted): $userId');

          if (userId == 0) {
            debugPrint('[DIABETES_PAGE] ❌ userId é 0! Abortando.');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Erro: Usuário não identificado')));
            Navigator.pop(context);
            return;
          }

          final glucoseValue =
              double.tryParse(glucoseController.text.trim()) ?? 0.0;
          debugPrint('[DIABETES_PAGE] 📊 Glicose valor: $glucoseValue mg/dL');

          final healthService =
              Provider.of<HealthService>(context, listen: false);

          debugPrint(
              '[DIABETES_PAGE] 📤 Chamando healthService.addGlucoseRecord()');
          healthService.addGlucoseRecord(
            userId,
            GlucoseRecord(
              glucoseLevel: glucoseValue,
              time: timeController.text.trim(),
              date: DateTime.now(),
            ),
          );

          debugPrint('[DIABETES_PAGE] ✅ addGlucoseRecord() chamado');
          Navigator.pop(context);
        },
      ),
    );
  }
}

class DiabetesDisplay extends StatelessWidget {
  const DiabetesDisplay({super.key});

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

    final records = healthService.getGlucoseForDate(userId, today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REGISTROS DE GLICEMIA',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Nenhum registro hoje',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          Column(
            children: records
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
                        const Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${r.glucoseLevel.toStringAsFixed(0)} mg/dL - ${r.time}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors
                                  .darkBlueBackground, // <-- COR DO TEXTO ALTERADA
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            healthService.removeGlucoseRecord(userId, r);
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
