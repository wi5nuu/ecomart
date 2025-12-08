// lib/models/checkout_model.dart

// Model untuk menyimpan semua data yang diperlukan pada proses checkout
class CheckoutModel {
  // Alamat
  String selectedAddress;
  String city; // Kota, untuk perhitungan ongkir

  // Pembayaran
  String paymentMethod; // Contoh: 'Bank Transfer', 'E-Wallet', 'COD'

  // Diskon
  String voucherCode;
  double discountAmount;

  // Ongkos Kirim
  double shippingCost;

  // Item Keranjang (Data ini biasanya diambil dari CartProvider, tapi kita simpan di model untuk kelengkapan)
  double subtotal;

  CheckoutModel({
    this.selectedAddress = 'Pilih Alamat Pengiriman',
    this.city = 'Jakarta', // Default ke Jakarta untuk contoh Jabodetabek
    this.paymentMethod = 'Pilih Metode Pembayaran',
    this.voucherCode = '',
    this.discountAmount = 0.0,
    this.shippingCost = 0.0,
    required this.subtotal,
  });

  // Total Akhir (Subtotal - Diskon + Ongkir)
  double get totalFinal => subtotal - discountAmount + shippingCost;
}