// lib/models/cart_item_model.dart - Model Item Keranjang untuk Transaksi dan Keranjang Persisten
// PERHATIAN: Konten ini adalah CartItemModel, tetapi disimpan di file transaction_model.dart sesuai permintaan Anda.

import 'package:flutter/foundation.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price; // Harga Jual
  final double costPrice; // Harga Modal (Penting untuk Laporan Laba Rugi)
  int quantity; // TIDAK final, agar kuantitas bisa diubah (tambah/kurang) di CartProvider
  final String imageUrl;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.quantity,
    required this.imageUrl,
  });

  // Metode untuk mendapatkan harga total JUAL item ini
  double get totalPrice => price * quantity;

  // Metode untuk mendapatkan total harga MODAL item ini
  double get totalCost => costPrice * quantity;

  // Metode copyWith(): Memungkinkan pembuatan salinan objek dengan perubahan parsial
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

  // Konversi dari Map (digunakan saat mengambil data Transaksi/Keranjang dari Firestore)
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      // Pastikan konversi ke double/int aman
      price: (map['price'] is num) ? map['price'].toDouble() : 0.0,
      costPrice: (map['costPrice'] is num) ? map['costPrice'].toDouble() : 0.0,
      quantity: (map['quantity'] is num) ? map['quantity'].toInt() : 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Konversi ke Map (digunakan saat menyimpan item ke Transaksi atau Keranjang di Firestore)
  Map<String, dynamic> toMapForTransaction() {
    return {
      // Simpan ID lokal CartItem (opsional)
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'costPrice': costPrice, // Simpan harga modal
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  // Metode toString(): Membantu dalam proses debugging
  @override
  String toString() {
    return 'CartItemModel{id: $id, name: $name, price: $price, costPrice: $costPrice, quantity: $quantity, totalSale: $totalPrice}';
  }
}