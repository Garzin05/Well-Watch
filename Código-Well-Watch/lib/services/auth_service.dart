import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  String? username;
  String? userId;
  String role = 'patient'; // 'patient' ou 'doctor'

  static const _kUsernameKey = 'auth_username';
  static const _kUserIdKey = 'auth_user_id';
  static const _kRoleKey = 'auth_role';

  AuthService() {
    // Carrega preferências de forma assíncrona (não bloqueante)
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString(_kUsernameKey) ?? username;
      userId = prefs.getString(_kUserIdKey) ?? userId;
      role = prefs.getString(_kRoleKey) ?? role;
    } catch (_) {
      // ignore errors silently - não crítico
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (username != null) await prefs.setString(_kUsernameKey, username!);
      if (userId != null) await prefs.setString(_kUserIdKey, userId!);
      await prefs.setString(_kRoleKey, role);
    } catch (_) {
      // ignore
    }
  }

  void setRole(String newRole) {
    if (newRole != 'patient' && newRole != 'doctor') {
      throw ArgumentError('Role must be either "patient" or "doctor"');
    }
    role = newRole;
    _saveToPrefs();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    // TODO: Implementar autenticação real
    await Future.delayed(const Duration(seconds: 2));
    if (username == 'admin' && password == '123456') {
      this.username = username;
      userId = 'admin-id';
      role = 'doctor'; // Admin é sempre médico
      await _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> socialLogin(String provider) async {
    // Simula um login social com atraso
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
    return;
  }

  Future<bool> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String crm,
    required String specialty,
    required String phone,
  }) async {
    // TODO: Implementar registro real
    await Future.delayed(const Duration(seconds: 2));
    username = name;
    userId = 'doctor-${DateTime.now().millisecondsSinceEpoch}';
    role = 'doctor';
    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<bool> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // TODO: Implementar registro real
    await Future.delayed(const Duration(seconds: 2));
    username = name;
    userId = 'patient-${DateTime.now().millisecondsSinceEpoch}';
    role = 'patient';
    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    username = null;
    userId = null;
    role = 'patient';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kUsernameKey);
      await prefs.remove(_kUserIdKey);
      await prefs.remove(_kRoleKey);
    } catch (_) {
      // ignore errors silently
    }
    notifyListeners();
  }

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
  bool get isAuthenticated => username != null && userId != null;
}
