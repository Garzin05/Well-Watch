import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/app_logo.dart';
import '../services/auth_service.dart';
import '../widgets/custom_scaffold.dart'; // Importe o CustomScaffold

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login bem-sucedido!')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${e.toString()}')),
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
  }

  void _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.socialLogin(provider);
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
      showBackButton: false, // Não mostra o botão de voltar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com logo
            Container(
              color: AppColors.darkBackground,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              child: Column(
                children: [
                  const AppLogo(size: 80, color: Color(0xFF39D2C0)),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Formulário de login
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.welcomeTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.lightText,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Campo de usuário
                    CustomTextField(
                      labelText: AppStrings.nameLabel,
                      hintText: '',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 16),

                    // Campo de senha
                    CustomTextField(
                      labelText: AppStrings.passwordLabel,
                      hintText: '',
                      controller: _passwordController,
                      obscureText: true,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade de recuperação de senha (a ser implementada)'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.forgotPasswordText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                              AppStrings.loginButton,
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
                              AppStrings.orDivider,
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
                        const SizedBox(width: 16),
                        SocialLoginButton.instagram(
                          onPressed: () => _handleSocialLogin('Instagram'),
                        ),
                        const SizedBox(width: 16),
                        SocialLoginButton.google(
                          onPressed: () => _handleSocialLogin('Google'),
                        ),
                        const SizedBox(width: 16),
                        SocialLoginButton.microsoft(
                          onPressed: () => _handleSocialLogin('Microsoft'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.newUserQuestion,
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
                            AppStrings.registerLink,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
      ), onBackPressed: () {  },
    );
  }
}
