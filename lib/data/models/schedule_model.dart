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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      doctorId: json['doctor_id'] is int ? json['doctor_id'] : int.parse(json['doctor_id'].toString()),
      day: json['day'] ?? json['hari'] ?? '',
      time: json['time'] ?? json['jam'] ?? '',
    );
  }
}