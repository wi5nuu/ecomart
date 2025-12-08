
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Controller untuk animasi fade-in (durasi 1.5 detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Setup Animasi Opacity dari 0.0 ke 1.0
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // 3. Mulai animasi
    _controller.forward();

    // PENTING: Future.delayed untuk navigasi telah DIHAPUS.
    // Tugas navigasi sekarang sepenuhnya dikendalikan oleh AuthWrapper 
    // setelah status otentikasi Firebase siap.
  }

  @override
  void dispose() {
    // Pastikan controller di-dispose untuk mencegah memory leak
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan Image.asset untuk logo kustom lokal Ecomart
              // Pastikan Anda sudah membuat folder assets/images/ dan menambahkan file ecomart_logo.png
              Image.asset(
                'assets/images/ecomart_logo.png', // Pastikan path ini sesuai
                height: 150,
                width: 150,
                // Fallback visual jika file gambar tidak ditemukan
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.shopping_bag,
                    size: 150,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Ecomart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Indikator loading
              const CircularProgressIndicator(color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
