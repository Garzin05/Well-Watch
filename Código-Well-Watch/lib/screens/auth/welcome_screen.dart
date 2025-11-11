import 'package:flutter/material.dart';
import 'package:projetowell/constansts.dart';
import 'package:projetowell/widgets/custom_button.dart';
import 'package:projetowell/widgets/app_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _selectedUserType;

  void _selectUserType(String type) {
    setState(() {
      _selectedUserType = type;
    });
  }

  void _navigateToRegistration() {
    if (_selectedUserType == 'patient') {
      Navigator.pushNamed(context, '/patient-registration');
    } else if (_selectedUserType == 'doctor') {
      Navigator.pushNamed(context, '/doctor-registration');
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de cores padrão do projeto
    const Color primaryColor = Color(0xFF39D2C0); // Ciano do logo
    const Color backgroundDark = Color(0xFF0B1214); // Azul escuro do fundo

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          'Bem-vindo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TOPO
              Container(
                width: double.infinity,
                color: backgroundDark,
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Column(
                  children: [
                    const AppLogo(size: 80, color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // CONTEÚDO
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Sua saúde em boas mãos',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // MENSAGEM DE ORIENTAÇÃO
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Selecione como deseja se cadastrar',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // BOTÕES DE SELEÇÃO
                    _buildUserTypeSelection(primaryColor),
                    const SizedBox(height: 40),

                    // BOTÃO CONTINUAR
                    CustomButton(
                      text: 'Continuar para Cadastro',
                      icon: Icons.arrow_forward,
                      onPressed:
                          _selectedUserType != null ? _navigateToRegistration : null,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 20),

                    // BOTÃO LOGIN
                    CustomButton(
                      text: 'Já tenho conta',
                      icon: Icons.login,
                      onPressed: _navigateToLogin,
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection(Color primaryColor) {
    return Column(
      children: [
        UserTypeButton(
          title: 'Paciente',
          description: 'Cadastrar como paciente para consultas',
          icon: Icons.person,
          onPressed: () => _selectUserType('patient'),
          isSelected: _selectedUserType == 'patient',
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),
        UserTypeButton(
          title: 'Médico',
          description: 'Cadastrar como médico para atender pacientes',
          icon: Icons.medical_services,
          onPressed: () => _selectUserType('doctor'),
          isSelected: _selectedUserType == 'doctor',
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}

class UserTypeButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color primaryColor;

  const UserTypeButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    required this.isSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: primaryColor,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
