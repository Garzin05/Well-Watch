import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medico_paciente.dart';
import '../models/patient_model.dart';
import '../models/doctor_model.dart';
import 'storage_service.dart';

class AssociationService {
  static const String _kAssociationsKey = 'associations_medico_paciente';

  Future<List<MedicoPaciente>> _readAssociations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAssociationsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MedicoPaciente.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAssociations(List<MedicoPaciente> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kAssociationsKey, encoded);
  }

  // Doctor-side: add patient to doctor's list
  Future<bool> addPatientToDoctor({
    required String doctorId,
    required String patientId,
  }) async {
    final storage = StorageService();
    final doctor = await storage.getDoctorById(doctorId);
    final patient = await storage.getPatientById(patientId);
    if (doctor == null || patient == null) return false;

    final associations = await _readAssociations();

    // prevent duplicate
    final exists = associations
        .any((a) => a.doctorId == doctorId && a.patientId == patientId);
    if (exists) return true;

    // Enforce single-doctor-per-patient: remove any existing association for this patient
    associations.removeWhere((a) => a.patientId == patientId);

    associations.add(MedicoPaciente(
      doctorId: doctorId,
      patientId: patientId,
      createdAt: DateTime.now().toIso8601String(),
    ));

    await _writeAssociations(associations);
    return true;
  }

  Future<bool> removePatientFromDoctor({
    required String doctorId,
    required String patientId,
  }) async {
    final associations = await _readAssociations();
    final before = associations.length;
    associations
        .removeWhere((a) => a.doctorId == doctorId && a.patientId == patientId);
    if (associations.length == before) return false;
    await _writeAssociations(associations);
    return true;
  }

  Future<List<String>> listPatientIdsForDoctor(String doctorId) async {
    final associations = await _readAssociations();
    return associations
        .where((a) => a.doctorId == doctorId)
        .map((a) => a.patientId)
        .toList();
  }

  Future<List<Patient>> listPatientsForDoctor(String doctorId) async {
    final storage = StorageService();
    final ids = await listPatientIdsForDoctor(doctorId);
    final out = <Patient>[];
    for (final id in ids) {
      final p = await storage.getPatientById(id);
      if (p != null) out.add(p);
    }
    return out;
  }

  // Patient-side: register (assign) a doctor to this patient. This enforces single doctor.
  Future<bool> registerDoctorForPatient({
    required String patientId,
    required String doctorId,
  }) async {
    // reuse addPatientToDoctor behavior which enforces single-doctor
    return addPatientToDoctor(doctorId: doctorId, patientId: patientId);
  }

  Future<bool> removeDoctorForPatient({
    required String patientId,
  }) async {
    final associations = await _readAssociations();
    final before = associations.length;
    associations.removeWhere((a) => a.patientId == patientId);
    if (associations.length == before) return false;
    await _writeAssociations(associations);
    return true;
  }

  // Return the single doctor assigned to the patient (or null)
  Future<Doctor?> getDoctorForPatient(String patientId) async {
    final associations = await _readAssociations();
    MedicoPaciente? assoc;
    for (final a in associations) {
      if (a.patientId == patientId) {
        assoc = a;
        break;
      }
    }
    if (assoc == null) return null;
    final storage = StorageService();
    return storage.getDoctorById(assoc.doctorId);
  }
}
