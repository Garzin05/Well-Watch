import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlueBackground = Color(0xFF0D1B2A);
  static const Color darkGrayText = Color(0xFF4A4A4A);
  static const Color lightBlueAccent = Color(0xFF1E88E5);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF39D2C0),
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
      backgroundColor: Colors.black,
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
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(primary: const Color(0xFF39D2C0), secondary: Colors.white),
);
