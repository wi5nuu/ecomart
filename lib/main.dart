import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

// Firebase Config
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/admin_analytics_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/transaction_provider.dart';

// Seeder
import 'services/data_seeder.dart';

// Import AuthWrapper (pindahkan ke file terpisah atau biarkan di sini)
import 'wrappers/auth_wrapper.dart';
// Asumsi AuthWrapper dipindahkan ke 'wrappers/auth_wrapper.dart'
// Jika AuthWrapper tetap di main.dart, hapus baris import di atas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error atau sudah inisialisasi: $e");
  }

  // Isi data produk awal
  await seedProducts();

  runApp(const EcomartApp());
}

class EcomartApp extends StatelessWidget {
  const EcomartApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'id_ID';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Ecomart',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Inter',
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          appBarTheme: AppBarTheme(
            color: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
        ),

        // 1. UBAH TITIK MASUK UTAMA MENJADI AUTHWRAPPER!
        // AuthWrapper akan menampilkan SplashScreen saat loading.
        home: const AuthWrapper(),

        // Rute yang tersisa
        routes: {
          // Tidak perlu lagi rute '/wrapper' karena ia adalah home.
          '/registration': (context) => const RegistrationScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/add-product': (context) => const AddProductScreen(),
          '/admin-analytics': (context) => const AdminAnalyticsScreen(),
        },

        // Screen dengan argument
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: productId),
            );
          }
          return null;
        },
      ),
    );
  }
}
// PENTING: Pindahkan AuthWrapper ke file lib/wrappers/auth_wrapper.dart
// atau biarkan di sini jika Anda lebih suka (walaupun lebih rapi jika dipindah).
// Saya akan asumsikan AuthWrapper tetap berada di file lib/wrappers/auth_wrapper.dart
/*============================================
            AUTH WRAPPER (DELETED FROM MAIN.DART)
=============================================*/