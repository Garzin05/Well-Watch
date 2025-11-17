import 'dart:convert';
import 'package:flutter/material.dart';

class VitalRecord {
  final DateTime date;
  final double? glucoseMgDl;
  final int? systolic;
  final int? diastolic;
  final double? weightKg;

  const VitalRecord({
    required this.date,
    this.glucoseMgDl,
    this.systolic,
    this.diastolic,
    this.weightKg,
  });

  factory VitalRecord.fromJson(Map<String, dynamic> j) {
    return VitalRecord(
      date: DateTime.parse(j['date']),
      glucoseMgDl: j['glucoseMgDl'] != null ? (j['glucoseMgDl'] as num).toDouble() : null,
      systolic: j['systolic'] as int?,
      diastolic: j['diastolic'] as int?,
      weightKg: j['weightKg'] != null ? (j['weightKg'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'glucoseMgDl': glucoseMgDl,
        'systolic': systolic,
        'diastolic': diastolic,
        'weightKg': weightKg,
      };
}

class Patient {
  final String id;
  final String name;
  final List<VitalRecord> records;
  late final String initials;

  Patient({
    required this.id,
    required this.name,
    required this.records,
  }) {
    initials = name.isNotEmpty
        ? name.trim().split(RegExp(r"\s+")).map((e) => e[0]).take(2).join()
        : '?';
  }

  factory Patient.fromJson(Map<String, dynamic> j) {
    final recs = <VitalRecord>[];
    if (j['records'] is List) {
      for (final r in j['records']) {
        if (r is Map<String, dynamic>) recs.add(VitalRecord.fromJson(r));
      }
    }
    return Patient(
      id: j['id'].toString(),
      name: j['name'] ?? '',
      records: recs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'records': records.map((r) => r.toJson()).toList(),
      };

  VitalRecord? latestRecord() {
    if (records.isEmpty) return null;
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }
}

class Appointment {
  final DateTime dateTime;
  final String patientId;
  final String note;

  Appointment({required this.dateTime, required this.patientId, required this.note});

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        dateTime: DateTime.parse(j['dateTime']),
        patientId: j['patientId'].toString(),
        note: j['note'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime.toIso8601String(),
        'patientId': patientId,
        'note': note,
      };
}

class NotificationItem {
  final String title;
  final String subtitle;
  final String icon; // string identifier — evita dependência direta
  final int colorValue;

  NotificationItem(this.title, this.subtitle, this.icon, this.colorValue);

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'icon': icon,
        'colorValue': colorValue,
      };
}

class AppData extends ChangeNotifier {
  final List<Patient> patients = [];
  final List<Appointment> appointments = [];
  final List<NotificationItem> notifications = [];

  Patient? selectedPatient;

  // NÃO chama _seed() no construtor — dados serão populados pela API
  AppData();

  // ---------- helpers públicos ----------
  void clearAll() {
    patients.clear();
    appointments.clear();
    notifications.clear();
    selectedPatient = null;
    notifyListeners();
  }

  /// Substitui a lista de pacientes por dados vindos da API (jsonList = List<Map>)
  void setPatientsFromJson(List<dynamic> jsonList) {
    patients.clear();
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        patients.add(Patient.fromJson(item));
      } else if (item is Map) {
        patients.add(Patient.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    if (patients.isNotEmpty && selectedPatient == null) selectedPatient = patients.first;
    notifyListeners();
  }

  void setAppointmentsFromJson(List<dynamic> jsonList) {
    appointments.clear();
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        appointments.add(Appointment.fromJson(item));
      } else if (item is Map) {
        appointments.add(Appointment.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    notifyListeners();
  }

  // Método auxiliar para adicionar um único patient vindo do backend
  void addOrUpdatePatientFromJson(Map<String, dynamic> j) {
    final id = j['id'].toString();
    final idx = patients.indexWhere((p) => p.id == id);
    final p = Patient.fromJson(j);
    if (idx >= 0) {
      patients[idx] = p;
    } else {
      patients.add(p);
    }
    notifyListeners();
  }

  void addAppointment({required DateTime dateTime, required String patientId, required String note}) {
    appointments.add(Appointment(dateTime: dateTime, patientId: patientId, note: note));
    notifyListeners();
  }

  void addVital({
    required String patientId,
    required DateTime date,
    double? glucoseMgDl,
    int? systolic,
    int? diastolic,
    double? weightKg,
  }) {
    final idx = patients.indexWhere((e) => e.id == patientId);
    if (idx == -1) return;
    final p = patients[idx];
    final newList = [...p.records, VitalRecord(date: date, glucoseMgDl: glucoseMgDl, systolic: systolic, diastolic: diastolic, weightKg: weightKg)];
    patients[idx] = Patient(id: p.id, name: p.name, records: newList);
    notifyListeners();
  }

  // Pequenos contadores (opcionais)
  int get alertsCount {
    int count = 0;
    for (final n in notifications) {
      if (n.icon == 'warning' || n.icon == 'heart') count++;
    }
    return count;
  }

  int get todayAppointmentsCount {
    final now = DateTime.now();
    return appointments.where((a) => a.dateTime.year == now.year && a.dateTime.month == now.month && a.dateTime.day == now.day).length;
  }
}

final appData = AppData();
