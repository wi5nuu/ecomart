import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/checkout_model.dart';
import '../providers/cart_provider.dart';
import 'products_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late CheckoutModel _checkoutData;
  final TextEditingController _voucherController = TextEditingController();

  final List<String> _jabodetabekCities = [
    'Jakarta',
    'Bogor',
    'Depok',
    'Tangerang',
    'Bekasi',
  ];

  final List<String> _allCities = [
    'Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi',
    'Bandung', 'Surabaya', 'Medan', 'Yogyakarta'
  ];

  final List<String> _paymentMethods = [
    'Transfer Bank BNI',
    'Transfer Bank Mandiri',
    'Gopay',
    'OVO',
    'Bayar di Tempat (COD)',
  ];

  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    _checkoutData = CheckoutModel(subtotal: cartProvider.totalAmount);

    _calculateShippingCost();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  /// Hitung ongkos kirim berdasarkan kota
  void _calculateShippingCost() {
    setState(() {
      final city = _checkoutData.city;
      _checkoutData.shippingCost = _jabodetabekCities.contains(city) ? 0.0 : 15000.0;
    });
  }

  /// Terapkan voucher diskon
  void _applyVoucher(String code) {
    setState(() {
      _checkoutData.voucherCode = code.toUpperCase();
      _checkoutData.discountAmount = 0.0;

      if (code.toUpperCase() == 'DISKON10') {
        _checkoutData.discountAmount = _checkoutData.subtotal * 0.1;
        _showSnack('Voucher DISKON10 berhasil diterapkan!', Colors.green);
      } else if (code.toUpperCase() == 'HEMAT5K') {
        _checkoutData.discountAmount = 5000.0;
        _showSnack('Voucher HEMAT5K berhasil diterapkan!', Colors.green);
      } else if (code.isNotEmpty) {
        _showSnack('Voucher tidak valid atau kadaluarsa.', Colors.red);
      }
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Proses pembayaran
  void _processPayment() {
    if (_checkoutData.selectedAddress.isEmpty || _checkoutData.selectedAddress == 'Pilih Alamat Pengiriman') {
      _showSnack('Mohon pilih alamat pengiriman terlebih dahulu.', Colors.red);
      return;
    }

    if (_checkoutData.paymentMethod.isEmpty || _checkoutData.paymentMethod == 'Pilih Metode Pembayaran') {
      _showSnack('Mohon pilih metode pembayaran.', Colors.red);
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();

    _showSnack(
      'Pembayaran sebesar Rp ${_checkoutData.totalFinal.toStringAsFixed(0)} sukses! Pesanan sedang diproses.',
      Colors.green,
    );

    // Navigasi kembali ke layar produk, hapus semua layar sebelumnya
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ProductsScreen()),
          (route) => false,
    );
  }

  /// Widget Pilih Alamat
  Widget _buildAddressSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_checkoutData.selectedAddress.isEmpty
            ? 'Pilih Alamat Pengiriman'
            : _checkoutData.selectedAddress),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final selectedCity = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => _buildCitySelector(),
          );

          if (selectedCity != null) {
            setState(() {
              _checkoutData.city = selectedCity;
              _checkoutData.selectedAddress =
              'Jalan Melati No. 12, Kel. Sentosa, Kota $selectedCity, Indonesia';
              _calculateShippingCost();
            });
          }
        },
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Pilih Kota Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 250,
            child: ListView(
              children: _allCities.map((city) {
                final isFree = _jabodetabekCities.contains(city);
                return ListTile(
                  title: Text(city, style: TextStyle(color: isFree ? Colors.green : Colors.black)),
                  trailing: isFree ? const Text('GRATIS ONGKIR', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)) : null,
                  onTap: () => Navigator.pop(context, city),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Voucher
  Widget _buildVoucherSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voucher Diskon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode voucher (DISKON10/HEMAT5K)',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _applyVoucher(_voucherController.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
                  child: const Text('Terapkan'),
                ),
              ],
            ),
            if (_checkoutData.discountAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Diskon Rp ${_checkoutData.discountAmount.toStringAsFixed(0)} berhasil diterapkan!', style: const TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }

  /// Widget Metode Pembayaran
  Widget _buildPaymentSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.green),
        title: const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_checkoutData.paymentMethod.isEmpty
            ? 'Pilih Metode Pembayaran'
            : _checkoutData.paymentMethod),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final selectedMethod = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => _buildPaymentMethodSelector(),
          );

          if (selectedMethod != null) {
            setState(() => _checkoutData.paymentMethod = selectedMethod);
          }
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 250,
            child: ListView(
              children: _paymentMethods.map((method) => ListTile(
                title: Text(method),
                onTap: () => Navigator.pop(context, method),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Ringkasan Pembayaran
  Widget _buildSummarySection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rincian Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSummaryRow('Subtotal Produk', _checkoutData.subtotal, color: Colors.black54),
            _buildSummaryRow('Ongkos Kirim', _checkoutData.shippingCost,
                color: _checkoutData.shippingCost == 0.0 ? Colors.green : Colors.orange,
                isShipping: true, city: _checkoutData.city),
            _buildSummaryRow('Diskon Voucher', -_checkoutData.discountAmount, color: Colors.red),
            const Divider(height: 20, thickness: 2),
            _buildSummaryRow('Total Pembayaran', _checkoutData.totalFinal, color: Colors.blue.shade700, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount,
      {Color color = Colors.black, bool isTotal = false, bool isShipping = false, String? city}) {
    String detailText = '';
    if (isShipping) {
      detailText = amount == 0.0 ? '(Gratis Ongkir ke $city!)' : '(Reguler ke $city)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
              ),
              if (detailText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(detailText, style: TextStyle(fontSize: 12, color: color, fontStyle: FontStyle.italic)),
                ),
            ],
          ),
          Text(
            'Rp ${amount.abs().toStringAsFixed(0)}',
            style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Pembayaran'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(),
            _buildVoucherSection(),
            _buildPaymentSection(),
            _buildSummarySection(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment, color: Colors.white),
              label: Text(
                'Bayar Sekarang (Rp ${_checkoutData.totalFinal.toStringAsFixed(0)})',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: cartProvider.itemCount > 0 &&
                  _checkoutData.totalFinal > 0.0 &&
                  _checkoutData.selectedAddress != 'Pilih Alamat Pengiriman' &&
                  _checkoutData.paymentMethod != 'Pilih Metode Pembayaran'
                  ? _processPayment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
