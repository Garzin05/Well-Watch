import 'package:flutter/material.dart';
import 'package:projetowell/constansts.dart';
import 'package:projetowell/router.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/widgets/app_logo.dart';
import 'package:projetowell/widgets/custom_scaffold.dart';
import 'package:projetowell/widgets/custom_text_field.dart';
import 'package:projetowell/widgets/social_login_button.dart';
import 'package:provider/provider.dart';

class AppColors {
  static const Color darkBlueBackground = Color(0xFF0D1B2A); // Dark background
  static const Color darkBackground = Color(0xFF0D1B2A); // Dark background
  static const Color darkGrayText = Color(0xFF4A4A4A); // Dark gray text
  static const Color lightBlueAccent = Color(0xFF1E88E5); // Light blue accent (never null)
  static const Color lightText = Color(0xFF6B7280); // Secondary text used on light surfaces
  static const Color cardBackground = Color(0xFFF5F7FA); // Card / surface background
  static const Color glucoseLow = Color(0xFFD32F2F); // Red for low glucose
  static const Color glucoseHigh = Color(0xFFF57C00); // Orange for high glucose
  static const Color glucoseNormal = Color(0xFF2E7D32); // Green for normal glucose
  static const Color bpHigh = Color(0xFFD32F2F); // Red for high blood pressure
  static const Color bpPre = Color(0xFFF57C00); // Orange for prehypertension
  static const Color bpNormal = Color(0xFF2E7D32); // Green for normal blood pressure
  static const Color diabetes = Color(0xFFEF6C00); // Deep orange for diabetes
  static const Color agenda = Color(0xFF3F51B5); // Indigo for agenda
  static const Color weightColor = Color.fromARGB(255, 110, 142, 177); // Weight color
  static const Color reports = Color(0xFF00897B); // Teal for reports
  static const Color others = Color(0xFF9E9E9E);

  static Color? get primaryBlue => null;

  static Null get lightGrayBorder => null; // Grey for other purposes
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightBlueAccent, // Garantido que sempre é Color
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF39D2C0),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFEDEDED),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightBlueAccent, // Garantido que sempre é Color
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF39D2C0),
    secondary: Colors.black,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF39D2C0),
  scaffoldBackgroundColor: const Color(0xFF12171F),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF12171F),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleSmall: TextStyle(fontSize: 14, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2A38),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightBlueAccent, // Garantido que sempre é Color
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(primary: const Color(0xFF39D2C0), secondary: Colors.white),
);

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
      print("Função removida: setRole()");(_selectedIsDoctor ? 'doctor' : 'patient');

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login com $provider bem-sucedido!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao fazer login com $provider: ${e.toString()}')),
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
    var backgroundColor;
    return CustomScaffold(
      title: 'Login',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.darkBackground,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 72, bottom: 28),
              child: Column(
                children: [
                  AppLogo(size: 72, color: AppColors.lightBlueAccent),
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
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGrayText,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.loginSubtitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.lightText,
                          ),
                    ),
                    const SizedBox(height: 24),
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
                      labelText: AppStrings.nameLabel,
                      hintText: '',
                      controller: _usernameController, label: '',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      labelText: AppStrings.passwordLabel,
                      hintText: '',
                      controller: _passwordController,
                      obscureText: true, label: '',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AppRoutes.passwordRecovery);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.forgotPasswordText,
                          style: TextStyle(
                            color: AppColors.lightBlueAccent,
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
                        backgroundColor: AppColors.lightBlueAccent,
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
                              color: AppColors.lightBlueAccent,
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
      onBackPressed: () {}, backgroundColor: backgroundColor,
    );
  }
}

extension on Type {
}
