import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlueBackground = Color(0xFF0D1B2A);
  // Slightly more generic dark background used across screens
  static const Color darkBackground = Color(0xFF0D1B2A);
  static const Color darkGrayText = Color(0xFF4A4A4A);
  static const Color lightBlueAccent = Color(0xFF1E88E5);
  // Secondary text used on light surfaces
  static const Color lightText = Color(0xFF6B7280);
  // Card / surface background
  static const Color cardBackground = Color(0xFFF5F7FA);
  // Health area specific colors
  static const Color glucoseLow = Color(0xFFD32F2F); // red
  static const Color glucoseHigh = Color(0xFFF57C00); // orange
  static const Color glucoseNormal = Color(0xFF2E7D32); // green

  static const Color bpHigh = Color(0xFFD32F2F); // red
  static const Color bpPre = Color(0xFFF57C00); // orange
  static const Color bpNormal = Color(0xFF2E7D32); // green

  static const Color diabetes = Color(0xFFEF6C00); // deep orange
  static const Color agenda = Color(0xFF3F51B5); // indigo
  static const Color weightColor = Color.fromARGB(255, 110, 142, 177);
  static const Color reports = Color(0xFF00897B); // teal
  static const Color others = Color(0xFF9E9E9E); // grey
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightBlueAccent,
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
      backgroundColor: AppColors.lightBlueAccent,
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
      backgroundColor: AppColors.lightBlueAccent,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(primary: const Color(0xFF39D2C0), secondary: Colors.white),
);
