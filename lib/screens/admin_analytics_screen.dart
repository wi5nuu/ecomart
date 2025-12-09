import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import 'add_product_screen.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final currencyFormat =
  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final allProducts = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard & Analitik'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory, color: Colors.white),
            tooltip: 'Kelola Produk',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddProductScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: transactionProvider.isLoading || productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await transactionProvider.fetchTransactions();
          await productProvider.fetchProducts();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Keuangan
              const Text('Ringkasan Keuangan',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 10),
              _buildFinancialSummary(transactionProvider),
              const SizedBox(height: 30),

              // Ringkasan Stok Produk
              const Text('Status Stok Produk',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 10),
              _buildStockSummary(allProducts),
              const SizedBox(height: 30),

              // Transaksi Terbaru
              const Text('Detail Transaksi Terakhir',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 10),
              _buildTransactionList(
                  transactionProvider.transactions.take(5).toList()),
              const SizedBox(height: 30),

              // Semua Transaksi
              const Text('Semua Transaksi',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 10),
              _buildAllTransactionList(transactionProvider.transactions),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddProductScreen(),
            ),
          );
        },
        label: const Text('Kelola Produk'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.red.shade500,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ---------------- Ringkasan Keuangan ----------------
  Widget _buildFinancialSummary(TransactionProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          title: 'Total Transaksi',
          value: provider.transactionCount.toString(),
          icon: Icons.receipt_long,
          color: Colors.blue.shade600,
        ),
        _buildMetricCard(
          title: 'Total Penjualan (Revenue)',
          value: currencyFormat.format(provider.totalRevenue),
          icon: Icons.monetization_on,
          color: Colors.green.shade600,
        ),
        _buildMetricCard(
          title: 'Total Modal (Cost)',
          value: currencyFormat.format(provider.totalCost),
          icon: Icons.money_off,
          color: Colors.orange.shade600,
        ),
        _buildMetricCard(
          title: 'Total Keuntungan (Profit)',
          value: currencyFormat.format(provider.totalProfit),
          icon: Icons.trending_up,
          color: provider.totalProfit >= 0
              ? Colors.purple.shade600
              : Colors.red.shade600,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      {required String title,
        required String value,
        required IconData icon,
        required Color color}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: color),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ---------------- Ringkasan Stok Produk ----------------
  Widget _buildStockSummary(List<ProductModel> products) {
    int totalStock = products.fold(0, (sum, item) => sum + item.stock);
    int lowStockCount = products.where((p) => p.stock < 10 && p.stock > 0).length;
    int outOfStockCount = products.where((p) => p.stock == 0).length;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStockRow('Total Sisa Produk:', '$totalStock unit', Colors.black, isBold: true),
            _buildStockRow('Produk Stok Rendah (<10):', '$lowStockCount jenis', Colors.orange),
            _buildStockRow('Produk Habis (Stok 0):', '$outOfStockCount jenis', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStockRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  // ---------------- Transaksi Terakhir ----------------
  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return const Center(child: Text('Belum ada transaksi yang tercatat.'));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final transaction = transactions[i];
        final profit = transaction.totalAmount - transaction.totalCostPrice;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TRX ID: ${transaction.id.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(transaction.statusString.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      backgroundColor: transaction.status == TransactionStatus.completed
                          ? Colors.green
                          : transaction.status == TransactionStatus.pending
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Pelanggan: ${transaction.userId}'),
                Text('Payment: ${transaction.paymentMethod}'),
                Text('Alamat: ${transaction.address}, ${transaction.city}'),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal: Rp ${transaction.subtotal.toStringAsFixed(0)}'),
                    Text('Shipping: Rp ${transaction.shippingCost.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount: Rp ${transaction.discountAmount.toStringAsFixed(0)}'),
                    Text('Profit: Rp ${profit.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
                  ],
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Total: Rp ${transaction.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tanggal: ${DateFormat('dd/MM/yy HH:mm').format(transaction.transactionDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- Semua Transaksi ----------------
  Widget _buildAllTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return const Center(child: Text('Belum ada transaksi yang tercatat.'));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final trx = transactions[i];
        final profit = trx.totalAmount - trx.totalCostPrice;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header TRX ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TRX ID: ${trx.id.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: trx.statusString,
                      items: ['pending', 'completed', 'cancelled'].map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateTransactionStatus(trx.id, value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('User ID: ${trx.userId}'),
                Text('Payment: ${trx.paymentMethod}'),
                Text('Alamat: ${trx.address}, ${trx.city}'),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal: Rp ${trx.subtotal.toStringAsFixed(0)}'),
                    Text('Shipping: Rp ${trx.shippingCost.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount: Rp ${trx.discountAmount.toStringAsFixed(0)}'),
                    Text('Profit: Rp ${profit.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
                  ],
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total: Rp ${trx.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Batalkan / Hapus Pesanan',
                        onPressed: () => _deleteTransaction(trx.id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tanggal: ${DateFormat('dd/MM/yy HH:mm').format(trx.transactionDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateTransactionStatus(String transactionId, String statusString) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    TransactionStatus status;
    switch (statusString) {
      case 'completed':
        status = TransactionStatus.completed;
        break;
      case 'pending':
        status = TransactionStatus.pending;
        break;
      case 'cancelled':
        status = TransactionStatus.cancelled;
        break;
      default:
        status = TransactionStatus.pending;
    }

    transactionProvider.updateTransactionStatus(transactionId, status);
  }

  void _deleteTransaction(String transactionId) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin membatalkan transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              transactionProvider.deleteTransaction(transactionId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
