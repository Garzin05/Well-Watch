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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bem-vindo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.darkBackground,
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Column(
                  children: [
                    const AppLogo(size: 80, color: Color(0xFF39D2C0)),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Sua saúde em boas mãos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Selecione como deseja se cadastrar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildUserTypeSelection(theme),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: 'Continuar para Cadastro',
                      icon: Icons.arrow_forward,
                      onPressed: _selectedUserType != null
                          ? _navigateToRegistration
                          : null,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 20),
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

  Widget _buildUserTypeSelection(ThemeData theme) {
    return Column(
      children: [
        UserTypeButton(
          title: 'Paciente',
          description: 'Cadastrar como paciente para consultas',
          icon: Icons.person,
          onPressed: () => _selectUserType('patient'),
          isSelected: _selectedUserType == 'patient',
        ),
        const SizedBox(height: 16),
        UserTypeButton(
          title: 'Médico',
          description: 'Cadastrar como médico para atender pacientes',
          icon: Icons.medical_services,
          onPressed: () => _selectUserType('doctor'),
          isSelected: _selectedUserType == 'doctor',
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

  const UserTypeButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha((0.1 * 255).round())
              : Colors.white,
          border: Border.all(
            color:
                isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
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
