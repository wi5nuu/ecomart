// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  /// Ambil semua item di keranjang
  List<CartItemModel> get items => [..._items];

  /// Jumlah item di keranjang
  int get itemCount => _items.length;

  /// Total harga jual semua item
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  /// Total harga modal semua item
  double get totalCostPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalCost;
    }
    return total;
  }

  /// Menambahkan item ke keranjang
  void addItem(CartItemModel newItem) {
    try {
      // Cek apakah produk sudah ada di cart
      final index = _items.indexWhere((item) => item.productId == newItem.productId);
      if (index >= 0) {
        // Jika ada, tambahkan kuantitas
        _items[index].quantity += newItem.quantity;
      } else {
        _items.add(newItem);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error addItem: $e');
    }
  }

  /// Menghapus item dari keranjang
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Update kuantitas item
  void updateItemQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  /// Clear semua item di keranjang
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Mengecek apakah item tertentu ada di cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Ambil total kuantitas semua item
  int get totalQuantity {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  /// Debugging: Cetak semua item di cart
  void printCart() {
    for (var item in _items) {
      debugPrint(item.toString());
    }
    debugPrint('Total Amount: $totalAmount, Total Cost Price: $totalCostPrice');
  }
}
