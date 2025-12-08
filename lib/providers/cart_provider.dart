import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _cartSubscription;

  // --- Getters ---
  List<CartItemModel> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalCostAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalCost);

  String? get currentUserId => _auth.currentUser?.uid;

  // --- Firestore Utility ---
  CollectionReference<Map<String, dynamic>> _getCartCollection() {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated.');
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  // --- Listener real-time Cart ---
  void setupCartListener() {
    _cartSubscription?.cancel();
    _items.clear();
    notifyListeners();

    if (currentUserId == null) return;

    _cartSubscription = _getCartCollection().snapshots().listen((snapshot) {
      _items.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final item = CartItemModel.fromMap(data);
        _items[item.productId] = item;
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error loading cart from Firestore: $error");
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  // --- Cart Operations ---
  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    if (currentUserId == null) return;

    if (product.stock <= 0) return;

    int currentQuantity = _items[product.id]?.quantity ?? 0;
    if (currentQuantity + quantity > product.stock) return;

    final newCartItem = CartItemModel(
      id: DateTime.now().toString(),
      productId: product.id!,
      name: product.name,
      price: product.price,
      costPrice: product.costPrice,
      quantity: quantity,
      imageUrl: product.imageUrl,
    );

    final itemDocRef = _getCartCollection().doc(product.id);

    if (_items.containsKey(product.id)) {
      await itemDocRef.update({'quantity': FieldValue.increment(quantity)});
    } else {
      await itemDocRef.set(newCartItem.toMapForTransaction());
    }
  }

  Future<void> incrementQuantity(String productId) async {
    if (!_items.containsKey(productId)) return;
    final itemDocRef = _getCartCollection().doc(productId);
    await itemDocRef.update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decrementQuantity(String productId) async {
    if (!_items.containsKey(productId)) return;
    final currentItem = _items[productId]!;
    if (currentItem.quantity <= 1) {
      await removeItem(productId);
    } else {
      final itemDocRef = _getCartCollection().doc(productId);
      await itemDocRef.update({'quantity': FieldValue.increment(-1)});
    }
  }

  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId)) return;
    final itemDocRef = _getCartCollection().doc(productId);
    await itemDocRef.delete();
  }

  Future<void> clearCart() async {
    if (currentUserId == null) return;

    final cartCollection = _getCartCollection();
    final cartSnapshot = await cartCollection.get();

    final batch = _firestore.batch();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    _items.clear();
    notifyListeners();
  }

  // --- Checkout ---
  Future<void> checkout({
    required String selectedAddress,
    required String city,
    required String paymentMethod,
    required double shippingCost,
    required double discountAmount,
  }) async {
    if (currentUserId == null || _items.isEmpty) return;

    try {
      final subtotal = totalAmount;
      final totalCostPrice = totalCostAmount;
      final totalFinal = subtotal + shippingCost - discountAmount;

      // Buat transaksi baru
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUserId!,
        items: _items.values.toList(),
        subtotal: subtotal,
        totalAmount: totalFinal,
        totalCostPrice: totalCostPrice,
        shippingCost: shippingCost,
        discountAmount: discountAmount,
        paymentMethod: paymentMethod,
        address: selectedAddress,
        city: city,
        transactionDate: DateTime.now(),
        status: TransactionStatus.completed,
      );

      // Simpan ke collection 'transactions'
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());

      // Kosongkan cart
      await clearCart();

      debugPrint('Checkout berhasil. Transaksi tercatat dengan ID: ${transaction.id}');
    } catch (e) {
      debugPrint('Checkout gagal: $e');
    }
  }
}
