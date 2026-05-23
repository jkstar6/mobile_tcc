// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String nik;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.nik,
  });

  // Nanti digunakan saat integrasi API JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      nik: json['nik'] ?? '',
    );
  }
}