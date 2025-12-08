import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthReady = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAuthReady => _isAuthReady;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      try {
        final userModel = await _firestoreService.getUser(firebaseUser.uid);
        _currentUser = userModel;
      } catch (e) {
        if (kDebugMode) print('Error mengambil user Firestore: $e');
        _currentUser = null;
      }
    }
    _isAuthReady = true;
    notifyListeners();
  }

  // Register user
  Future<bool> register(UserModel newUserModel, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Buat user di Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _errorMessage = 'Gagal membuat akun Firebase.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2️⃣ Buat user di Firestore collection 'users' dengan uid sebagai ID
      final userToSave = newUserModel.copyWith(id: firebaseUser.uid);
      await _firestoreService.saveUser(userToSave);

      // 3️⃣ Update current user
      _currentUser = userToSave;
      _isAuthReady = true;
      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Email sudah digunakan.';
      } else {
        _errorMessage = 'Registrasi gagal: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error tak terduga: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userModel = await _firestoreService.getUser(firebaseUser.uid);
        if (userModel == null) {
          _errorMessage = "Data user tidak ditemukan di Firestore.";
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = userModel;
      }

      _isAuthReady = true;
      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _errorMessage = 'Email atau password salah.';
      } else {
        _errorMessage = 'Login gagal: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error tak terduga: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print('Error saat logout: $e');
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
