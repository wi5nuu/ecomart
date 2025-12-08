// lib/providers/transaction_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/cart_item_model.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

    List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  /// Ringkasan keuangan untuk AdminAnalyticsScreen
  int get transactionCount => _transactions.length;

  double get totalRevenue =>
      _transactions.fold(0.0, (sum, trx) => sum + trx.totalAmount);

  double get totalCost =>
      _transactions.fold(0.0, (sum, trx) => sum + trx.totalCostPrice);

  double get totalProfit => totalRevenue - totalCost;

  /// Fetch semua transaksi dari Firestore
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .orderBy('transactionDate', descending: true)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetchTransactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah transaksi baru ke Firestore
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection('transactions').doc(transaction.id).set(
        transaction.toMap(),
      );
      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      debugPrint('Error addTransaction: $e');
    }
  }

  /// Update status transaksi
  Future<void> updateTransactionStatus(String transactionId, TransactionStatus status) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update({'status': status.toString().split('.').last});

      final index =
      _transactions.indexWhere((trx) => trx.id == transactionId);
      if (index != -1) {
        _transactions[index] = TransactionModel(
          id: _transactions[index].id,
          userId: _transactions[index].userId,
          items: _transactions[index].items,
          subtotal: _transactions[index].subtotal,
          totalAmount: _transactions[index].totalAmount,
          totalCostPrice: _transactions[index].totalCostPrice,
          shippingCost: _transactions[index].shippingCost,
          discountAmount: _transactions[index].discountAmount,
          paymentMethod: _transactions[index].paymentMethod,
          address: _transactions[index].address,
          city: _transactions[index].city,
          transactionDate: _transactions[index].transactionDate,
          status: status,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updateTransactionStatus: $e');
    }
  }

  /// Hapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      _transactions.removeWhere((trx) => trx.id == transactionId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleteTransaction: $e');
    }
  }
}
