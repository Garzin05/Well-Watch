import 'package:intl/intl.dart';

class HealthRecord {
  final DateTime date;
  final String time;
  final String type; // 'glucose', 'weight', 'blood_pressure', 'medication'

  HealthRecord({required this.date, required this.time, required this.type});

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
  String get formattedTime => time;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'time': time,
    'type': type,
  };

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      date: DateTime.parse(json['date']),
      time: json['time'],
      type: json['type'],
    );
  }
}

class GlucoseRecord extends HealthRecord {
  final double glucoseLevel; // mg/dl

  GlucoseRecord({
    required super.date,
    required super.time,
    required this.glucoseLevel,
  }) : super(type: 'glucose');

  String get formattedGlucose => '${glucoseLevel.toStringAsFixed(0)} mg/dl';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'glucoseLevel': glucoseLevel,
  };

  factory GlucoseRecord.fromJson(Map<String, dynamic> json) {
    return GlucoseRecord(
      date: DateTime.parse(json['date']),
      time: json['time'],
      glucoseLevel: json['glucoseLevel'].toDouble(),
    );
  }
}

class WeightRecord extends HealthRecord {
  final double weight; // kg

  WeightRecord({
    required super.date,
    required super.time,
    required this.weight,
  }) : super(type: 'weight');

  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'weight': weight};

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      date: DateTime.parse(json['date']),
      time: json['time'],
      weight: json['weight'].toDouble(),
    );
  }
}

class BloodPressureRecord extends HealthRecord {
  final int systolic;
  final int diastolic;
  final int? heartRate; // opcional, batimentos por minuto

  BloodPressureRecord({
    required super.date,
    required super.time,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
  }) : super(type: 'blood_pressure');

  String get formattedBP => '$systolic/$diastolic mmHg';
  String get formattedHeartRate => heartRate != null ? '$heartRate bpm' : 'N/A';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'systolic': systolic,
    'diastolic': diastolic,
    'heartRate': heartRate,
  };

  factory BloodPressureRecord.fromJson(Map<String, dynamic> json) {
    return BloodPressureRecord(
      date: DateTime.parse(json['date']),
      time: json['time'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      heartRate: json['heartRate'],
    );
  }
}

class MedicationRecord extends HealthRecord {
  final String medicationName;
  final String dosage;
  final List<String> scheduledTimes;
  final bool taken;

  MedicationRecord({
    required super.date,
    required super.time,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTimes,
    this.taken = false,
  }) : super(type: 'medication');

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'medicationName': medicationName,
    'dosage': dosage,
    'scheduledTimes': scheduledTimes,
    'taken': taken,
  };

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      date: DateTime.parse(json['date']),
      time: json['time'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      scheduledTimes: List<String>.from(json['scheduledTimes']),
      taken: json['taken'] ?? false,
    );
  }
}
