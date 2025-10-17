// TODO Implement this library.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';

class HealthService extends ChangeNotifier {
  static const String _glucoseKey = 'glucose_records';
  static const String _weightKey = 'weight_records';
  static const String _bpKey = 'bp_records';
  static const String _medicationKey = 'medication_records';

  List<GlucoseRecord> _glucoseRecords = [];
  List<WeightRecord> _weightRecords = [];
  List<BloodPressureRecord> _bpRecords = [];
  List<MedicationRecord> _medicationRecords = [];

  List<GlucoseRecord> get glucoseRecords => _glucoseRecords;
  List<WeightRecord> get weightRecords => _weightRecords;
  List<BloodPressureRecord> get bpRecords => _bpRecords;
  List<MedicationRecord> get medicationRecords => _medicationRecords;

  HealthService() {
    loadData();
  }

  // Carrega dados do SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Tenta carregar dados salvos
      final glucoseJson = prefs.getStringList(_glucoseKey);
      final weightJson = prefs.getStringList(_weightKey);
      final bpJson = prefs.getStringList(_bpKey);
      final medicationJson = prefs.getStringList(_medicationKey);

      if (glucoseJson != null) {
        _glucoseRecords =
            glucoseJson
                .map((json) => GlucoseRecord.fromJson(jsonDecode(json)))
                .toList();
      }

      if (weightJson != null) {
        _weightRecords =
            weightJson
                .map((json) => WeightRecord.fromJson(jsonDecode(json)))
                .toList();
      }

      if (bpJson != null) {
        _bpRecords =
            bpJson
                .map((json) => BloodPressureRecord.fromJson(jsonDecode(json)))
                .toList();
      }

      if (medicationJson != null) {
        _medicationRecords =
            medicationJson
                .map((json) => MedicationRecord.fromJson(jsonDecode(json)))
                .toList();
      }

      // Se não houver dados salvos, cria dados de exemplo
      if (_glucoseRecords.isEmpty &&
          _weightRecords.isEmpty &&
          _bpRecords.isEmpty &&
          _medicationRecords.isEmpty) {
        createMockData();
        saveData(); // Salva os dados de exemplo
      }

      // Ordena os registros por data (mais recentes primeiro)
      _sortRecords();

