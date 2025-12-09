import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/patient_model.dart';
import '../models/doctor_model.dart';

class StorageService {
  Future<void> savePatient(Patient patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'patient_${patient.email}', jsonEncode(patient.toJson()));
  }

  Future<void> saveDoctor(Doctor doctor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'doctor_${doctor.email}', jsonEncode(doctor.toJson()));
  }

  Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final isPatient = prefs.containsKey('patient_$email');
    final isDoctor = prefs.containsKey('doctor_$email');
    return isPatient || isDoctor;
  }

  // =====================
  // READ / LIST HELPERS
  // =====================
  Future<Patient?> getPatientById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('patient_')) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          if ((map['id'] as String) == id) {
            return Patient.fromJson(map);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Future<Doctor?> getDoctorById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('doctor_')) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          if ((map['id'] as String) == id) {
            return Doctor.fromJson(map);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Future<Patient?> getPatientByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'patient_$email';
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Patient.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<Doctor?> getDoctorByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'doctor_$email';
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Doctor.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Debug: list all patient keys stored in SharedPreferences
  Future<List<String>> getAllPatientEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = <String>[];
    for (final key in prefs.getKeys()) {
      if (key.startsWith('patient_')) {
        final email = key.replaceFirst('patient_', '');
        emails.add(email);
      }
    }
    return emails;
  }

  Future<List<Patient>> getAllPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <Patient>[];
    for (final key in prefs.getKeys()) {
      if (key.startsWith('patient_')) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          out.add(Patient.fromJson(map));
        } catch (_) {}
      }
    }
    return out;
  }

  Future<List<Doctor>> getAllDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <Doctor>[];
    for (final key in prefs.getKeys()) {
      if (key.startsWith('doctor_')) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          out.add(Doctor.fromJson(map));
        } catch (_) {}
      }
    }
    return out;
  }
}
