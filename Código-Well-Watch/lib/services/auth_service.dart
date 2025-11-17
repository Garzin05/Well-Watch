import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projetowell/services/api_service.dart';

class AuthService extends ChangeNotifier {
  // Campos comuns
  String? username;
  String? email;
  String? userId; // sempre string, usada como int.parse() nas telas
  String? role; // doctor ou patient

  // Campos extras de médico
  String? crm;
  String? phone;
  String? specialty;
  String? hospital;

  // Campos extras de paciente (opcional)
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

  // =========================================
  // Carrega dados do SharedPreferences
  // =========================================
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    username = prefs.getString("username");
    email = prefs.getString("email");
    userId = prefs.getString("userId");
    role = prefs.getString("role");

    // campos médicos
    crm = prefs.getString("crm");
    phone = prefs.getString("phone");
    specialty = prefs.getString("specialty");
    hospital = prefs.getString("hospital");

    // campos pacientes
    age = prefs.getInt("age");
    gender = prefs.getString("gender");
    address = prefs.getString("address");
    bloodType = prefs.getString("bloodType");
    allergies = prefs.getString("allergies");
    medications = prefs.getString("medications");
    height = prefs.getDouble("height");
    weight = prefs.getDouble("weight");

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

    // médicos
    if (crm != null) prefs.setString("crm", crm!);
    if (phone != null) prefs.setString("phone", phone!);
    if (specialty != null) prefs.setString("specialty", specialty!);
    if (hospital != null) prefs.setString("hospital", hospital!);

    // pacientes
    if (age != null) prefs.setInt("age", age!);
    if (gender != null) prefs.setString("gender", gender!);
    if (address != null) prefs.setString("address", address!);
    if (bloodType != null) prefs.setString("bloodType", bloodType!);
    if (allergies != null) prefs.setString("allergies", allergies!);
    if (medications != null) prefs.setString("medications", medications!);
    if (height != null) prefs.setDouble("height", height!);
    if (weight != null) prefs.setDouble("weight", weight!);
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
        userId = user["id"].toString();
        this.role = user["role"];

        if (role == 'doctor') {
          crm = user["crm"];
          phone = user["phone"];
          specialty = user["specialty"];
          hospital = user["hospital_afiliado"];
        }

        if (role == 'patient') {
          phone = user["phone"];
          age = user["age"];
          gender = user["gender"];
          address = user["address"];
          bloodType = user["blood_type"];
          allergies = user["allergies"];
          medications = user["medications"];
          height = user["height"]?.toDouble();
          weight = user["weight"]?.toDouble();
        }

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

  // =========================================
  // GETTERS
  // =========================================
  bool get isDoctor => role == "doctor";
  bool get isPatient => role == "patient";
  bool get isAuthenticated =>
      username != null && email != null && userId != null;
}
