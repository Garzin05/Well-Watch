import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({super.key});

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPatient = '';
  String _selectedType = 'Consulta de Rotina';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar agendamento
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      appBar: AppBar(
        title: const Text('Agendar Consulta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPatientSelector(),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTimeField(),
                  const SizedBox(height: 16),
                  _buildAppointmentTypeSelector(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Agendar Consulta',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedPatient.isEmpty ? null : _selectedPatient,
      decoration: InputDecoration(
        labelText: 'Paciente',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      items: const [], // TODO: Implementar lista de pacientes
      onChanged: (value) {
        setState(() {
          _selectedPatient = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um paciente';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Data',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Horário',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.access_time),
      ),
      controller: TextEditingController(
        text: _selectedTime.format(context),
      ),
      onTap: () => _selectTime(context),
    );
  }

  Widget _buildAppointmentTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo de Consulta',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.medical_services),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Consulta de Rotina',
          child: Text('Consulta de Rotina'),
        ),
        DropdownMenuItem(
          value: 'Retorno',
          child: Text('Retorno'),
        ),
        DropdownMenuItem(
          value: 'Emergência',
          child: Text('Emergência'),
        ),
        DropdownMenuItem(
          value: 'Exames',
          child: Text('Exames'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value ?? 'Consulta de Rotina';
        });
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Observações',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }
}
