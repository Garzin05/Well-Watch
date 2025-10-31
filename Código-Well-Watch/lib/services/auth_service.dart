import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String? username;
  String role = 'patient'; // 'patient' ou 'doctor'

  static const _kUsernameKey = 'auth_username';
  static const _kRoleKey = 'auth_role';

  AuthService() {
    // Carrega preferências de forma assíncrona (não bloqueante)
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString(_kUsernameKey) ?? username;
      role = prefs.getString(_kRoleKey) ?? role;
    } catch (_) {
      // ignore errors silently - não crítico
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (username != null) await prefs.setString(_kUsernameKey, username!);
      await prefs.setString(_kRoleKey, role);
    } catch (_) {
      // ignore
    }
  }

  void setRole(String newRole) {
    role = newRole;
    _saveToPrefs();
  }

  Future<bool> login(String username, String password) async {
    // Simula um login: apenas se for admin/123456
    await Future.delayed(const Duration(seconds: 2));
    this.username = username;
    await _saveToPrefs();
    return username == 'admin' && password == '123456';
  }

  Future<void> socialLogin(String provider) async {
    // Simula um login social com atraso
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> signOut() async {
    username = null;
    role = 'patient';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kUsernameKey);
      await prefs.remove(_kRoleKey);
    } catch (_) {
      // ignore errors silently
    }
  }
}
