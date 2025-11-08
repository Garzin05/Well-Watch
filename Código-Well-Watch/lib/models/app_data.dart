import 'dart:math';
import 'package:flutter/material.dart';

// Definições de dados vitais do paciente
class VitalRecord {
  final DateTime date;
  final double? glucoseMgDl; // mg/dL
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
}

// Classe de paciente com os registros vitais
class Patient {
  final String id;
  final String name;
  final String initials;
  final List<VitalRecord> records;

  Patient({
    required this.id,
    required this.name,
    required this.records,
  }) : initials = name.isNotEmpty
            ? name.trim().split(RegExp(r"\s+")).map((e) => e[0]).take(2).join()
            : '?';

  bool get hasAlert {
    // Verifica se o paciente possui algum alerta baseado nos registros vitais
    for (final r in records) {
      if ((r.glucoseMgDl ?? 0) >= 180) return true;
      if ((r.systolic ?? 0) >= 140 || (r.diastolic ?? 0) >= 90) return true;
    }
    return false;
  }

  VitalRecord? latestRecord() {
    // Retorna o último registro vital
    if (records.isEmpty) return null;
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }
}

// Classe de agendamento de consultas
class Appointment {
  final DateTime dateTime;
  final String patientId;
  final String note;
  Appointment({required this.dateTime, required this.patientId, required this.note});
}

// Classe de Notificação (Alertas, lembretes, etc)
class NotificationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  NotificationItem(this.title, this.subtitle, this.icon, this.color);
}

// Classe AppData gerencia o estado de pacientes, consultas e notificações
class AppData extends ChangeNotifier {
  final List<Patient> patients = [];
  final List<Appointment> appointments = [];
  final List<NotificationItem> notifications = [];

  Patient? selectedPatient;

  AppData() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    
    // Função que gera séries de registros vitais de forma aleatória
    List<VitalRecord> genSeries({double gBase = 100, int sBase = 120, int dBase = 80, double wBase = 80}) {
      final rnd = Random(42);
      return List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        return VitalRecord(
          date: day,
          glucoseMgDl: (gBase + rnd.nextInt(40) - 20).toDouble(),
          systolic: sBase + rnd.nextInt(20) - 10,
          diastolic: dBase + rnd.nextInt(12) - 6,
          weightKg: double.parse((wBase - i * 0.2 + rnd.nextDouble() * 0.2).toStringAsFixed(1)),
        );
      });
    }

    // Inicializa os pacientes com dados gerados
    patients.addAll([
      Patient(id: 'p1', name: 'João Silva', records: genSeries(gBase: 110, sBase: 125, dBase: 82, wBase: 79.5)),
      Patient(id: 'p2', name: 'Maria Souza', records: genSeries(gBase: 95, sBase: 118, dBase: 76, wBase: 68.2)),
      Patient(id: 'p3', name: 'Carlos Almeida', records: genSeries(gBase: 130, sBase: 138, dBase: 88, wBase: 85.0)),
      Patient(id: 'p4', name: 'Ana Pereira', records: genSeries(gBase: 100, sBase: 120, dBase: 80, wBase: 61.0)),
    ]);
    selectedPatient = patients.first;

    // Inicializa os agendamentos de consultas
    appointments.addAll([
      Appointment(dateTime: now.add(const Duration(hours: 2)), patientId: 'p1', note: 'Retorno - revisão exames'),
      Appointment(dateTime: now.add(const Duration(days: 1, hours: 1)), patientId: 'p2', note: 'Avaliação pressão'),
    ]);

    _refreshAlertsFromVitals();
  }

  void _refreshAlertsFromVitals() {
    notifications.clear();
    
    // Gera notificações baseadas nos registros vitais dos pacientes
    for (final p in patients) {
      final last = p.latestRecord();
      if (last == null) continue;
      
      // Gera notificações de alerta para glicose alta
      if ((last.glucoseMgDl ?? 0) >= 180) {
        notifications.add(NotificationItem(
          'Glicose alta em ${p.name.split(' ').first}',
          'Valor ${last.glucoseMgDl!.toStringAsFixed(0)} mg/dL',
          Icons.warning_amber_rounded,
          Colors.redAccent,
        ));
      }

      // Gera notificações de alerta para pressão alta
      if ((last.systolic ?? 0) >= 140 || (last.diastolic ?? 0) >= 90) {
        notifications.add(NotificationItem(
          'Pressão elevada em ${p.name.split(' ').first}',
          '${last.systolic}/${last.diastolic}',
          Icons.monitor_heart_rounded,
          Colors.orange,
        ));
      }
    }

    // Adiciona exemplo de lembrete de consulta
    notifications.add(NotificationItem('Consulta amanhã - Maria', 'Lembrete de retorno às 10:00', Icons.event_rounded, Colors.blue));
  }

  void selectPatient(Patient p) {
    selectedPatient = p;
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
    final p = patients.firstWhere((e) => e.id == patientId);
    p.records.add(VitalRecord(date: date, glucoseMgDl: glucoseMgDl, systolic: systolic, diastolic: diastolic, weightKg: weightKg));
    _refreshAlertsFromVitals();
    notifyListeners();
  }

  // Conta o número de alertas
  int get alertsCount => notifications.where((n) => n.icon == Icons.warning_amber_rounded || n.icon == Icons.monitor_heart_rounded).length;

  // Conta o número de consultas para o dia atual
  int get todayAppointmentsCount {
    final now = DateTime.now();
    return appointments.where((a) => a.dateTime.year == now.year && a.dateTime.month == now.month && a.dateTime.day == now.day).length;
  }
}

// Global singleton usado pelas páginas. Em um app maior, prefira uma DI/Provider adequada.
final appData = AppData();
