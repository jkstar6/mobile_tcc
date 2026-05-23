// lib/ui/screens/booking/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/poli_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/api_service.dart';

class BookingScreen extends StatefulWidget {
  final PoliModel poli;
  final DoctorModel doctor;
  final ScheduleModel schedule;

  const BookingScreen({
    Key? key,
    required this.poli,
    required this.doctor,
    required this.schedule,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _userName = '';
  String _userNik = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data NIK dan Nama dari Firestore berdasarkan user yang login
  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc.data()?['name'] ?? '';
          _userNik = doc.data()?['nik'] ?? '';
        });
      }
    }
  }

  void _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.storeBooking(
        userId: _userId,
        scheduleId: widget.schedule.id,
        name: _userName,
        nik: _userNik,
      );

      if (!mounted) return;

      // Ambil data nomor antrean dari response Laravel/Dummy
      final nomorAntrean = result['data']['nomor_antrean'] ?? '000';

      // Tampilkan dialog sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Booking Berhasil"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nomor Antrean Anda:"),
              const SizedBox(height: 12),
              Text(
                nomorAntrean,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text("Poliklinik: ${widget.poli.name}"),
              Text("Dokter: ${widget.doctor.name}"),
              Text("Jadwal: ${widget.schedule.day}, ${widget.schedule.time}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Membuat simulasi data booking aktif di Firestore agar bisa dites realtime-nya
                await FirebaseFirestore.instance.collection('bookings').add({
                  'user_id': _userId,
                  'nomor_antrean': nomorAntrean,
                  'poli_name': widget.poli.name,
                  'doctor_name': widget.doctor.name,
                  'status': 'menunggu', // default status awal
                  'created_at': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;
                Navigator.pop(context); // Tutup dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Selesai"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfirmasi Booking"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _userName.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Data Pasien", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          Text("Nama: $_userName"),
                          const SizedBox(height: 4),
                          Text("NIK: $_userNik"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Detail Kunjungan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          Text("Poli: ${widget.poli.name}"),
                          const SizedBox(height: 4),
                          Text("Dokter: ${widget.doctor.name}"),
                          const SizedBox(height: 4),
                          Text("Waktu: ${widget.schedule.day}, ${widget.schedule.time}"),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Konfirmasi & Ambil Antrean", style: TextStyle(fontSize: 16, color: Colors.white)),
                  )
                ],
              ),
            ),
    );
  }
}