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
      // Menggunakan tryParse agar tidak crash jika null, default ke 0
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      
      // Mengecek berbagai kemungkinan nama kolom dari backend
      poliId: int.tryParse(json['poli_id']?.toString() ?? 
                           json['id_poli']?.toString() ?? 
                           json['poliklinik_id']?.toString() ?? '0') ?? 0,
                           
      name: json['name'] ?? json['nama'] ?? json['nama_dokter'] ?? 'Nama Dokter Kosong',
    );
  }
}