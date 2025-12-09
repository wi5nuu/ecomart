import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === USER METHODS ===
  // Simpan user ke Firestore (ID dokumen = UID Firebase Auth)
  Future<void> saveUser(UserModel user) async {
    try {
      if (user.id == null) {
        throw Exception('ID user belum diisi. Pastikan ID user sudah dibuat.');
      }
      await _firestore.collection('users').doc(user.id!).set(user.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan user: $e');
    }
  }

  // Ambil user berdasarkan UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil user berdasarkan UID: $e');
    }
  }

  // Cek apakah email sudah terdaftar
  Future<bool> isEmailRegistered(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal memeriksa email: $e');
    }
  }

  // Ambil user berdasarkan email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.id, query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil user: $e');
    }
  }

  // === PRODUCT METHODS ===
  Future<List<ProductModel>> getProducts() async {
    try {
      final query = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final query = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return query.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk by category: $e');
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }
}
