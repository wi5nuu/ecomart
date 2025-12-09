import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

import '../screens/admin_analytics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _cartListenerInitialized = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // 1. Menunggu Firebase cek session login
    if (!auth.isAuthReady) {
      return const SplashScreen();
    }

    // 2. BELUM LOGIN → langsung ke LoginScreen
    if (!auth.isAuthenticated || auth.currentUser == null) {
      // Hentikan listener cart lama
      cartProvider.clearCart();
      _cartListenerInitialized = false;
      return const LoginScreen();
    }

    // 3. SUDAH LOGIN → setup cart listener sekali saja
    if (!_cartListenerInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cartListenerInitialized = true;
      });
    }

    // 4. Admin
    if (auth.isAdmin) {
      return const AdminAnalyticsScreen();
    }

    // 5. User biasa
    return const HomeScreen();
  }
}
