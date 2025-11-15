import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/health_data.dart';

class ApiService {
  // -----------------------
  // URL base
  // -----------------------
  static String get baseUrl {
    if (kIsWeb) return "http://localhost/WellWatchAPI";
    return "http://10.0.2.2/WellWatchAPI";
  }

  // -----------------------
  // Login
  // -----------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = "patient",
  }) async {
    final url = Uri.parse("$baseUrl/login.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "role": role,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['user']['role'] != role) {
        return {"status": false, "message": "Acesso negado: papel de usuário incorreto"};
      }
      return data;
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Cadastro
  // -----------------------
  static Future<Map<String, dynamic>> registerPatient(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_patient.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  static Future<Map<String, dynamic>> registerDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register_doctor.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Buscar medições
  // -----------------------
  static Future<Map<String, dynamic>> getMeasurements(int patientId, {String? typeCode}) async {
    String query = "?patient_id=$patientId";
    if (typeCode != null) query += "&type_code=$typeCode";

    final url = Uri.parse("$baseUrl/get_measurements.php$query");
    try {
      final response = await http.get(url, headers: {"Accept": "application/json"});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Inserir medições no servidor
  // -----------------------
  static Future<Map<String, dynamic>> insertMeasurement({
    required int patientId,
    GlucoseRecord? glucose,
    WeightRecord? weight,
    BloodPressureRecord? bp,
  }) async {
    final url = Uri.parse("$baseUrl/insert_measurement.php");
    Map<String, dynamic> data = {"patient_id": patientId};

    if (glucose != null) {
      data['type_code'] = 'glucose';
      data['glucose_value'] = glucose.glucoseLevel;
      data['recorded_at'] = glucose.date.toIso8601String();
    } else if (weight != null) {
      data['type_code'] = 'weight';
      data['weight_value'] = weight.weight;
      data['recorded_at'] = weight.date.toIso8601String();
    } else if (bp != null) {
      data['type_code'] = 'pressure';
      data['systolic'] = bp.systolic;
      data['diastolic'] = bp.diastolic;
      data['heart_rate'] = bp.heartRate;
      data['recorded_at'] = bp.date.toIso8601String();
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }
}
