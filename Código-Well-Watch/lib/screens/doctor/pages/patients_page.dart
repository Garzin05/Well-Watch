import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/api_service.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/association_service.dart';
import 'package:projetowell/models/app_data.dart';

class PatientsPage extends StatefulWidget {
  final String? initialQuery;
  const PatientsPage({super.key, this.initialQuery});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late TextEditingController _searchController;
  List<Patient> _patients = [];
  final _assocSvc = AssociationService();
  final Set<String> _associatedPatientIds =
      {}; // patient IDs associated to this doctor

  static const primaryColor = Color.fromARGB(255, 2, 31, 48);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _loadPatients();
    _loadAssociations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssociations() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final doctorId = auth.userId;
      if (doctorId == null) return;
      final ids = await _assocSvc.listPatientIdsForDoctor(doctorId);
      _associatedPatientIds.clear();
      _associatedPatientIds.addAll(ids);
      if (mounted) setState(() {});
    } catch (e) {
      // ignore
    }
  }

  /// Carrega pacientes do AppData
  void _loadPatients() {
    _patients = List.from(appData.patients);
    _patients.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _patients
        .where((p) =>
            p.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddPatientPressed,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Adicionar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Pesquisar paciente',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum paciente encontrado',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          child: Text(p.initials),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_latestSubtitle(p),
                            style: const TextStyle(color: Colors.grey)),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Relatórios',
                              onPressed: () => _openReports(p),
                              icon: const Icon(Icons.insights_rounded),
                            ),
                            IconButton(
                              tooltip: 'Contatar',
                              onPressed: () => _contactPatient(p),
                              icon: const Icon(Icons.chat_bubble_rounded),
                            ),
                            IconButton(
                              tooltip: 'Adicionar medição',
                              onPressed: () => _addVital(p),
                              icon: const Icon(Icons.add_chart_rounded),
                            ),
                            // Association button: add/remove patient for current doctor
                            IconButton(
                              tooltip: _associatedPatientIds.contains(p.id)
                                  ? 'Remover paciente'
                                  : 'Associar paciente',
                              onPressed: () async {
                                final auth = Provider.of<AuthService>(context,
                                    listen: false);
                                final doctorId = auth.userId;
                                if (doctorId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'ID do médico não disponível.')));
                                  return;
                                }

                                bool ok;
                                if (_associatedPatientIds.contains(p.id)) {
                                  ok = await _assocSvc.removePatientFromDoctor(
                                      doctorId: doctorId, patientId: p.id);
                                } else {
                                  ok = await _assocSvc.addPatientToDoctor(
                                      doctorId: doctorId, patientId: p.id);
                                }

                                if (ok) {
                                  await _loadAssociations();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(_associatedPatientIds
                                                  .contains(p.id)
                                              ? 'Paciente associado.'
                                              : 'Paciente removido.')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Falha ao atualizar associação.')));
                                }
                              },
                              icon: Icon(_associatedPatientIds.contains(p.id)
                                  ? Icons.link_off_rounded
                                  : Icons.person_add_rounded),
                            ),
                          ],
                        ),
                        onTap: () => _openReports(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddPatientPressed() async {
    final emailCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar paciente'),
        content: TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email do paciente',
            hintText: 'exemplo@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Buscar')),
        ],
      ),
    );

    if (result != true) return;
    final email = emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe o email.')));
      return;
    }

    debugPrint('=== Iniciando busca de paciente ===');
    debugPrint('Email procurado: $email');

    // Buscar paciente do backend (API)
    final apiResponse = await ApiService.getPatientByEmail(email);
    debugPrint('API Response: $apiResponse');

    if (apiResponse['status'] != true) {
      debugPrint(
          'Paciente não encontrado, buscando lista de emails disponíveis...');
      // Buscar lista de emails disponíveis
      final emailListResponse = await ApiService.getAllPatientEmails();
      debugPrint('Email List Response: $emailListResponse');

      // Deserialização robusta da lista de emails
      List<String> availableEmails = [];
      if (emailListResponse['status'] == true &&
          emailListResponse['emails'] != null) {
        try {
          final emailsData = emailListResponse['emails'];
          debugPrint('Tipo de emailsData: ${emailsData.runtimeType}');
          if (emailsData is List) {
            availableEmails = emailsData.map((e) => e.toString()).toList();
            debugPrint('Emails extraídos: $availableEmails');
          } else {
            debugPrint('Esperado List, recebido: ${emailsData.runtimeType}');
          }
        } catch (e) {
          debugPrint('Erro ao deserializar emails: $e');
        }
      }

      final message = availableEmails.isEmpty
          ? 'Nenhum paciente cadastrado. Emails disponíveis: nenhum'
          : 'Paciente não encontrado. Emails cadastrados: ${availableEmails.join(", ")}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
      );
      return;
    }

    // Extrair dados do paciente retornado
    final patientData = apiResponse['patient'] as Map<String, dynamic>;
    final patientId = patientData['id'].toString();
    final patientIdInt = int.tryParse(patientId) ?? 0;
    final patientName = patientData['name'] as String;

    debugPrint('Paciente encontrado: ID=$patientId, Nome=$patientName');

    // Buscar medições do paciente
    debugPrint('Buscando medições para patient_id=$patientIdInt...');
    final measurementsResponse =
        await ApiService.getPatientMeasurements(patientIdInt);

    List<VitalRecord> records = [];
    if (measurementsResponse['status'] == true &&
        measurementsResponse['measurements'] != null) {
      try {
        final measurements = measurementsResponse['measurements'] as List;
        debugPrint('Encontradas ${measurements.length} medições');

        for (final m in measurements) {
          if (m is Map<String, dynamic>) {
            // Converter medição para VitalRecord
            // type_id: 1=glucose, 2=pressure, 3=weight
            final typeId = m['type_id'] as int?;
            final recordedAt = m['recorded_at'] as String?;

            VitalRecord record = VitalRecord(
              date: recordedAt != null
                  ? DateTime.parse(recordedAt)
                  : DateTime.now(),
              glucoseMgDl:
                  typeId == 1 ? (m['glucose_value'] as num?)?.toDouble() : null,
              systolic: typeId == 2 ? m['systolic'] as int? : null,
              diastolic: typeId == 2 ? m['diastolic'] as int? : null,
              weightKg:
                  typeId == 3 ? (m['weight_value'] as num?)?.toDouble() : null,
            );
            records.add(record);
            debugPrint('Medição adicionada: type=$typeId, date=${record.date}');
          }
        }
      } catch (e) {
        debugPrint('Erro ao processar medições: $e');
      }
    } else {
      debugPrint('Nenhuma medição encontrada para o paciente');
    }

    debugPrint('Total de records a adicionar: ${records.length}');

    // Converter para Patient local
    final patient = Patient(
      id: patientId,
      name: patientName,
      records: records,
    );

    // Adicionar a appData
    appData.addPatientObject(patient);

    // Associar ao médico logado
    final auth = Provider.of<AuthService>(context, listen: false);
    final doctorId = auth.userId;
    if (doctorId != null) {
      await _assocSvc.addPatientToDoctor(
          doctorId: doctorId, patientId: patientId);
      await _loadAssociations();
    }

    _loadPatients();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$patientName associado com sucesso.')),
    );
  }

  String _latestSubtitle(Patient p) {
    final last = p.latestRecord();
    if (last == null) return 'Sem dados';

    final d = last.date;
    String two(int n) => n.toString().padLeft(2, '0');
    final when = '${two(d.day)}/${two(d.month)}/${d.year}';

    final g = last.glucoseMgDl != null
        ? '${last.glucoseMgDl!.toStringAsFixed(0)} mg/dL'
        : '-';

    final pr = (last.systolic != null && last.diastolic != null)
        ? '${last.systolic}/${last.diastolic}'
        : '-';

    final w =
        last.weightKg != null ? '${last.weightKg!.toStringAsFixed(1)} kg' : '-';

    return 'Último: $when • Glicose $g • PA $pr • Peso $w';
  }

  /// ----------- CORRIGIDO AQUI -------------
  void _openReports(Patient p) async {
    appData.selectedPatient = p;

    await Navigator.pushNamed(context, '/reports');

    if (!mounted) return;
    setState(() {});
  }

  /// ------------------------------------------

  void _contactPatient(Patient p) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
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
                  Expanded(
                    child: Text(
                      'Enviar mensagem para ${p.name.split(' ').first}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Escreva sua mensagem...'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Mensagem enviada (simulado).')),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Enviar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _addVital(Patient p) {
    final gCtrl = TextEditingController();
    final sCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    final wCtrl = TextEditingController();
    DateTime when = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
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
                  Expanded(
                      child: Text('Adicionar medição — ${p.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height: 8),
                TextField(
                    controller: gCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                        const InputDecoration(labelText: 'Glicose (mg/dL)')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: sCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Sistólica'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: dCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Diastólica'))),
                ]),
                const SizedBox(height: 8),
                TextField(
                    controller: wCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso (kg)')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text('Data: ${_formatDate(when)}')),
                  IconButton(
                    tooltip: 'Escolher data e hora',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: when,
                      );
                      if (picked != null) {
                        final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(when));
                        if (t != null) {
                          when = DateTime(picked.year, picked.month, picked.day,
                              t.hour, t.minute);
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded),
                  ),
                ]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      double? g =
                          double.tryParse(gCtrl.text.replaceAll(',', '.'));
                      int? s = int.tryParse(sCtrl.text);
                      int? d = int.tryParse(dCtrl.text);
                      double? w =
                          double.tryParse(wCtrl.text.replaceAll(',', '.'));

                      if (g == null && s == null && d == null && w == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Informe ao menos um valor.')),
                        );
                        return;
                      }

                      appData.addVital(
                        patientId: p.id,
                        date: when,
                        glucoseMgDl: g,
                        systolic: s,
                        diastolic: d,
                        weightKg: w,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medição adicionada.')),
                      );

                      setState(() {});
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Salvar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
