import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthReady = false;

  // =========================
  // Getter
  // =========================
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isAuthReady => _isAuthReady;

  // =========================
  // Private: hash password
  // =========================
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // =========================
  // Set auth ready
  // =========================
  void setAuthReady() {
    _isAuthReady = true;
    notifyListeners();
  }

  // =========================
  // Register user
  // =========================
  Future<bool> register(UserModel newUser, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userRef = _firestore.collection('users');

      // cek email sudah ada atau belum
      final query = await userRef.where('email', isEqualTo: newUser.email).get();
      if (query.docs.isNotEmpty) {
        _setError('Email sudah digunakan.');
        return false;
      }

      // hash password
      final hashedPassword = _hashPassword(password);

      // buat dokumen baru
      final docRef = userRef.doc();
      final userToSave = newUser.copyWith(
        id: docRef.id,
        password: hashedPassword,
      );

      await docRef.set(userToSave.toMap());
      _currentUser = userToSave;

      return true;
    } catch (e) {
      _setError('Error registrasi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // Login user
  // =========================
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final hashedPassword = _hashPassword(password);
      final userRef = _firestore.collection('users');
      final query = await userRef
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: hashedPassword)
          .get();

      if (query.docs.isEmpty) {
        _setError('Email atau password salah.');
        return false;
      }

      final doc = query.docs.first;
      final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      _currentUser = UserModel.fromMap(doc.id, userData);

      return true;
    } catch (e) {
      _setError('Error login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // Logout user
  // =========================
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // =========================
  // Clear error
  // =========================
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // =========================
  // Private helpers
  // =========================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // =========================
  // Update currentUser data (opsional)
  // =========================
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_currentUser!.id).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.id, doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal refresh user data: $e');
    }
  }


  // =========================
// Cek session login otomatis
// =========================
  Future<void> tryAutoLogin() async {
    // Simulasi cek session / token yang tersimpan di device
    // Karena kita tidak pakai SharedPreferences, kita hanya set auth ready
    // jika sudah ada currentUser di memory (misal setelah login sebelumnya)
    await Future.delayed(const Duration(milliseconds: 500)); // optional delay
    setAuthReady();
  }

}
