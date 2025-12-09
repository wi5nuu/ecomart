import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/admin_analytics_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/transaction_provider.dart';

import 'services/data_seeder.dart';
import 'wrappers/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  await seedProducts(); // seed data awal

  runApp(const EcomartApp());
}

class EcomartApp extends StatelessWidget {
  const EcomartApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'id_ID';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // <-- diganti
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          appBarTheme: AppBarTheme(
            color: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(), // root widget sekarang aman
        routes: {
          '/registration': (_) => const RegistrationScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/cart': (_) => const CartScreen(),
          '/add-product': (_) => const AddProductScreen(),
          '/admin-analytics': (_) => const AdminAnalyticsScreen(),
        },
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
