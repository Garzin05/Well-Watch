import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projetowell/services/api_service.dart';

class AuthService extends ChangeNotifier {
  String? username;
  String? email;
  String? userId;
  String? role; // doctor ou patient

  AuthService() {
    _loadFromPrefs();
  }

  // =========================================
  // Carrega dados salvos localmente
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
  // Salvar dados no SharedPreferences
  // =========================================
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if (username != null) prefs.setString("username", username!);
    if (email != null) prefs.setString("email", email!);
    if (userId != null) prefs.setString("userId", userId!);
    if (role != null) prefs.setString("role", role!);
  }

  // =========================================
  // MÉTODO PÚBLICO PARA SALVAR LOCALMENTE
  // (Usado no ProfilePage)
  // =========================================
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

        username = user["name"];
        this.email = user["email"];
        userId = user["id"].toString();
        this.role = user["role"]; // doctor ou patient

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
  bool get isAuthenticated => username != null && email != null;
}
