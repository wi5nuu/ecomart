// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart'; // <<< PENTING: Impor CartProvider
import 'cart_screen.dart'; // <<< PENTING: Impor CartScreen untuk Navigasi

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  // Widget untuk membuat ikon keranjang dengan badge counter
  Widget _buildCartIcon(BuildContext context) {
    // Menggunakan Consumer agar icon bisa otomatis update
    return Consumer<CartProvider>(
      builder: (_, cart, ch) => Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Navigasi ke CartScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
          // Badge Counter (Hanya Tampil jika ada item)
          if (cart.itemCount > 0)
            Positioned(
              right: 0,
              top: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  cart.itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cari produk berdasarkan ID dari provider
    final productProvider = Provider.of<ProductProvider>(context);
    final ProductModel? product = productProvider.getProductById(productId);

    // Ambil instance CartProvider (gunakan listen: false karena hanya untuk memanggil metode)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Produk'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Produk tidak ditemukan atau belum dimuat.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  productProvider.fetchProducts();
                  Navigator.pop(context);
                },
                child: const Text('Muat Ulang Produk'),
              )
            ],
          ),
        ),
      );
    }

    // --- Tampilan Detail Produk ---
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            actions: [
              _buildCartIcon(context), // <<< TAMBAHKAN IKON KERANJANG DI SINI
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.name,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                ),
              ),
              background: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Harga dan Kategori
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.red[700],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),

                      // Rating & Stok
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount} Ulasan)',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(fontSize: 16, color: product.stock > 10 ? Colors.green : Colors.orange),
                          ),
                        ],
                      ),
                      const Divider(height: 30),

                      // Deskripsi
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Tombol mengambang di bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol Chat
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal, size: 30),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat dengan Penjual')));
              },
            ),
            const SizedBox(width: 16),
            // Tombol Tambah Keranjang
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text('Tambah ke Keranjang', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: product.stock > 0 ? () {
                  // !!! PERBAIKAN PENTING: Memanggil CartProvider.addItem()
                  cartProvider.addItem(product);

                  // Tampilkan konfirmasi
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} berhasil ditambahkan ke keranjang!'),
                        duration: const Duration(seconds: 1),
                      )
                  );
                } : null, // Disable jika stok 0
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.stock > 0 ? Colors.orange : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}