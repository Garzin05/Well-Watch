// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/constansts.dart' hide AppColors;
import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/social_login_button.dart';
import 'package:projetowell/widgets/app_logo.dart';
import 'package:projetowell/router.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/services/api_service.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';

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

  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedIsDoctor ? 'doctor' : 'patient';

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('[LOGIN_SCREEN] 🔐 Login iniciado: email=$email, role=$role');

      // Preferimos usar o AuthService (ele já salva no SharedPreferences)
      final auth = Provider.of<AuthService>(context, listen: false);
      final logged = await auth.login(email, password, role: role);

      debugPrint(
          '[LOGIN_SCREEN] 🔐 Login status: $logged, userId=${auth.userId}');

      if (logged) {
        debugPrint(
            '[LOGIN_SCREEN] ✅ Login bem-sucedido! userId=${auth.userId}');

        // AuthService já salvou username, email, userId, role no SharedPreferences
        // Agora atualizamos o HealthService com o userId numérico
        final healthService =
            Provider.of<HealthService>(context, listen: false);

        // Proteção: se auth.userId for nulo, tentamos buscar no servidor direto (fallback)
        if (auth.userId != null && auth.userId!.isNotEmpty) {
          final int userId = int.tryParse(auth.userId!) ?? 0;
          debugPrint(
              '[LOGIN_SCREEN] 📊 Convertido userId String→Int: ${auth.userId} → $userId');
          healthService.currentUserId = userId;
        } else {
          debugPrint(
              '[LOGIN_SCREEN] ⚠️ auth.userId é nulo! Usando fallback...');
          // fallback: chamar ApiService.login direto para obter id (raro)
          final response = await ApiService.login(
              email: email, password: password, role: role);
          if (response["status"] == true && response["user"]?["id"] != null) {
            final userId = response["user"]["id"];
            debugPrint('[LOGIN_SCREEN] 🔄 Fallback userId obtido: $userId');
            healthService.currentUserId =
                userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
            // opcional: atualizar auth.userId também
            auth.userId = healthService.currentUserId?.toString();
            await auth.saveLocal();
          }
        }

        // notifica para garantir que listeners atualizem
        // healthService.notifyListeners();  // Comentado: só pode ser chamado dentro da classe

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login realizado com sucesso!"),
              backgroundColor: Colors.green),
        );

        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, AppRoutes.doctorMenu);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        debugPrint('[LOGIN_SCREEN] ❌ Credenciais inválidas');
        _showError("E-mail ou senha incorretos.");
      }
    } catch (e) {
      debugPrint('[LOGIN_SCREEN] ❌ Erro: $e');
      _showError("Erro ao conectar com o servidor.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _handleSocialLogin(String provider) async {
    _showError("Login com $provider ainda não implementado.");
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF39D2C0);
    const Color darkBackground = Color(0xFF0B1214);

    return CustomScaffold(
      title: 'Login',
      showBackButton: false,
      backgroundColor: Colors.white,
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
                    const Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
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

                    // Escolha de tipo de usuário
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Paciente'),
                          labelStyle: TextStyle(
                            color: !_selectedIsDoctor
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: primaryColor,
                          selected: !_selectedIsDoctor,
                          onSelected: (v) =>
                              setState(() => _selectedIsDoctor = !v),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Médico'),
                          labelStyle: TextStyle(
                            color: _selectedIsDoctor
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: primaryColor,
                          selected: _selectedIsDoctor,
                          onSelected: (v) =>
                              setState(() => _selectedIsDoctor = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos de login
                    CustomTextField(
                      labelText: 'E-mail',
                      hintText: 'Digite seu e-mail',
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
                          Navigator.pushNamed(
                              context, AppRoutes.passwordRecovery);
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
                        SocialLoginButton.google(
                          onPressed: () => _handleSocialLogin('Google'),
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
                          ),
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
