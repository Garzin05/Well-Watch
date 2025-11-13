import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
  if (kIsWeb) {
    return "http://localhost/WellWatchAPI"; 
  } else {
    return "http://10.0.2.2/WellWatchAPI"; 
  }
}

  // ==========================================================
  // LOGIN (paciente ou médico)
  // ==========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = "patient",
  }) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        body: {
          "email": email.trim(),
          "password": password.trim(),
          "role": role,
        },
      );

      // ✅ Verifica se a resposta realmente é JSON antes de decodificar
      if (response.headers['content-type']?.contains('application/json') ?? false) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": false,
          "message": "Resposta inesperada do servidor: ${response.body}",
        };
      }
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
      final response = await http.post(url, body: data);
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
      final response = await http.post(url, body: data);
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
