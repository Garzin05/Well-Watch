import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';
import 'api_service.dart';

class HealthService extends ChangeNotifier {
  // -----------------------
  // Chaves do SharedPreferences
  // -----------------------
  static const String _glucoseKey = 'glucose_records';
  static const String _weightKey = 'weight_records';
  static const String _bpKey = 'bp_records';

  // -----------------------
  // Mapas internos por usuário
  // -----------------------
  Map<int, List<GlucoseRecord>> _glucoseByUser = {};
  Map<int, List<WeightRecord>> _weightByUser = {};
  Map<int, List<BloodPressureRecord>> _bpByUser = {};

  // -----------------------
  // Id do usuário atual
  // -----------------------
  int? currentUserId;

  HealthService() {
    loadData();
  }

  // -----------------------
  // Carregar dados do SharedPreferences
  // -----------------------
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final glucoseJson = prefs.getString(_glucoseKey);
      final weightJson = prefs.getString(_weightKey);
      final bpJson = prefs.getString(_bpKey);

      if (glucoseJson != null) {
        final map = jsonDecode(glucoseJson) as Map<String, dynamic>;
        _glucoseByUser = map.map((k, v) => MapEntry(
            int.parse(k),
            (v as List).map((e) => GlucoseRecord.fromJson(e)).toList()));
      }

      if (weightJson != null) {
        final map = jsonDecode(weightJson) as Map<String, dynamic>;
        _weightByUser = map.map((k, v) => MapEntry(
            int.parse(k),
            (v as List).map((e) => WeightRecord.fromJson(e)).toList()));
      }

      if (bpJson != null) {
        final map = jsonDecode(bpJson) as Map<String, dynamic>;
        _bpByUser = map.map((k, v) => MapEntry(
            int.parse(k),
            (v as List).map((e) => BloodPressureRecord.fromJson(e)).toList()));
      }

      notifyListeners();
    } catch (e) {
      _glucoseByUser = {};
      _weightByUser = {};
      _bpByUser = {};
      notifyListeners();
    }
  }

  // -----------------------
  // Salvar dados no SharedPreferences
  // -----------------------
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _glucoseKey,
      jsonEncode(_glucoseByUser.map((k, v) =>
          MapEntry(k.toString(), v.map((e) => e.toJson()).toList()))),
    );

    await prefs.setString(
      _weightKey,
      jsonEncode(_weightByUser.map((k, v) =>
          MapEntry(k.toString(), v.map((e) => e.toJson()).toList()))),
    );

    await prefs.setString(
      _bpKey,
      jsonEncode(_bpByUser.map((k, v) =>
          MapEntry(k.toString(), v.map((e) => e.toJson()).toList()))),
    );
  }

  // -----------------------
  // Getters públicos
  // -----------------------
  List<GlucoseRecord> get glucoseRecords =>
      currentUserId == null ? [] : _glucoseByUser[currentUserId!] ?? [];

  List<WeightRecord> get weightRecords =>
      currentUserId == null ? [] : _weightByUser[currentUserId!] ?? [];

  List<BloodPressureRecord> get bpRecords =>
      currentUserId == null ? [] : _bpByUser[currentUserId!] ?? [];

  // -----------------------
  // Métodos por data
  // -----------------------
  List<GlucoseRecord> getGlucoseForDate(int userId, DateTime date) =>
      (_glucoseByUser[userId] ?? []).where((r) => isSameDay(r.date, date)).toList();

  List<WeightRecord> getWeightForDate(int userId, DateTime date) =>
      (_weightByUser[userId] ?? []).where((r) => isSameDay(r.date, date)).toList();

  List<BloodPressureRecord> getBPForDate(int userId, DateTime date) =>
      (_bpByUser[userId] ?? []).where((r) => isSameDay(r.date, date)).toList();

  // -----------------------
  // Adicionar registros
  // -----------------------
  Future<void> addGlucoseRecord(int userId, GlucoseRecord record) async {
    final list = _glucoseByUser[userId] ?? [];
    list.add(record);
    list.sort(_compareRecords);
    _glucoseByUser[userId] = list;
    notifyListeners();
    await saveData();

    // Salvar no banco via API
    await ApiService.insertMeasurement(patientId: userId, glucose: record);
  }

  Future<void> addWeightRecord(int userId, WeightRecord record) async {
    final list = _weightByUser[userId] ?? [];
    list.add(record);
    list.sort(_compareRecords);
    _weightByUser[userId] = list;
    notifyListeners();
    await saveData();

    await ApiService.insertMeasurement(patientId: userId, weight: record);
  }

  Future<void> addBloodPressureRecord(int userId, BloodPressureRecord record) async {
    final list = _bpByUser[userId] ?? [];
    list.add(record);
    list.sort(_compareRecords);
    _bpByUser[userId] = list;
    notifyListeners();
    await saveData();

    await ApiService.insertMeasurement(patientId: userId, bp: record);
  }

  // -----------------------
  // Remover registros
  // -----------------------
  Future<void> removeGlucoseRecord(int userId, GlucoseRecord record) async {
    final list = _glucoseByUser[userId] ?? [];
    list.removeWhere((r) => r.date == record.date && r.time == record.time && r.glucoseLevel == record.glucoseLevel);
    _glucoseByUser[userId] = list;
    notifyListeners();
    await saveData();
  }

  Future<void> removeWeightRecord(int userId, WeightRecord record) async {
    final list = _weightByUser[userId] ?? [];
    list.removeWhere((r) => r.date == record.date && r.time == record.time && r.weight == record.weight);
    _weightByUser[userId] = list;
    notifyListeners();
    await saveData();
  }

  Future<void> removeBloodPressureRecord(int userId, BloodPressureRecord record) async {
    final list = _bpByUser[userId] ?? [];
    list.removeWhere((r) =>
        r.date == record.date &&
        r.time == record.time &&
        r.systolic == record.systolic &&
        r.diastolic == record.diastolic);
    _bpByUser[userId] = list;
    notifyListeners();
    await saveData();
  }

  // -----------------------
  // Sincronizar do servidor
  // -----------------------
  Future<void> fetchFromServer(int userId) async {
    final res = await ApiService.getMeasurements(userId);
    if (res['status'] == true) {
      List data = res['data'] ?? [];

      _glucoseByUser[userId] = data
          .where((m) => m['type_code'] == 'glucose')
          .map((e) => GlucoseRecord.fromJson(e))
          .toList();

      _weightByUser[userId] = data
          .where((m) => m['type_code'] == 'weight')
          .map((e) => WeightRecord.fromJson(e))
          .toList();

      _bpByUser[userId] = data
          .where((m) => m['type_code'] == 'pressure')
          .map((e) => BloodPressureRecord.fromJson(e))
          .toList();

      notifyListeners();
      await saveData();
    }
  }

  // -----------------------
  // Utilitários
  // -----------------------
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _compareRecords(dynamic a, dynamic b) {
    final cmp = b.date.compareTo(a.date);
    if (cmp != 0) return cmp;
    return b.time.compareTo(a.time);
  }
}
