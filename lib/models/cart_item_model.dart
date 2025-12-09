// lib/models/cart_item_model.dart
// Model Item Keranjang untuk Transaksi dan Keranjang Persisten

import 'package:flutter/foundation.dart';

class CartItemModel {
  final String id;           // ID unik lokal untuk item keranjang
  final String productId;    // ID produk di Firestore
  final String name;         // Nama produk
  final double price;        // Harga jual produk
  final double costPrice;    // Harga modal produk (untuk laporan laba/rugi)
  int quantity;              // Jumlah item, bisa diubah
  final String imageUrl;     // URL gambar produk

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.quantity,
    required this.imageUrl,
  });

  // ===== Hitung total harga jual =====
  double get totalPrice => price * quantity;

  // ===== Hitung total harga modal =====
  double get totalCost => costPrice * quantity;

  // ===== Copy dengan update parsial =====
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    double? costPrice,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // ===== Konversi dari Map (dari Firestore) =====
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] is num) ? map['price'].toDouble() : 0.0,
      costPrice: (map['costPrice'] is num) ? map['costPrice'].toDouble() : 0.0,
      quantity: (map['quantity'] is num) ? map['quantity'].toInt() : 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // ===== Konversi ke Map untuk transaksi =====
  Map<String, dynamic> toMapForTransaction() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  // ===== Debugging =====
  @override
  String toString() {
    return 'CartItemModel{id: $id, productId: $productId, name: $name, price: $price, costPrice: $costPrice, quantity: $quantity, totalPrice: $totalPrice}';
  }
}
