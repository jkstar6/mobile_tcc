// lib/data/models/poli_model.dart
class PoliModel {
  final int id;
  final String name;

  PoliModel({required this.id, required this.name});

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      // Tambahkan json['nama_poli'] di sini
      name: json['name'] ?? json['nama'] ?? json['nama_poli'] ?? '',
    );
  }
}
