// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mengubah import ke app class yang benar
import 'package:ecomart/main.dart';

void main() {
  testWidgets('Ecomart App Smoke Test', (WidgetTester tester) async {
    // Membangun app utama (EcomartApp, bukan MyApp)
    await tester.pumpWidget(const EcomartApp());

    // Verifikasi bahwa aplikasi tidak crash saat diluncurkan
    // Kita cek apakah widget MaterialApp ditemukan
    expect(find.byType(MaterialApp), findsOneWidget);

    // Karena initialRoute adalah '/registration', kita bisa cek teks pendaftaran
    // (Asumsi RegistrationScreen memiliki teks "Register" atau "Daftar")
    expect(find.text('Register'), findsOneWidget);

    // Catatan: Tes ini masih menguji boilerplate, sebaiknya ganti dengan
    // pengujian yang relevan untuk Ecomart Anda.
  });
}