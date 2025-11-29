// lib/main.dart
import 'package:flutter/material.dart';

// Pages
import 'pages/main.dart';                     // BNav
import 'pages/tanya_ai/tanya_ai_page.dart';
import 'pages/keuangan/keuangan_page.dart';
import 'pages/kepala_cabang/kepala_cabang_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/create_account_page.dart';
import 'pages/splash/splash_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Initial route (ubah sesuai kebutuhan)
      initialRoute: '/splash',

      routes: {
        // MAIN
        '/': (context) => const BNav(),

        // SUB PAGES (Akses langsung)
        '/tanya-ai': (context) => const TanyaAiPage(),
        '/keuangan': (context) => const KeuanganPage(),
        '/kepala-cabang': (context) => const KepalaCabangPage(),
        '/profile': (context) => const ProfilePage(),

        // AUTH
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountPage(),

        // SPLASH / LOADING
        '/splash': (context) => const SplashPage(),
      },
    );
  }
}