      notifyListeners();
    } catch (e) {
      // Em caso de erro ao carregar dados, cria dados de exemplo
      createMockData();
      notifyListeners();
    }
  }

  // Cria dados de exemplo para demonstração
  void createMockData() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Registros de glicose
    _glucoseRecords = [
      GlucoseRecord(date: today, time: '07:30', glucoseLevel: 120),
      GlucoseRecord(date: today, time: '12:00', glucoseLevel: 145),
      GlucoseRecord(date: yesterday, time: '07:30', glucoseLevel: 118),
    ];

    // Registros de peso
    _weightRecords = [
      WeightRecord(date: today, time: '07:00', weight: 75.5),
      WeightRecord(date: yesterday, time: '07:00', weight: 76.0),
    ];

    // Registros de pressão arterial
    _bpRecords = [
      BloodPressureRecord(
        date: today,
        time: '08:00',
        systolic: 130,
        diastolic: 85,
        heartRate: 72,
      ),
      BloodPressureRecord(
        date: today,
        time: '20:00',
        systolic: 125,
        diastolic: 82,
        heartRate: 68,
      ),
      BloodPressureRecord(
        date: yesterday,
        time: '08:00',
        systolic: 135,
        diastolic: 88,
        heartRate: 75,
      ),
    ];

    // Registros de medicação
    _medicationRecords = [
      MedicationRecord(
        date: today,
        time: '08:00',
        medicationName: 'Metformina',
        dosage: '500mg',
        scheduledTimes: ['08:00', '20:00'],
        taken: true,
      ),
      MedicationRecord(
        date: today,
        time: '20:00',
        medicationName: 'Metformina',
        dosage: '500mg',
        scheduledTimes: ['08:00', '20:00'],
        taken: false,
      ),
    ];
  }

  // Salva todos os dados no SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Converte registros para JSON
    final glucoseJson =
        _glucoseRecords.map((record) => jsonEncode(record.toJson())).toList();

    final weightJson =
        _weightRecords.map((record) => jsonEncode(record.toJson())).toList();

    final bpJson =
        _bpRecords.map((record) => jsonEncode(record.toJson())).toList();

    final medicationJson =
        _medicationRecords
            .map((record) => jsonEncode(record.toJson()))
            .toList();

    // Salva no SharedPreferences
    await prefs.setStringList(_glucoseKey, glucoseJson);
    await prefs.setStringList(_weightKey, weightJson);
    await prefs.setStringList(_bpKey, bpJson);
    await prefs.setStringList(_medicationKey, medicationJson);
  }

  // Adiciona um novo registro de glicose
  Future<void> addGlucoseRecord(GlucoseRecord record) async {
    _glucoseRecords.add(record);
    _sortRecords();
    notifyListeners();
    await saveData();
  }

  // Adiciona um novo registro de peso
  Future<void> addWeightRecord(WeightRecord record) async {
    _weightRecords.add(record);
    _sortRecords();
    notifyListeners();
    await saveData();
  }

  // Adiciona um novo registro de pressão arterial
  Future<void> addBloodPressureRecord(BloodPressureRecord record) async {
    _bpRecords.add(record);
    _sortRecords();
    notifyListeners();
    await saveData();
  }

  // Adiciona um novo registro de medicação
  Future<void> addMedicationRecord(MedicationRecord record) async {
    _medicationRecords.add(record);
    _sortRecords();
    notifyListeners();
    await saveData();
  }

  // Atualiza o status de um medicamento (tomado ou não)
  Future<void> updateMedicationStatus(
    MedicationRecord record,
    bool taken,
  ) async {
    final index = _medicationRecords.indexWhere(
      (r) =>
          r.date == record.date &&
          r.time == record.time &&
          r.medicationName == record.medicationName,
    );

    if (index != -1) {
      // Substitui o registro existente com o status atualizado
      _medicationRecords[index] = MedicationRecord(
        date: record.date,
        time: record.time,
        medicationName: record.medicationName,
        dosage: record.dosage,
        scheduledTimes: record.scheduledTimes,
        taken: taken,
      );

      notifyListeners();
      await saveData();
    }
  }

  // Remove um registro de glicose
  Future<void> removeGlucoseRecord(GlucoseRecord record) async {
    _glucoseRecords.removeWhere(
      (r) =>
          r.date == record.date &&
          r.time == record.time &&
          r.glucoseLevel == record.glucoseLevel,
    );
    notifyListeners();
    await saveData();
  }

  // Remove um registro de peso
  Future<void> removeWeightRecord(WeightRecord record) async {
    _weightRecords.removeWhere(
      (r) =>
          r.date == record.date &&
          r.time == record.time &&
          r.weight == record.weight,
    );
    notifyListeners();
    await saveData();
  }

  // Remove um registro de pressão arterial
  Future<void> removeBloodPressureRecord(BloodPressureRecord record) async {
    _bpRecords.removeWhere(
      (r) =>
          r.date == record.date &&
          r.time == record.time &&
          r.systolic == record.systolic &&
          r.diastolic == record.diastolic,
    );
    notifyListeners();
    await saveData();
  }

  // Remove um registro de medicação
  Future<void> removeMedicationRecord(MedicationRecord record) async {
    _medicationRecords.removeWhere(
      (r) =>
          r.date == record.date &&
          r.time == record.time &&
          r.medicationName == record.medicationName,
    );
    notifyListeners();
    await saveData();
  }

  // Obtém registros de glicose para uma data específica
  List<GlucoseRecord> getGlucoseForDate(DateTime date) {
    return _glucoseRecords
        .where((record) => isSameDay(record.date, date))
        .toList();
  }

  // Obtém registros de peso para uma data específica
  List<WeightRecord> getWeightForDate(DateTime date) {
    return _weightRecords
        .where((record) => isSameDay(record.date, date))
        .toList();
  }

  // Obtém registros de pressão arterial para uma data específica
  List<BloodPressureRecord> getBPForDate(DateTime date) {
    return _bpRecords.where((record) => isSameDay(record.date, date)).toList();
  }

  // Obtém registros de medicação para uma data específica
  List<MedicationRecord> getMedicationForDate(DateTime date) {
    return _medicationRecords
        .where((record) => isSameDay(record.date, date))
        .toList();
  }

  // Verifica se duas datas são o mesmo dia
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Ordena todos os registros por data (mais recentes primeiro)
  void _sortRecords() {
    _glucoseRecords.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    _weightRecords.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    _bpRecords.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    _medicationRecords.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });
  }
}
