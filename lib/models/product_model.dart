import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;       // Harga jual
  final double costPrice;   // Harga modal (BARU)
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.costPrice,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'costPrice': costPrice,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    final num priceNum = map['price'] ?? 0;
    final num costNum = map['costPrice'] ?? 0;
    final num ratingNum = map['rating'] ?? 0;

    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: priceNum.toDouble(),
      costPrice: costNum.toDouble(),   // BARU
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      rating: ratingNum.toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    String? imageUrl,
    String? category,
    int? stock,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Format harga jual
  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // Format harga modal
  String get formattedCostPrice {
    return 'Rp ${costPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
