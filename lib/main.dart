// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'pages/main.dart';
import 'pages/profile/profile_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/product/product_page.dart';
import 'pages/pembelian/pembelian_page.dart';

// Auth Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/create_account_page.dart';
import 'pages/auth/forgot_password_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      theme: ThemeData(
        fontFamily: GoogleFonts.lora().fontFamily,
        textTheme: GoogleFonts.loraTextTheme(),
        useMaterial3: true,
      ),

      routes: {
        '/': (context) => const BNav(),
        '/splash': (context) => const SplashPage(),
        '/profile': (context) => const ProfilePage(),
        '/product': (context) => const ProductPage(),
        '/pembelian': (context) => const PembelianPage(),

        // Auth
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
