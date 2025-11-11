import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/models/patient_model.dart';
import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/custom_dropdown_field.dart';
import 'package:projetowell/widgets/custom_chips_input.dart';
import 'package:projetowell/widgets/custom_button.dart';
import 'package:projetowell/services/storage_service.dart';
import 'package:projetowell/screens/auth/registration_success_screen.dart';
import 'package:projetowell/screens/auth/login_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _gender = 'Masculino';
  String _bloodType = 'A+';
  List<String> _allergies = [];
  List<String> _medications = [];

  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Outro'];
  final List<String> _bloodTypeOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'\d')},
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final isEmailRegistered = await _storageService.isEmailRegistered(email);

      if (isEmailRegistered) {
        _showError('Este e-mail já está cadastrado.');
        setState(() => _isLoading = false);
        return;
      }

      final age = int.tryParse(_ageController.text);
      if (age == null || age <= 0) {
        _showError('Por favor, insira uma idade válida.');
        setState(() => _isLoading = false);
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('As senhas não coincidem.');
        setState(() => _isLoading = false);
        return;
      }

      final patient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: email,
        phone: _phoneController.text.trim(),
        age: age,
        gender: _gender,
        bloodType: _bloodType,
        address: _addressController.text.trim(),
        allergies: _allergies,
        currentMedications: _medications,
        password: _passwordController.text.trim(),
        createdAt: DateTime.now().toIso8601String(), cpf: '',
      );

      await _storageService.savePatient(patient);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationSuccessScreen(
            userType: 'patient',
            userName: patient.name,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      _showError('Erro ao salvar os dados. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      scaffoldBackgroundColor: const Color(0xFF0B1214),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF39D2C0),
        brightness: Brightness.dark,
        primary: const Color(0xFF39D2C0),
        secondary: const Color(0xFF2FA89E),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );

    return Theme(
      data: theme,
      child: CustomScaffold(
        title: 'Cadastro de Paciente',
        showBackButton: true,
        onBackPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        backgroundColor: const Color(0xFF0B1214),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPersonalInfoSection(theme),
                  const SizedBox(height: 32),
                  _buildHealthInfoSection(theme),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações Pessoais', style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          CustomTextField(
            labelText: 'Nome Completo',
            hintText: 'Digite seu nome completo',
            controller: _nameController,
            prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary), label: '',
          ),
          CustomTextField(
            labelText: 'E-mail',
            hintText: 'Digite seu e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary), label: '',
          ),
          CustomTextField(
            labelText: 'Telefone',
            hintText: '(00) 00000-0000',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary), label: '',
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Idade',
                  hintText: 'Digite sua idade',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.cake, color: theme.colorScheme.primary), label: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdownField<String>(
                  labelText: 'Gênero',
                  value: _gender,
                  items: _genderOptions,
                  onChanged: (value) =>
                      setState(() => _gender = value ?? _gender),
                  prefixIcon:
                      Icon(Icons.people, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          CustomTextField(
            labelText: 'Endereço',
            hintText: 'Digite seu endereço completo',
            controller: _addressController,
            prefixIcon: Icon(Icons.home, color: theme.colorScheme.primary), label: '',
          ),
          CustomTextField(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary), label: '',
          ),
          CustomTextField(
            labelText: 'Confirme sua senha',
            hintText: 'Repita sua senha',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            }, label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection(ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações de Saúde', style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          CustomDropdownField<String>(
            labelText: 'Tipo Sanguíneo',
            value: _bloodType,
            items: _bloodTypeOptions,
            onChanged: (value) =>
                setState(() => _bloodType = value ?? _bloodType),
            prefixIcon: Icon(Icons.bloodtype, color: theme.colorScheme.primary),
          ),
          CustomChipsInput(
            labelText: 'Alergias',
            hintText: 'Adicionar alergia',
            values: _allergies,
            onChanged: (value) => setState(() => _allergies = value),
          ),
          CustomChipsInput(
            labelText: 'Medicações Atuais',
            hintText: 'Adicionar medicação',
            values: _medications,
            onChanged: (value) => setState(() => _medications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: CustomButton(
        text: 'Finalizar Cadastro',
        icon: Icons.check,
        onPressed: _submitForm,
        isLoading: _isLoading,
      ),
    );
  }
}
