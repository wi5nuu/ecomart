import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch semua produk
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil service untuk mendapatkan semua produk
      _products = await _firestoreService.getProducts();

      // Debugging: Cek jumlah produk yang dimuat
      debugPrint('Produk berhasil dimuat dari FirestoreService: ${_products.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Tangani error dan tampilkan
      _errorMessage = 'Gagal memuat produk: ${e.toString()}';
      debugPrint('Error fetchProducts: $_errorMessage');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch produk by category
  Future<void> fetchProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getProductsByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat produk berdasarkan kategori: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product baru (untuk admin)
  Future<bool> addProduct(ProductModel product) async {
    try {
      // Asumsi addProduct mengembalikan ID produk yang baru
      final newId = await _firestoreService.addProduct(product);

      // Buat salinan produk dengan ID yang ditetapkan oleh Firestore
      final newProductWithId = product.copyWith(id: newId);

      // Tambahkan produk ke daftar lokal
      _products.add(newProductWithId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan produk: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get product by id dari daftar lokal
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get products by search dari daftar lokal yang sudah dimuat
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}