import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
// Tambahkan import ApiService (sesuaikan path-nya jika berbeda)
import 'api_service.dart'; 

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Inisialisasi ApiService
  final ApiService _apiService = ApiService(); 

  // Fungsi Register
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String nik,
    required String password,
  }) async {
    try {
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Simpan data tambahan (NIK, Nama) ke Firestore di collection 'users'
        UserModel newUser = UserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          nik: nik,
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': newUser.id,
          'name': newUser.name,
          'email': newUser.email,
          'nik': newUser.nik,
          'created_at': FieldValue.serverTimestamp(),
        });

        // 3. --- LOMPATAN KE LARAVEL (BARU) ---
        // Setelah sukses di Firebase, langsung simpan otomatis ke MySQL
        await _apiService.registerPatientToBackend(
          uid: firebaseUser.uid,
          name: name,
          nik: nik,
        );

        return newUser;
      }
    } catch (e) {
      throw Exception('Gagal Register: ${e.toString()}');
    }
    return null;
  }

  // Fungsi Login
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login via Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Ambil data NIK dan Nama dari Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      throw Exception('Gagal Login: Cek kembali email dan password');
    }
    return null;
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}