class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String bloodType;
  final String address;
  final List<String> allergies;
  final List<String> currentMedications;
  final String createdAt;
  final double height;
  final double weight;
  final String emergencyContact;
  final String emergencyPhone;
  final String insuranceProvider;
  final String insuranceNumber;
  final List<MedicalRecord> medicalHistory;
  final List<Appointment> appointments;
  final String profileImage;
  final Map<String, dynamic> vitalSigns;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.address,
    required this.allergies,
    required this.currentMedications,
    required this.createdAt,
    this.height = 0.0,
    this.weight = 0.0,
    this.emergencyContact = '',
    this.emergencyPhone = '',
    this.insuranceProvider = '',
    this.insuranceNumber = '',
    this.medicalHistory = const [],
    this.appointments = const [],
    this.profileImage = '',
    this.vitalSigns = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'address': address,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'createdAt': createdAt,
      'height': height,
      'weight': weight,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'medicalHistory':
          medicalHistory.map((record) => record.toJson()).toList(),
      'appointments': appointments.map((apt) => apt.toJson()).toList(),
      'profileImage': profileImage,
      'vitalSigns': vitalSigns,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bloodType: json['bloodType'] as String,
      address: json['address'] as String,
      allergies: List<String>.from(json['allergies'] as List),
      currentMedications: List<String>.from(json['currentMedications'] as List),
      createdAt: json['createdAt'] as String,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      emergencyContact: json['emergencyContact'] as String? ?? '',
      emergencyPhone: json['emergencyPhone'] as String? ?? '',
      insuranceProvider: json['insuranceProvider'] as String? ?? '',
      insuranceNumber: json['insuranceNumber'] as String? ?? '',
      medicalHistory: json['medicalHistory'] != null
          ? List<MedicalRecord>.from(
              (json['medicalHistory'] as List).map(
                (x) => MedicalRecord.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      appointments: json['appointments'] != null
          ? List<Appointment>.from(
              (json['appointments'] as List).map(
                (x) => Appointment.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      profileImage: json['profileImage'] as String? ?? '',
      vitalSigns: json['vitalSigns'] as Map<String, dynamic>? ?? {},
    );
  }
}

class MedicalRecord {
  final String id;
  final String doctorId;
  final String doctorName;
  final String date;
  final String diagnosis;
  final String description;
  final String treatment;
  final List<String> prescriptions;
  final List<String> testResults;
  final List<String> attachments;

  MedicalRecord({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.description,
    required this.treatment,
    this.prescriptions = const [],
    this.testResults = const [],
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date,
      'diagnosis': diagnosis,
      'description': description,
      'treatment': treatment,
      'prescriptions': prescriptions,
      'testResults': testResults,
      'attachments': attachments,
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      date: json['date'] as String,
      diagnosis: json['diagnosis'] as String,
      description: json['description'] as String,
      treatment: json['treatment'] as String,
      prescriptions: List<String>.from(json['prescriptions'] as List),
      testResults: List<String>.from(json['testResults'] as List),
      attachments: List<String>.from(json['attachments'] as List),
    );
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String date;
  final String time;
  final String type;
  final String status;
  final String notes;
  final bool isConfirmed;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    this.notes = '',
    this.isConfirmed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date,
      'time': time,
      'type': type,
      'status': status,
      'notes': notes,
      'isConfirmed': isConfirmed,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String? ?? '',
      isConfirmed: json['isConfirmed'] as bool? ?? false,
    );
  }
}
