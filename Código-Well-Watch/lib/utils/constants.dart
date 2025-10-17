// TODO Implement this library.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
/// String constants used throughout the app
class AppStrings {
  // Login Screen
  static const welcomeTitle = 'Bem-Vindo!';
  static const loginSubtitle = 'Faça o Login para continuar';
  static const nameLabel = 'NOME';
  static const passwordLabel = 'SENHA';
  static const loginButton = 'Entrar';
  static const orDivider = 'OU';
  static const newUserQuestion = 'É novo(a) a serviço?';
  static const registerLink = 'Cadastre-se';
  static const forgotPasswordText = 'Esqueceu a senha?';
  static const appName = 'Well Watch';
}

/// Color constants (in addition to theme.dart colors)
class AppColors {
  static const darkBackground = Color(0xFF12171F);
  static const lightText = Color(0xFF8B8B8B);
  static const textFieldBg = Color(0xFFEDEDED);
  static const facebookBlue = Color(0xFF1877F2);
  static const instagramPink = Color(0xFFE4405F);
  static const googleRed = Color(0xFFDB4437);
  static const microsoftBlue = Color(0xFF0078D4);
}