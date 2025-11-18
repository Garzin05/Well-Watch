import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projetowell/services/api_service.dart';

class AuthService extends ChangeNotifier {
  // ===========================
  // DADOS COMUNS
  // ===========================
  String? username;
  String? email;
  String? userId; // string para evitar crash ao parse
  String? role; // "doctor" ou "patient"

  // ===========================
  // DADOS DO MÉDICO
  // ===========================
  String? crm;
  String? phone;
  String? specialty;
  String? hospital;

  // ===========================
  // DADOS DO PACIENTE
  // ===========================
  int? age;
  String? gender;
  String? address;
  String? bloodType;
  String? allergies;
  String? medications;
  double? height;
  double? weight;

  AuthService() {
    _loadFromPrefs();
  }

  // ===========================
  // CARREGAR DADOS LOCAIS
  // ===========================
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      username = prefs.getString("username");
      email = prefs.getString("email");
      userId = prefs.getString("userId");
      role = prefs.getString("role");

      // Médico
      crm = prefs.getString("crm");
      phone = prefs.getString("phone");
      specialty = prefs.getString("specialty");
      hospital = prefs.getString("hospital");

      // Paciente
      age = prefs.getInt("age");
      gender = prefs.getString("gender");
      address = prefs.getString("address");
      bloodType = prefs.getString("bloodType");
      allergies = prefs.getString("allergies");
      medications = prefs.getString("medications");
      height = prefs.getDouble("height");
      weight = prefs.getDouble("weight");

      notifyListeners();
    } catch (e) {
      debugPrint("⚠ Erro ao carregar SharedPreferences: $e");
    }
  }

  // ===========================
  // SALVAR DADOS LOCAIS
  // ===========================
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // comuns
    await prefs.setString("username", username ?? '');
    await prefs.setString("email", email ?? '');
    await prefs.setString("userId", userId ?? '');
    await prefs.setString("role", role ?? '');

    // Médico
    await prefs.setString("crm", crm ?? '');
    await prefs.setString("phone", phone ?? '');
    await prefs.setString("specialty", specialty ?? '');
    await prefs.setString("hospital", hospital ?? '');

    // Paciente
    if (age != null) prefs.setInt("age", age!);
    await prefs.setString("gender", gender ?? '');
    await prefs.setString("address", address ?? '');
    await prefs.setString("bloodType", bloodType ?? '');
    await prefs.setString("allergies", allergies ?? '');
    await prefs.setString("medications", medications ?? '');
    if (height != null) prefs.setDouble("height", height!);
    if (weight != null) prefs.setDouble("weight", weight!);
  }

  Future<void> saveLocal() async {
    await _saveToPrefs();
    notifyListeners();
  }

  // ===========================
  // LOGIN
  // ===========================
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

      if (result["status"] != true) return false;

      final user = result["user"];

      // --- CAMPOS COMUNS ---
      username = user["name"] ?? user["nome"] ?? "Usuário";
      this.email = user["email"] ?? '';
      userId = user["id"]?.toString() ?? '';
      this.role = user["role"] ?? role; // fallback caso API não envie

      // --- CAMPOS DO MÉDICO ---
      if (this.role == "doctor") {
        crm = user["crm"]?.toString() ?? '';
        phone = user["telefone"]?.toString() ?? '';
        specialty = user["especialidade"] ?? '';
        hospital = user["hospital_afiliado"] ?? '';
      }

      // --- CAMPOS DO PACIENTE ---
      if (this.role == "patient") {
        phone = user["telefone"]?.toString() ?? '';
        age = user["age"];
        gender = user["gender"] ?? '';
        address = user["address"] ?? '';
        bloodType = user["blood_type"] ?? '';
        allergies = user["allergies"] ?? '';
        medications = user["medications"] ?? '';
        height =
            user["height"] != null ? double.tryParse(user["height"].toString()) : null;
        weight =
            user["weight"] != null ? double.tryParse(user["weight"].toString()) : null;
      }

      await _saveToPrefs();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("❌ Erro no login: $e");
      return false;
    }
  }

  // ===========================
  // LOGOUT
  // ===========================
  Future<void> signOut() async {
    username = null;
    email = null;
    userId = null;
    role = null;

    crm = null;
    phone = null;
    specialty = null;
    hospital = null;

    age = null;
    gender = null;
    address = null;
    bloodType = null;
    allergies = null;
    medications = null;
    height = null;
    weight = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // ===========================
  // GETTERS
  // ===========================
  bool get isDoctor => role == "doctor";
  bool get isPatient => role == "patient";
  bool get isAuthenticated =>
      (username != null && username!.isNotEmpty) &&
      (email != null && email!.isNotEmpty) &&
      (userId != null && userId!.isNotEmpty);

  // Apenas para compatibilidade com códigos antigos
  void logout() => signOut();
}
