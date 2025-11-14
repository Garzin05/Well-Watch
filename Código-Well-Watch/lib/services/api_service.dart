import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  /// Base URL dependendo se está rodando no navegador ou emulador
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/WellWatchAPI"; 
    } else {
      return "http://10.0.2.2/WellWatchAPI"; 
    }
  }

  // ==========================================================
  // LOGIN (paciente ou médico) com validação de role
  // ==========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = "patient", // paciente por padrão
  }) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "role": role,
        }),
      );

      // Decodifica JSON com segurança
      try {
        final data = jsonDecode(response.body);

        // Verifica se o role retornado coincide
        if (data['status'] == true && data['user']['role'] != role) {
          return {
            "status": false,
            "message": "Acesso negado: papel de usuário incorreto",
          };
        }

        return data;
      } catch (_) {
        return {
          "status": false,
          "message": "Resposta inválida do servidor: ${response.body}",
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
  // CADASTRO DE PACIENTE (envio JSON)
  // ==========================================================
  static Future<Map<String, dynamic>> registerPatient(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_patient.php");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
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
  // CADASTRO DE MÉDICO (envio JSON)
  // ==========================================================
  static Future<Map<String, dynamic>> registerDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_doctor.php");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
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
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Erro de conexão com o servidor: $e",
      };
    }
  }
}
