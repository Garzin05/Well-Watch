class Doctor {
  final String id;
  final String name; // campo que vai pegar o nome do médico
  final String email;
  final String phone;
  final String specialty;
  final String crm;
  final String clinicAddress;
  final String createdAt;
  final int yearsOfExperience;
  final String hospital;
  final String education;
  final String specialization;
  final String gender;
  final List<String> skills;
  final String about;
  final String profileImage;
  final List<WorkingHours> workingHours;
  final bool isAvailable;
  final double rating;
  final int totalPatients;
  final int totalAppointments;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.crm,
    required this.clinicAddress,
    required this.createdAt,
    required this.yearsOfExperience,
    required this.hospital,
    required this.education,
    required this.specialization,
    required this.gender,
    required this.skills,
    required this.about,
    this.profileImage = '',
    required this.workingHours,
    this.isAvailable = true,
    this.rating = 0.0,
    this.totalPatients = 0,
    this.totalAppointments = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'crm': crm,
      'clinicAddress': clinicAddress,
      'createdAt': createdAt,
      'yearsOfExperience': yearsOfExperience,
      'hospital': hospital,
      'education': education,
      'specialization': specialization,
      'gender': gender,
      'skills': skills,
      'about': about,
      'profileImage': profileImage,
      'workingHours': workingHours.map((wh) => wh.toJson()).toList(),
      'isAvailable': isAvailable,
      'rating': rating,
      'totalPatients': totalPatients,
      'totalAppointments': totalAppointments,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'].toString(),
      name: json['name'] ?? json['nome'] ?? 'Usuário', // garante pegar o nome real
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialty: json['specialty'] as String,
      crm: json['crm'] as String,
      clinicAddress: json['clinicAddress'] as String,
      createdAt: json['createdAt'] as String,
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      hospital: json['hospital'] as String,
      education: json['education'] as String,
      specialization: json['specialization'] as String,
      gender: json['gender'] as String,
      skills: List<String>.from(json['skills'] as List? ?? []),
      about: json['about'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      workingHours: (json['workingHours'] as List? ?? [])
          .map((wh) => WorkingHours.fromJson(wh as Map<String, dynamic>))
          .toList(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalPatients: json['totalPatients'] as int? ?? 0,
      totalAppointments: json['totalAppointments'] as int? ?? 0,
    );
  }
}

class WorkingHours {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  WorkingHours({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
