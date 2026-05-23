// lib/data/repositories/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poli_model.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';

class ApiService {
  // Ubah sesuai dengan host server backend Laravel kalian
  static const String baseUrl = 'http://192.168.1.2:8000/api';

  Future<List<PoliModel>> getPolis() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/polis'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PoliModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      // BACKUP PLAN: Jika server Laravel belum jalan/belum di-deploy,
      // kita kembalikan data dummy agar UI mobile tetap bisa dikerjakan.
      print("Koneksi API Gagal, menggunakan data cadangan: $e");
      return [
        PoliModel(id: 1, name: 'Poli Umum'),
        PoliModel(id: 2, name: 'Poli Gigi'),
        PoliModel(id: 3, name: 'Poli Anak (KIA)'),
        PoliModel(id: 4, name: 'Poli Mata'),
      ];
    }
  }

  // Mengambil daftar Dokter berdasarkan Poli
  Future<List<DoctorModel>> getDoctorsByPoli(int poliId) async {
    try {
      // Biasanya API akan menerima parameter seperti /doctors?poli_id=1
      final response = await http.get(
        Uri.parse('$baseUrl/doctors?poli_id=$poliId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DoctorModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data Dokter');
      }
    } catch (e) {
      print("Koneksi API Gagal, menggunakan data dummy dokter: $e");
      // Data Dummy Dokter
      List<DoctorModel> dummyDoctors = [
        DoctorModel(id: 1, poliId: 1, name: 'dr. Andi (Umum)'),
        DoctorModel(id: 2, poliId: 1, name: 'dr. Budi (Umum)'),
        DoctorModel(id: 3, poliId: 2, name: 'drg. Citra (Gigi)'),
        DoctorModel(id: 4, poliId: 3, name: 'dr. Dewi, Sp.A (Anak)'),
        DoctorModel(id: 5, poliId: 4, name: 'dr. Eko, Sp.M (Mata)'),
      ];
      // Filter dummy data sesuai poli yang dipilih
      return dummyDoctors.where((doc) => doc.poliId == poliId).toList();
    }
  }

  // Mengambil jadwal berdasarkan Dokter
  Future<List<ScheduleModel>> getSchedulesByDoctor(int doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules?doctor_id=$doctorId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data Jadwal');
      }
    } catch (e) {
      print("Koneksi API Gagal, menggunakan data dummy jadwal: $e");
      // Data Dummy Jadwal
      List<ScheduleModel> dummySchedules = [
        ScheduleModel(id: 1, doctorId: 1, day: 'Senin', time: '08:00 - 12:00'),
        ScheduleModel(id: 2, doctorId: 1, day: 'Selasa', time: '08:00 - 12:00'),
        ScheduleModel(id: 3, doctorId: 2, day: 'Rabu', time: '13:00 - 16:00'),
        ScheduleModel(id: 4, doctorId: 3, day: 'Kamis', time: '09:00 - 14:00'),
        ScheduleModel(id: 5, doctorId: 4, day: 'Jumat', time: '08:00 - 11:00'),
        ScheduleModel(id: 6, doctorId: 5, day: 'Senin', time: '10:00 - 15:00'),
      ];
      return dummySchedules
          .where((sched) => sched.doctorId == doctorId)
          .toList();
    }
  }

  // Mengirim data booking ke backend Laravel
  Future<Map<String, dynamic>> storeBooking({
    required String userId,
    required int scheduleId,
    required String name,
    required String nik,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/booking'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'schedule_id': scheduleId,
          'name': name,
          'nik': nik,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal melakukan booking');
      }
    } catch (e) {
      print("Koneksi API Gagal, menggunakan simulasi booking sukses: $e");
      // BACKUP PLAN: Jika Laravel belum siap, kembalikan simulasi data nomor antrean
      await Future.delayed(const Duration(seconds: 1)); // Efek loading
      return {
        'status': 'success',
        'message': 'Booking berhasil disimpan',
        'data': {'nomor_antrean': 'A-012', 'sisa_antrean': 5},
      };
    }
  }
}
