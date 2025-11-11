// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:projetowell/constansts.dart' hide AppColors;
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
    const Color primaryColor = Color(0xFF39D2C0); // Ciano do logo
    const Color darkBackground = Color(0xFF0B1214); // Azul escuro padrão

    return CustomScaffold(
      title: 'Login',
      showBackButton: false,
      backgroundColor: Colors.white, // <--- ADICIONADO (obrigatório)
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOPO COM LOGO
            Container(
              color: darkBackground,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 72, bottom: 28),
              child: Column(
                children: [
                  const AppLogo(size: 80, color: primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // CONTEÚDO
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bem-vindo de volta!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Acesse sua conta para continuar',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Escolha de papel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Paciente'),
                          labelStyle: TextStyle(
                            color: !_selectedIsDoctor ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: primaryColor,
                          selected: !_selectedIsDoctor,
                          onSelected: (v) {
                            setState(() => _selectedIsDoctor = !v);
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Médico'),
                          labelStyle: TextStyle(
                            color: _selectedIsDoctor ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: primaryColor,
                          selected: _selectedIsDoctor,
                          onSelected: (v) {
                            setState(() => _selectedIsDoctor = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos de login
                    CustomTextField(
                      labelText: 'Usuário',
                      hintText: 'Digite seu nome',
                      controller: _usernameController,
                      label: '',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
                      controller: _passwordController,
                      obscureText: true,
                      label: '',
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.passwordRecovery);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // BOTÃO LOGIN
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // DIVISOR
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ou continue com',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LOGIN SOCIAL
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
                    const SizedBox(height: 26),

                    // RODAPÉ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Novo por aqui?',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/welcome');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
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
