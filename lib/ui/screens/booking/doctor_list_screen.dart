// lib/ui/screens/booking/doctor_list_screen.dart
import 'package:flutter/material.dart';
import '../../../data/models/poli_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/api_service.dart';
import 'booking_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final PoliModel poli;

  const DoctorListScreen({Key? key, required this.poli}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DoctorModel>> _doctorFuture;

  @override
  void initState() {
    super.initState();
    _doctorFuture = _apiService.getDoctorsByPoli(widget.poli.id);
  }

  void _showSchedules(DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<ScheduleModel>>(
          future: _apiService.getSchedulesByDoctor(doctor.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text("Jadwal belum tersedia untuk dokter ini.")),
              );
            }

            final schedules = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jadwal ${doctor.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return ListTile(
                          leading: const Icon(Icons.access_time, color: Colors.blue),
                          title: Text(schedule.day),
                          subtitle: Text(schedule.time),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Tutup bottom sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    poli: widget.poli,
                                    doctor: doctor,
                                    schedule: schedule,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Pilih"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poli.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DoctorModel>>(
        future: _doctorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada dokter di poli ini."));
          }

          final listDoctor = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listDoctor.length,
            itemBuilder: (context, index) {
              final doctor = listDoctor[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Ketuk untuk melihat jadwal"),
                  onTap: () => _showSchedules(doctor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}