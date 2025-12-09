class MedicoPaciente {
  final String doctorId;
  final String patientId;
  final String createdAt;

  MedicoPaciente({
    required this.doctorId,
    required this.patientId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'createdAt': createdAt,
    };
  }

  factory MedicoPaciente.fromJson(Map<String, dynamic> json) {
    return MedicoPaciente(
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
