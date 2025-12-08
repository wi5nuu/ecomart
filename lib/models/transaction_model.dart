import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

enum TransactionStatus { pending, completed, cancelled }

class TransactionModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double totalAmount;
  final double totalCostPrice;
  final double shippingCost;
  final double discountAmount;
  final String paymentMethod;
  final String address;
  final String city;
  final DateTime transactionDate;
  final TransactionStatus status;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.totalAmount,
    required this.totalCostPrice,
    required this.shippingCost,
    required this.discountAmount,
    required this.paymentMethod,
    required this.address,
    required this.city,
    required this.transactionDate,
    this.status = TransactionStatus.pending,
  });

  String get statusString {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toMapForTransaction()).toList(),
      'subtotal': subtotal,
      'totalAmount': totalAmount,
      'totalCostPrice': totalCostPrice,
      'shippingCost': shippingCost,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod,
      'address': address,
      'city': city,
      'transactionDate': transactionDate,
      'status': status.toString().split('.').last,
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      subtotal: (data['subtotal']?.toDouble() ?? 0.0),
      totalAmount: (data['totalAmount']?.toDouble() ?? 0.0),
      totalCostPrice: (data['totalCostPrice']?.toDouble() ?? 0.0),
      shippingCost: (data['shippingCost']?.toDouble() ?? 0.0),
      discountAmount: (data['discountAmount']?.toDouble() ?? 0.0),
      paymentMethod: data['paymentMethod'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      status: TransactionStatus.values.firstWhere(
            (e) => e.toString() == 'TransactionStatus.${data['status']}',
        orElse: () => TransactionStatus.pending,
      ),
    );
  }
}
