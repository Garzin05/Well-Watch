import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/patient_model.dart';
import '../models/doctor_model.dart';

class StorageService {
  Future<void> savePatient(Patient patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_${patient.email}', jsonEncode(patient.toJson()));
  }

  Future<void> saveDoctor(Doctor doctor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_${doctor.email}', jsonEncode(doctor.toJson()));
  }

  Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final isPatient = prefs.containsKey('patient_$email');
    final isDoctor = prefs.containsKey('doctor_$email');
    return isPatient || isDoctor;
  }
}
