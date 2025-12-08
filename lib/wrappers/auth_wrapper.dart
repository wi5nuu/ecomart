import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

import '../screens/admin_analytics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // 1. Menunggu Firebase cek session login
    if (!auth.isAuthReady) {
      return const SplashScreen();
    }

    // 2. Jika belum login
    if (!auth.isAuthenticated || auth.currentUser == null) {
      return const LoginScreen();
    }

    // 3. User berhasil login → AKTIFKAN LISTENER TANPA MERUSAK build()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartProvider.setupCartListener();
    });

    // 4. User admin
    if (auth.currentUser!.isAdmin) {
      return const AdminAnalyticsScreen();
    }

    // 5. User biasa
    return const HomeScreen();
  }
}
