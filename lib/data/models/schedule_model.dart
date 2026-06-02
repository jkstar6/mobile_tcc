class ScheduleModel {
  final int id;
  final int doctorId;
  final String day;
  final String time;

  ScheduleModel({
    required this.id,
    required this.doctorId,
    required this.day,
    required this.time,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      doctorId:
          int.tryParse(
            json['doctor_id']?.toString() ??
                json['id_dokter']?.toString() ??
                '0',
          ) ??
          0,
      day: json['day'] ?? json['hari'] ?? json['hari_praktik'] ?? 'Hari -',
      time: json['time'] ?? json['jam'] ?? json['jam_praktik'] ?? 'Jam -',
    );
  }
}
