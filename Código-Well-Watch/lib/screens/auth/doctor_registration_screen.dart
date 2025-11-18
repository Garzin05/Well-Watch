import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/custom_button.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/screens/auth/registration_success_screen.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _crmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------
  // ENVIAR FORMULÁRIO
  // ----------------------------------------------------------------------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("As senhas não coincidem!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      const String apiUrl = "http://localhost/WellWatchAPI/register_doctor.php";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "crm": _crmController.text.trim(),
          "phone": _phoneController.text.trim(),
          "especialidade": _specialtyController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        if (!mounted) return;

        // ------------------------------------------------------------------
        // AGORA O AUTO-LOGIN VAI FUNCIONAR PARA MÉDICO!
        // ------------------------------------------------------------------
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationSuccessScreen(
              userType: 'doctor',
              userName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
          (route) => false,
        );
      } else {
        _showError(data["message"] ?? "Erro ao cadastrar médico.");
      }
    } catch (e) {
      _showError("Erro de conexão com o servidor.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------------
  // EXIBIR ERRO
  // ----------------------------------------------------------------------
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ----------------------------------------------------------------------
  // INTERFACE
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Cadastro de Médico',
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
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: Text(
                      'Cadastro Médico',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildDoctorInfoSection(),
                const SizedBox(height: 35),
                _buildSubmitButton(),
                const SizedBox(height: 20),
                _buildBackToLoginButton(context),
              ],
            ),
          ),
        ),
      ),
      onBackPressed: () {},
    );
  }

  // ----------------------------------------------------------------------
  // CAMPOS DE CADASTRO
  // ----------------------------------------------------------------------
  Widget _buildDoctorInfoSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          CustomTextField(
            labelText: 'Nome Completo',
            hintText: 'Digite o nome completo',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe o nome completo' : null,
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'E-mail',
            hintText: 'Digite o e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email, color: Colors.white),
            validator: (v) {
              if (v!.isEmpty) return 'Informe o e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'CRM',
            hintText: 'Digite o número do CRM',
            controller: _crmController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            prefixIcon: const Icon(Icons.badge, color: Colors.white),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Informe o CRM';
              }
              if (v.length < 4) {
                return 'CRM deve ter pelo menos 4 dígitos';
              }
              if (v.length > 6) {
                return 'CRM não pode ter mais de 6 dígitos';
              }
              return null;
            },
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Telefone',
            hintText: '(00) 00000-0000',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            prefixIcon: const Icon(Icons.phone, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Especialidade',
            hintText: 'Digite a especialidade médica',
            controller: _specialtyController,
            prefixIcon: const Icon(Icons.medical_services, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe a especialidade' : null,
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, color: Colors.white),
            validator: (v) => v!.length < 6 ? 'Mínimo de 6 caracteres' : null,
            label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Confirme a Senha',
            hintText: 'Confirme sua senha',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
            validator: (v) => v != _passwordController.text
                ? 'As senhas não coincidem'
                : null,
            label: '',
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
        icon: Icons.check_circle,
        onPressed: _submitForm,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildBackToLoginButton(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text(
          'Voltar para Login',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
