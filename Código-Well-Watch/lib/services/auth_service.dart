import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projetowell/services/api_service.dart';

class AuthService extends ChangeNotifier {
  String? username;
  String? email;
  String? userId; // sempre string, usada como int.parse() nas telas
  String? role; // doctor ou patient

  AuthService() {
    _loadFromPrefs();
  }

  // =========================================
  // Carrega dados do SharedPreferences
  // =========================================
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    username = prefs.getString("username");
    email = prefs.getString("email");
    userId = prefs.getString("userId");
    role = prefs.getString("role");

    notifyListeners();
  }

  // =========================================
  // Salva dados localmente
  // =========================================
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if (username != null) prefs.setString("username", username!);
    if (email != null) prefs.setString("email", email!);
    if (userId != null) prefs.setString("userId", userId!);
    if (role != null) prefs.setString("role", role!);
  }

  Future<void> saveLocal() async {
    await _saveToPrefs();
    notifyListeners();
  }

  // =========================================
  // LOGIN REAL USANDO API
  // =========================================
  Future<bool> login(
    String email,
    String password, {
    required String role,
  }) async {
    try {
      final result = await ApiService.login(
        email: email,
        password: password,
        role: role,
      );

      if (result["status"] == true) {
        final user = result["user"];

        username = user["name"] ?? user["nome"] ?? 'Usuário';
        this.email = user["email"];

        // garante que seja string numérica
        userId = user["id"].toString();

        this.role = user["role"];

        await _saveToPrefs();
        notifyListeners();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("❌ Erro no login: $e");
      return false;
    }
  }

  // =========================================
  // LOGOUT
  // =========================================
  Future<void> signOut() async {
    username = null;
    email = null;
    userId = null;
    role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("username");
    await prefs.remove("email");
    await prefs.remove("userId");
    await prefs.remove("role");

    notifyListeners();
  }

  // =========================================
  // GETTERS
  // =========================================
  bool get isDoctor => role == "doctor";
  bool get isPatient => role == "patient";

  // agora verifica userId também
  bool get isAuthenticated =>
      username != null && email != null && userId != null;
}
