// lib/ui/screens/home/poli_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../../../data/models/poli_model.dart';
import '../../../data/repositories/api_service.dart';
import '../booking/doctor_list_screen.dart';
import '../queue/queue_status_screen.dart';

class PoliListScreen extends StatefulWidget {
  const PoliListScreen({Key? key}) : super(key: key);

  @override
  State<PoliListScreen> createState() => _PoliListScreenState();
}

class _PoliListScreenState extends State<PoliListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PoliModel>> _poliFuture;

  @override
  void initState() {
    super.initState();
    // Memicu pengambilan data poli saat halaman pertama kali dibuka
    _poliFuture = _apiService.getPolis();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Puskesmas Cerdas"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Baru untuk melihat Antrean Aktif Pasien
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Antrean Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QueueStatusScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: FutureBuilder<List<PoliModel>>(
        future: _poliFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data poli tersedia."));
          }

          final listPoli = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listPoli.length,
            itemBuilder: (context, index) {
              final poli = listPoli[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.local_hospital, color: Colors.white),
                  ),
                  title: Text(
                    poli.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: const Text("Ketuk untuk melihat jadwal dokter"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorListScreen(poli: poli),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
