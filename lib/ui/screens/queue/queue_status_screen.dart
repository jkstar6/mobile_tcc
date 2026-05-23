// lib/ui/screens/queue/queue_status_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Antrean Saya Realtime"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil booking terbaru milik user yang sedang login
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('user_id', isEqualTo: currentUserId)
            .orderBy('created_at', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Tambahkan ini untuk menangkap error dari Firestore
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Error Firestore: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ... (lanjutan kode if (!snapshot.hasData) biarkan seperti semula)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Anda belum mengambil nomor antrean hari ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          // Mengambil data dokumen antrean pertama (terbaru)
          final queueData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final String nomorAntrean = queueData['nomor_antrean'] ?? '---';
          final String status = queueData['status'] ?? 'menunggu';
          final String poliName = queueData['poli_name'] ?? '-';
          final String doctorName = queueData['doctor_name'] ?? '-';

          // Mengatur warna badge berdasarkan status panggilan
          Color statusColor = Colors.orange;
          IconData statusIcon = Icons.hourglass_empty;
          if (status == 'dipanggil') {
            statusColor = Colors.green;
            statusIcon = Icons.volume_up;
          } else if (status == 'selesai') {
            statusColor = Colors.grey;
            statusIcon = Icons.check_circle;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Notifikasi Alert jika statusnya "Dipanggil"
                if (status == 'dipanggil')
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          color: Colors.green.shade800,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "SILAKAN MENUJU RUANGAN!\nNomor antrean Anda sedang dipanggil.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Kartu Utama Nomor Antrean
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          poliName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Divider(height: 32),
                        const Text(
                          "NOMOR ANTREAN ANDA",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.5,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nomorAntrean,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Badge Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Informasi Tambahan
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Halaman ini menggunakan sinkronisasi cloud realtime. Anda tidak perlu memuat ulang halaman secara manual.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
