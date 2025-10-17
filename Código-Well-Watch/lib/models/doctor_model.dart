class Doctor {
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String licenseNumber;
  final String clinicAddress;
  final String createdAt;
  final int yearsOfExperience;
  final String hospital;
  final String education;
  final String specialization;

  Doctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.licenseNumber,
    required this.clinicAddress,
    required this.createdAt,
    required this.yearsOfExperience,
    required this.hospital,
    required this.education,
    required this.specialization,
    required String crm,
    required int experience,
    required String gender,
    required List<String> skills,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'clinicAddress': clinicAddress,
      'createdAt': createdAt,
      'yearsOfExperience': yearsOfExperience,
      'hospital': hospital,
      'education': education,
      'specialization': specialization,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    var newMethod2;

    return Doctor(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      specialty: json['specialty'],
      licenseNumber: json['licenseNumber'],
      clinicAddress: json['clinicAddress'],
      createdAt: json['createdAt'],
      yearsOfExperience: json['yearsOfExperience'],
      hospital: json['hospital'],
      education: json['education'],
      specialization: json['specialization'],
      crm: '',
      experience: newMethod2,
      gender: '',
      skills: [],
    );
  }

  void newMethod() {}
}
