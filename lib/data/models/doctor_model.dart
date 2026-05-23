class DoctorModel {
  final int id;
  final int poliId;
  final String name;

  DoctorModel({
    required this.id,
    required this.poliId,
    required this.name,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      poliId: json['poli_id'] is int ? json['poli_id'] : int.parse(json['poli_id'].toString()),
      name: json['name'] ?? json['nama'] ?? '',
    );
  }
}