// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Serviço de comunicação entre o Flutter e a API PHP (no XAMPP)
class ApiService {
  /// Detecta automaticamente se está rodando no navegador (Chrome) ou no emulador Android
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/WellWatchAPI"; // Para rodar no Chrome
    } else {
      return "http://10.0.2.2/WellWatchAPI"; // Para rodar no emulador Android
    }
  }

  // ==========================================================
  // LOGIN (médico ou paciente)
  // ==========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = "patient", // <- papel padrão
  }) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "role": role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Erro de conexão com o servidor: $e",
      };
    }
  }

  // ==========================================================
  // CADASTRO DE PACIENTE
  // ==========================================================
  static Future<Map<String, dynamic>> registerPatient(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_patient.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Erro de conexão com o servidor: $e",
      };
    }
  }

  // ==========================================================
  // CADASTRO DE MÉDICO
  // ==========================================================
  static Future<Map<String, dynamic>> registerDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_doctor.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Erro de conexão com o servidor: $e",
      };
    }
  }

  // ==========================================================
  // BUSCAR MEDIÇÕES DE PACIENTE
  // ==========================================================
  static Future<Map<String, dynamic>> getMeasurements(int patientId) async {
    final url = Uri.parse("$baseUrl/get_measurements.php?patient_id=$patientId");

    try {
      final response = await http.get(url);
      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Erro de conexão com o servidor: $e",
      };
    }
  }
}
