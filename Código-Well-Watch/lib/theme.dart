import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// --- CORES PRINCIPAIS ---
/// Paleta moderna, voltada à saúde e tecnologia (azul + teal)
class LightModeColors {
  static const lightPrimary = Color(0xFF0066CC);
  static const lightOnPrimary = Colors.white;
  static const lightSecondary = Color(0xFF00B8A9);
  static const lightTertiary = Color(0xFFE94E77);
  static const lightSurface = Color(0xFFF5F9FC);
  static const lightOnSurface = Color(0xFF0F1419);

  // Gradiente de bem-estar
  static const gradientStart = Color(0xFF0072CE);
  static const gradientEnd = Color(0xFF2DD6C1);

  static Color? get lightAppBarBackground => null;

  static Color? get lightPrimaryContainer => null;
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF66D6D2);
  static const darkOnPrimary = Color(0xFF0B1D2E);
  static const darkSurface = Color(0xFF0B1D2E);
  static const darkOnSurface = Color(0xFFE6EEF2);
  static const gradientStart = Color(0xFF0B1D2E);
  static const gradientEnd = Color(0xFF1697A8);

  static Color? get darkPrimaryContainer => null;

  static Color? get darkAppBarBackground => null;
}

/// --- TEMA CLARO ---
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    secondary: LightModeColors.lightSecondary,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
  scaffoldBackgroundColor: LightModeColors.lightSurface,

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: LightModeColors.gradientStart,
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor:
          WidgetStateProperty.all(LightModeColors.lightPrimary),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(
        LightModeColors.lightSecondary.withOpacity(0.2),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevation: WidgetStateProperty.all(4),
      animationDuration: const Duration(milliseconds: 200),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: LightModeColors.lightPrimary),
    ),
    hintStyle: GoogleFonts.inter(
      color: Colors.black54,
      fontSize: 14,
    ),
  ),
);

/// --- TEMA ESCURO ---
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
  ),
  scaffoldBackgroundColor: DarkModeColors.darkSurface,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: DarkModeColors.darkOnSurface,
    displayColor: DarkModeColors.darkOnSurface,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: DarkModeColors.gradientStart,
    foregroundColor: Colors.white,
  ),
);

/// --- LOGIN SCREEN (com animações e ícones vivos) ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LightModeColors.gradientStart,
              LightModeColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.health_and_safety,
                            color: colorScheme.primary, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          "Well Watch",
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: 1.0,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.login),
                            label: const Text("Entrar"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- APP PRINCIPAL ---
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    home: const LoginScreen(),
  ));
}
