import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/custom_button.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/screens/auth/registration_success_screen.dart';
import 'package:projetowell/services/storage_service.dart';
import 'package:projetowell/models/doctor_model.dart'; // ✅ modelo correto

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final isEmailRegistered = await _storageService.isEmailRegistered(_emailController.text);
        if (isEmailRegistered) {
          _showError('Este e-mail já está cadastrado.');
          setState(() => _isLoading = false);
          return;
        }

        // ✅ agora usando o modelo do arquivo doctor_model.dart
        var yearsOfExperience = null;
        final doctor = Doctor(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          crm: _crmController.text.trim(),
          phone: _phoneController.text.trim(),
          specialty: _specialtyController.text.trim(),
          password: _passwordController.text.trim(),
          createdAt: DateTime.now().toIso8601String(), id: '', clinicAddress: '', yearsOfExperience: yearsOfExperience, hospital: '', education: '', specialization: '', gender: '', skills: [], about: '', workingHours: [],
        );

        await _storageService.saveDoctor(doctor);

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
        _showError('Erro ao salvar dados. Tente novamente.');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

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
      ), onBackPressed: () {  },
    );
  }

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
            validator: (v) => v!.isEmpty ? 'Informe o nome completo' : null, label: '',
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
            }, label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'CRM',
            hintText: 'Digite o número do CRM',
            controller: _crmController,
            prefixIcon: const Icon(Icons.badge, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe o CRM' : null, label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Telefone',
            hintText: '(00) 00000-0000',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            prefixIcon: const Icon(Icons.phone, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe o telefone' : null, label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Especialidade',
            hintText: 'Digite a especialidade médica',
            controller: _specialtyController,
            prefixIcon: const Icon(Icons.medical_services, color: Colors.white),
            validator: (v) => v!.isEmpty ? 'Informe a especialidade' : null, label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, color: Colors.white),
            validator: (v) => v!.length < 6 ? 'Mínimo de 6 caracteres' : null, label: '',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Confirme a Senha',
            hintText: 'Confirme sua senha',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
            validator: (v) =>
                v != _passwordController.text ? 'As senhas não coincidem' : null, label: '',
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
