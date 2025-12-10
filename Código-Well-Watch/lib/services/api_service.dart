import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/health_data.dart';
import '../models/app_data.dart';

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
        return {
          "status": false,
          "message": "Acesso negado: papel de usuário incorreto"
        };
      }
      return data;
    } catch (e) {
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Cadastro
  // -----------------------
  static Future<Map<String, dynamic>> registerPatient(
      Map<String, dynamic> data) async {
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

  static Future<Map<String, dynamic>> registerDoctor(
      Map<String, dynamic> data) async {
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
  static Future<Map<String, dynamic>> getMeasurements(int patientId,
      {String? typeCode}) async {
    String query = "?patient_id=$patientId";
    if (typeCode != null) query += "&type_code=$typeCode";

    final url = Uri.parse("$baseUrl/get_measurements.php$query");
    debugPrint(
        '[API] getMeasurements(patientId=$patientId, typeCode=$typeCode) - URL: $url');
    try {
      final response =
          await http.get(url, headers: {"Accept": "application/json"});
      debugPrint('[API] Status Code: ${response.statusCode}');
      debugPrint('[API] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return {"status": false, "message": "Erro HTTP ${response.statusCode}"};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[API] getMeasurements Parsed: $data');
      return data;
    } catch (e) {
      debugPrint('[API] getMeasurements Error: $e');
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  /// Carrega apenas as medições de glicose de um paciente
  static Future<List<VitalRecord>> getGlucoseMeasurements(
      String patientId) async {
    try {
      debugPrint('[API-GLUCOSE] Iniciando busca para patientId=$patientId');
      final int patientIntId = int.parse(patientId);
      debugPrint('[API-GLUCOSE] patientId convertido para int: $patientIntId');

      final result = await getMeasurements(patientIntId, typeCode: 'glucose');

      debugPrint('[API-GLUCOSE] Resposta da API: $result');

      if (result['status'] != true) {
        debugPrint(
            '[API-GLUCOSE] Status falso ou nulo. Message: ${result['message']}');
        return [];
      }

      final measurements = result['measurements'] as List? ?? [];
      debugPrint(
          '[API-GLUCOSE] Total de medicoes brutas: ${measurements.length}');

      if (measurements.isEmpty) {
        debugPrint('[API-GLUCOSE] Lista de medicoes esta vazia!');
        return [];
      }

      debugPrint(
          '[API-GLUCOSE] Primeira medicao bruta: ${measurements.isNotEmpty ? measurements[0] : "VAZIA"}');

      final records = measurements
          .map((m) {
            try {
              debugPrint('[API-GLUCOSE] Parseando medicao: $m');
              final record = VitalRecord(
                date: DateTime.parse(m['recorded_at']),
                glucoseMgDl: (m['glucose_value'] as num?)?.toDouble(),
              );
              debugPrint(
                  '[API-GLUCOSE] Sucesso ao parsear: glucose=${record.glucoseMgDl}, date=${record.date}');
              return record;
            } catch (e) {
              debugPrint('[API-GLUCOSE] ERRO ao parsear medicao: $m, erro: $e');
              return null;
            }
          })
          .whereType<VitalRecord>()
          .toList();

      debugPrint('[API-GLUCOSE] Total de records parseados: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('[API] getGlucoseMeasurements Error: $e');
      return [];
    }
  }

  /// Carrega apenas as medições de peso de um paciente
  static Future<List<VitalRecord>> getWeightMeasurements(
      String patientId) async {
    try {
      debugPrint('[API-WEIGHT] Iniciando busca para patientId=$patientId');
      final int patientIntId = int.parse(patientId);
      final result = await getMeasurements(patientIntId, typeCode: 'weight');

      debugPrint('[API-WEIGHT] Resposta da API: $result');

      if (result['status'] != true) {
        debugPrint('[API-WEIGHT] Status falso ou nulo');
        return [];
      }

      final measurements = result['measurements'] as List? ?? [];
      debugPrint(
          '[API-WEIGHT] Total de medicoes brutas: ${measurements.length}');

      final records = measurements
          .map((m) {
            try {
              debugPrint('[API-WEIGHT] Parseando: $m');
              final record = VitalRecord(
                date: DateTime.parse(m['recorded_at']),
                weightKg: (m['weight_value'] as num?)?.toDouble(),
              );
              debugPrint('[API-WEIGHT] Sucesso: weight=${record.weightKg}');
              return record;
            } catch (e) {
              debugPrint('[API-WEIGHT] ERRO: $e');
              return null;
            }
          })
          .whereType<VitalRecord>()
          .toList();

      debugPrint('[API-WEIGHT] Total parseado: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('[API] getWeightMeasurements Error: $e');
      return [];
    }
  }

  /// Carrega apenas as medições de pressão arterial de um paciente
  static Future<List<VitalRecord>> getPressureMeasurements(
      String patientId) async {
    try {
      debugPrint('[API-PRESSURE] Iniciando busca para patientId=$patientId');
      final int patientIntId = int.parse(patientId);
      final result = await getMeasurements(patientIntId, typeCode: 'pressure');

      debugPrint('[API-PRESSURE] Resposta da API: $result');

      if (result['status'] != true) {
        debugPrint('[API-PRESSURE] Status falso ou nulo');
        return [];
      }

      final measurements = result['measurements'] as List? ?? [];
      debugPrint(
          '[API-PRESSURE] Total de medicoes brutas: ${measurements.length}');

      final records = measurements
          .map((m) {
            try {
              debugPrint('[API-PRESSURE] Parseando: $m');
              final record = VitalRecord(
                date: DateTime.parse(m['recorded_at']),
                systolic: m['systolic'] as int?,
                diastolic: m['diastolic'] as int?,
              );
              debugPrint(
                  '[API-PRESSURE] Sucesso: systolic=${record.systolic}, diastolic=${record.diastolic}');
              return record;
            } catch (e) {
              debugPrint('[API-PRESSURE] ERRO: $e');
              return null;
            }
          })
          .whereType<VitalRecord>()
          .toList();

      debugPrint('[API-PRESSURE] Total parseado: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('[API] getPressureMeasurements Error: $e');
      return [];
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
      debugPrint(
          '[API_SERVICE] 📊 Preparando inserção de glicose: patientId=$patientId, valor=${glucose.glucoseLevel}');
    } else if (weight != null) {
      data['type_code'] = 'weight';
      data['weight_value'] = weight.weight;
      data['recorded_at'] = weight.date.toIso8601String();
      debugPrint(
          '[API_SERVICE] ⚖️ Preparando inserção de peso: patientId=$patientId, valor=${weight.weight}');
    } else if (bp != null) {
      data['type_code'] = 'pressure';
      data['systolic'] = bp.systolic;
      data['diastolic'] = bp.diastolic;
      data['heart_rate'] = bp.heartRate;
      data['recorded_at'] = bp.date.toIso8601String();
      debugPrint(
          '[API_SERVICE] 💓 Preparando inserção de pressão: patientId=$patientId, ${bp.systolic}/${bp.diastolic}');
    }

    debugPrint('[API_SERVICE] 📤 POST para: $url');
    debugPrint('[API_SERVICE] 📋 Body: ${jsonEncode(data)}');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(data),
      );
      final result = jsonDecode(response.body);
      debugPrint('[API_SERVICE] 📥 Response (${response.statusCode}): $result');
      return result;
    } catch (e) {
      debugPrint('[API_SERVICE] ❌ Erro de conexão: $e');
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Buscar paciente por email
  // -----------------------
  static Future<Map<String, dynamic>> getPatientByEmail(String email) async {
    final url = Uri.parse(
        "$baseUrl/get_patient_by_email.php?email=${Uri.encodeComponent(email.toLowerCase())}");
    debugPrint('[API] getPatientByEmail($email) - URL: $url');
    try {
      final response =
          await http.get(url, headers: {"Accept": "application/json"});
      debugPrint('[API] Status Code: ${response.statusCode}');
      debugPrint('[API] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return {"status": false, "message": "Erro HTTP ${response.statusCode}"};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[API] getPatientByEmail Parsed: $data');
      return data;
    } catch (e) {
      debugPrint('[API] getPatientByEmail Error: $e');
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Listar todos os emails de pacientes (DEBUG)
  // -----------------------
  static Future<Map<String, dynamic>> getAllPatientEmails() async {
    final url = Uri.parse("$baseUrl/get_all_patient_emails.php");
    debugPrint('[API] getAllPatientEmails - URL: $url');
    try {
      final response =
          await http.get(url, headers: {"Accept": "application/json"});
      debugPrint('[API] Status Code: ${response.statusCode}');
      debugPrint('[API] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return {"status": false, "message": "Erro HTTP ${response.statusCode}"};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[API] getAllPatientEmails Parsed: $data');
      return data;
    } catch (e) {
      debugPrint('[API] getAllPatientEmails Error: $e');
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }

  // -----------------------
  // Buscar medições de um paciente
  // -----------------------
  static Future<Map<String, dynamic>> getPatientMeasurements(
      int patientId) async {
    final url = Uri.parse(
        "$baseUrl/get_patient_measurements.php?patient_id=$patientId");
    debugPrint('[API] getPatientMeasurements($patientId) - URL: $url');
    try {
      final response =
          await http.get(url, headers: {"Accept": "application/json"});
      debugPrint('[API] Status Code: ${response.statusCode}');
      debugPrint('[API] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return {"status": false, "message": "Erro HTTP ${response.statusCode}"};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[API] getPatientMeasurements Parsed: $data');
      return data;
    } catch (e) {
      debugPrint('[API] getPatientMeasurements Error: $e');
      return {"status": false, "message": "Erro de conexão: $e"};
    }
  }
}
