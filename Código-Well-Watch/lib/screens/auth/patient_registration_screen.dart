import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/custom_dropdown_field.dart';
import 'package:projetowell/widgets/custom_chips_input.dart';
import 'package:projetowell/widgets/custom_button.dart';
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

  // ===========================================
  // ✅ Função para enviar o cadastro ao PHP
  // ===========================================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Detecta se é Web ou Emulador Android
      final String baseUrl = kIsWeb
          ? "http://localhost/WellWatchAPI"
          : "http://10.0.2.2/WellWatchAPI";

      final Uri url = Uri.parse("$baseUrl/register_patient.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "telefone": _phoneController.text.trim(),
          "idade": _ageController.text.trim(),
          "genero": _gender,
          "endereco": _addressController.text.trim(),
          "tipo_sanguineo": _bloodType,
          "alergias": _allergies.join(", "),
          "medicacoes_atuais": _medications.join(", "),
          "altura": null,
          "peso_inicial": null
        }),
      );

      // Converte a resposta JSON
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationSuccessScreen(
              userType: 'patient',
              userName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
          (route) => false,
        );
      } else {
        _showError(data["message"] ?? "Erro ao cadastrar paciente.");
      }
    } catch (e) {
      _showError("Erro de conexão com o servidor.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===========================================
  // ✅ Mensagem de erro
  // ===========================================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ===========================================
  // ✅ INTERFACE GRÁFICA
  // ===========================================
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
            prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
            label: '',
          ),
          CustomTextField(
            labelText: 'E-mail',
            hintText: 'Digite seu e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
            label: '',
          ),
          CustomTextField(
            labelText: 'Telefone',
            hintText: '(00) 00000-0000',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
            label: '',
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Idade',
                  hintText: 'Digite sua idade',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  prefixIcon:
                      Icon(Icons.cake, color: theme.colorScheme.primary),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua idade';
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Idade deve conter apenas números';
                    }
                    if (age < 1 || age > 122) {
                      return 'Idade deve estar entre 1 e 122 anos';
                    }
                    return null;
                  },
                  label: '',
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
            prefixIcon: Icon(Icons.home, color: theme.colorScheme.primary),
            label: '',
          ),
          CustomTextField(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
            label: '',
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
            },
            label: '',
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
