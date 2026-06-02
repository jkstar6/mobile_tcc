// lib/data/repositories/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poli_model.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';

class ApiService {
  // Ubah sesuai dengan host server backend Laravel kalian
  static const String baseUrl =
      'https://backend-antrean-433898248394.asia-southeast2.run.app/api';

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
  // --- UBAH BAGIAN INI SAJA DI API SERVICE ---

  Future<List<DoctorModel>> getDoctorsByPoli(int poliId) async {
    try {
      // Backend mengambil semua dokter, tidak difilter dari server
      final response = await http.get(Uri.parse('$baseUrl/doctors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allDoctors = data
            .map((json) => DoctorModel.fromJson(json))
            .toList();
        // Memfilter secara lokal di aplikasi mobile
        return allDoctors.where((doc) => doc.poliId == poliId).toList();
      } else {
        throw Exception('Gagal memuat data Dokter');
      }
    } catch (e) {
      throw Exception('Error Dokter: $e');
    }
  }

  Future<List<ScheduleModel>> getSchedulesByDoctor(int doctorId) async {
    try {
      // Backend mengambil semua jadwal
      final response = await http.get(Uri.parse('$baseUrl/schedules'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allSchedules = data
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
        // Memfilter jadwal khusus untuk dokter yang dipilih
        return allSchedules
            .where((sched) => sched.doctorId == doctorId)
            .toList();
      } else {
        throw Exception('Gagal memuat data Jadwal');
      }
    } catch (e) {
      throw Exception('Error Jadwal: $e');
    }
  }

  Future<Map<String, dynamic>> storeBooking({
    required String userId,
    required int scheduleId,
    required String name,
    required String nik,
  }) async {
    try {
      // Mendapatkan tanggal hari ini (Format YYYY-MM-DD)
      String today = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.post(
        Uri.parse('$baseUrl/booking'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'patient_id': userId, // Sekarang mengirim teks UID Firebase yang asli
          'schedule_id': scheduleId,
          'tanggal': today,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal melakukan booking');
      }
    } catch (e) {
      throw Exception('Koneksi Booking Gagal: $e');
    }
  }

  // Fungsi untuk menyimpan profil pasien ke Laravel setelah register Firebase
  Future<void> registerPatientToBackend({
    required String uid,
    required String name,
    required String nik,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'id': uid, 'nama': name, 'nik': nik}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Cetak pesan asli dari Laravel ke terminal (Debug Console)
        print('====== ERROR LARAVEL ======');
        print(response.body);
        print('===========================');
        throw Exception(
          'Gagal menyimpan data pasien. Cek terminal untuk detailnya.',
        );
      }
    } catch (e) {
      throw Exception('Error Sinkronisasi Pasien: $e');
    }
  }
}
