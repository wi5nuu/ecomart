import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

// Inisialisasi Firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// --- DATA PRODUK CONTOH DALAM FORMAT JSON STRING ---
// >>> LAKUKAN INPUT MASSAL DI SINI: GANTI SELURUH ARRAY INI <<<
// Ganti seluruh isi di antara tanda petik tiga (''') dengan array JSON produk Anda yang berjumlah ratusan.
const String _jsonProducts = '''
[
  {
    "category": "Sepatu",
    "description": "Sepatu lari ringan untuk jarak menengah, bahan breathable. Ideal untuk lari pagi.",
    "imageUrl": "https://placehold.co/600x400/007AFF/ffffff/png?text=SEPATU+LARI",
    "name": "Sepatu Lari X-Trail",
    "price": 750000,
    "rating": 4.7,
    "reviewCount": 55,
    "stock": 20
  },
  {
    "category": "Sepatu",
    "description": "Sneakers klasik dengan desain retro 90-an. Nyaman untuk dipakai harian, sangat fashionable.",
    "imageUrl": "https://placehold.co/600x400/FF5733/ffffff/png?text=SNEAKERS",
    "name": "Sneakers Retro 90",
    "price": 499000,
    "rating": 4.5,
    "reviewCount": 120,
    "stock": 35
  },
  {
    "category": "Aksesoris",
    "description": "Smartwatch canggih dengan fitur pelacak detak jantung, GPS, dan tahan air. Pilihan tepat untuk olahraga.",
    "imageUrl": "https://placehold.co/600x400/581845/ffffff/png?text=SMARTWATCH",
    "name": "Smartwatch Ultra",
    "price": 1800000,
    "rating": 4.9,
    "reviewCount": 88,
    "stock": 15
  },
  {
    "category": "Pakaian",
    "description": "Kaos katun organik 100%, sangat nyaman dan ramah lingkungan. Tersedia berbagai ukuran.",
    "imageUrl": "https://placehold.co/600x400/00AA8D/ffffff/png?text=KAOS+ORGANIK",
    "name": "Kaos Katun Premium",
    "price": 150000,
    "rating": 4.6,
    "reviewCount": 200,
    "stock": 150
  },
  {
    "category": "Elektronik",
    "description": "Headphone wireless dengan teknologi noise cancelling terbaik di kelasnya. Baterai tahan lama.",
    "imageUrl": "https://placehold.co/600x400/C70039/ffffff/png?text=HEADPHONE+ANC",
    "name": "Headphone Bluetooth Z1",
    "price": 1250000,
    "rating": 4.8,
    "reviewCount": 92,
    "stock": 40
  },
  {
    "category": "Aksesoris",
    "description": "Tas ransel multifungsi, tahan air, cocok untuk laptop 15 inci. Desain elegan.",
    "imageUrl": "https://placehold.co/600x400/33FF57/ffffff/png?text=TAS+RANSEL",
    "name": "Ransel Travel Pro",
    "price": 550000,
    "rating": 4.4,
    "reviewCount": 60,
    "stock": 50
  },
  {
    "category": "Pakaian",
    "description": "Jaket musim dingin stylish, tahan angin dan menghangatkan. Sempurna untuk cuaca ekstrem.",
    "imageUrl": "https://placehold.co/600x400/33A2FF/ffffff/png?text=JAKET+WINTER",
    "name": "Jaket Musim Dingin Arctic",
    "price": 980000,
    "rating": 4.7,
    "reviewCount": 30,
    "stock": 25
  },
  {
    "category": "Elektronik",
    "description": "Mouse gaming presisi tinggi dengan sensitivitas DPI yang dapat diatur. Responsif dan ergonomis.",
    "imageUrl": "https://placehold.co/600x400/A233FF/ffffff/png?text=MOUSE+GAMING",
    "name": "Mouse Gaming X9",
    "price": 320000,
    "rating": 4.5,
    "reviewCount": 75,
    "stock": 60
  }
]
'''
;

// --- FUNGSI SEEDING UTAMA ---
Future<void> seedProducts() async {
  try {
    final productsCollection = _firestore.collection('products');

    // 1. Cek apakah ada data.
    final snapshot = await productsCollection.limit(1).get();

    if (snapshot.docs.isEmpty) {
      debugPrint('Data produk kosong. Memulai pengisian data awal...');
    } else {
      // Menghapus semua dokumen yang ada, termasuk data lama,
      // agar koleksi bersih sebelum data massal dimasukkan.
      debugPrint('Data produk sudah ada. Menghapus data lama sebelum seeding...');

      final existingDocs = await productsCollection.get();
      final deleteBatch = _firestore.batch();

      for (var doc in existingDocs.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
      debugPrint('Semua data produk lama telah dihapus.');
    }

    // 2. Lakukan Seeding data baru (memasukkan data dari _jsonProducts)
    final List<dynamic> productsList = json.decode(_jsonProducts);
    final batch = _firestore.batch();

    for (var productData in productsList) {
      // Tambahkan FieldValue.serverTimestamp() untuk tanggal pembuatan
      productData['createdAt'] = FieldValue.serverTimestamp();

      // Buat dokumen baru dengan ID otomatis
      final newDocRef = productsCollection.doc();
      batch.set(newDocRef, productData as Map<String, dynamic>);
    }

    // Commit semua operasi batch (cara cepat memasukkan data massal)
    await batch.commit();
    debugPrint('Pengisian data awal selesai. Ditambahkan ${productsList.length} produk.');

  } catch (e) {
    debugPrint('Gagal melakukan seeding data: $e');
  }
}