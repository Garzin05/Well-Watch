// patient_model.dart

class Patient {
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

  Patient({
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
  });

  // Pode adicionar métodos adicionais para converter de/para JSON, por exemplo
  Map<String, dynamic> toMap() {
    return {
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
    };
  }

  // Pode também adicionar um método estático para converter de Map para Patient
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      age: map['age'],
      gender: map['gender'],
      bloodType: map['bloodType'],
      address: map['address'],
      allergies: List<String>.from(map['allergies']),
      currentMedications: List<String>.from(map['currentMedications']),
      createdAt: map['createdAt'],
    );
  }

  Object? toJson() {
    return null;
  }
}
