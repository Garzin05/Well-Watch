import 'package:flutter/material.dart';

class DoctorTheme {
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color lightBlue = Color(0xFF4D94FF);
  static const Color darkBlue = Color(0xFF004C99);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;

  static BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryBlue,
        primaryBlue.withOpacity(0.8),
      ],
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.white.withOpacity(0.9),
  );

  static TextStyle cardTitleStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle cardSubtitleStyle = const TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static InputDecoration searchDecoration = InputDecoration(
    hintText: 'Buscar pacientes...',
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: BorderSide.none,
    ),
    prefixIcon: const Icon(Icons.search, color: Colors.grey),
  );
}
