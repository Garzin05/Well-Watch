import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/storage_service.dart';
import 'registration_success_screen.dart';
import '../widgets/custom_scaffold.dart';  // Importando o CustomScaffold

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _crmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'\d')},
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _crmController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final isEmailRegistered = await _storageService.isEmailRegistered(_emailController.text);
        if (isEmailRegistered) {
          _showError('Este e-mail já está cadastrado');
          setState(() => _isLoading = false);
          return;
        }

        final doctor = Doctor(
          name: _nameController.text,
          email: _emailController.text,
          crm: _crmController.text,
          phone: _phoneController.text,
          specialty: _specialtyController.text,
          createdAt: DateTime.now().toIso8601String(),
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationSuccessScreen(
              userType: 'doctor',
              userName: doctor.name,
            ),
          ),
          (route) => false,
        );
      } catch (e) {
        _showError('Erro ao salvar dados');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      title: 'Cadastro de Médico',
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDoctorInfoSection(theme),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ), onBackPressed: () {  },
    );
  }

  Widget _buildDoctorInfoSection(ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Médico',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            labelText: 'Nome Completo',
            hintText: 'Digite o nome completo',
            controller: _nameController,
            prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          CustomTextField(
            labelText: 'E-mail',
            hintText: 'Digite o e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
          ),
          CustomTextField(
            labelText: 'CRM',
            hintText: 'Digite o número do CRM',
            controller: _crmController,
            prefixIcon: Icon(Icons.badge, color: theme.colorScheme.primary),
          ),
          CustomTextField(
            labelText: 'Telefone',
            hintText: '(00) 00000-0000',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
          ),
          CustomTextField(
            labelText: 'Especialidade',
            hintText: 'Digite a especialidade médica',
            controller: _specialtyController,
            prefixIcon: Icon(Icons.medical_services, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: CustomButton(
        text: 'Finalizar Cadastro',
        icon: Icons.check,
        onPressed: _submitForm,
        isLoading: _isLoading,
      ),
    );
  }
}

class Doctor {
  final String name;
  final String email;
  final String crm;
  final String phone;
  final String specialty;
  final String createdAt;

  Doctor({
    required this.name,
    required this.email,
    required this.crm,
    required this.phone,
    required this.specialty,
    required this.createdAt,
  });
}
