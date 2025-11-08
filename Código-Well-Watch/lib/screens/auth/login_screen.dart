import 'package:flutter/material.dart';
import 'package:projetowell/constansts.dart' hide AppColors;
import 'package:projetowell/utils/constants.dart'; // Certifique-se de que está importando corretamente
import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/social_login_button.dart';
import 'package:projetowell/widgets/app_logo.dart';
import 'package:projetowell/router.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _selectedIsDoctor = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    authService.username = _usernameController.text.isNotEmpty
        ? _usernameController.text
        : 'Usuário';
    authService.setRole(_selectedIsDoctor ? 'doctor' : 'patient');

    if (_selectedIsDoctor) {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorMenu);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.socialLogin(provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login com $provider bem-sucedido!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login com $provider: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Login',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.darkBackground,  // Sem parênteses
              width: double.infinity,
              padding: const EdgeInsets.only(top: 72, bottom: 28),
              child: Column(
                children: [
                  AppLogo(size: 72, color: AppColors.lightBlueAccent),  // Sem parênteses
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,  // Sem parênteses
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.welcomeTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGrayText,  // Sem parênteses
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.loginSubtitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.lightText,  // Sem parênteses
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Escolha de papel: Paciente ou Médico
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          key: const Key('chip_patient'),
                          label: const Text('Paciente'),
                          selected: !_selectedIsDoctor,
                          onSelected: (v) => setState(() {
                            _selectedIsDoctor = !v;
                          }),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          key: const Key('chip_doctor'),
                          label: const Text('Médico'),
                          selected: _selectedIsDoctor,
                          onSelected: (v) => setState(() {
                            _selectedIsDoctor = v;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      labelText: AppStrings.nameLabel,  // Usando AppStrings
                      hintText: '',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      labelText: AppStrings.passwordLabel,  // Usando AppStrings
                      hintText: '',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.passwordRecovery);  // Usando AppRoutes
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.forgotPasswordText,  // Usando AppStrings
                          style: TextStyle(
                            color: AppColors.lightBlueAccent,  // Sem parênteses
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlueAccent,  // Sem parênteses
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              AppStrings.loginButton,  // Usando AppStrings
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orDivider,  // Usando AppStrings
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialLoginButton.facebook(
                          onPressed: () => _handleSocialLogin('Facebook'),
                        ),
                        const SizedBox(width: 12),
                        SocialLoginButton.instagram(
                          onPressed: () => _handleSocialLogin('Instagram'),
                        ),
                        const SizedBox(width: 12),
                        SocialLoginButton.google(
                          onPressed: () => _handleSocialLogin('Google'),
                        ),
                        const SizedBox(width: 12),
                        SocialLoginButton.microsoft(
                          onPressed: () => _handleSocialLogin('Microsoft'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.newUserQuestion,  // Usando AppStrings
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/welcome');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.registerLink,  // Usando AppStrings
                            style: TextStyle(
                              color: AppColors.lightBlueAccent,  // Sem parênteses
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onBackPressed: () {},
    );
  }
}
