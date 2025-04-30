// Dosya: lib/views/splash/splash_screen.dart
// Amaç: Açılış ekranı, kullanıcı durumunu kontrol eder ve yönlendirme yapar.
// Bağlantı: language_selection_screen.dart veya home_screen.dart’a yönlendirir.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;
  final SharedPreferences sharedPreferences;

  const SplashScreen({
    Key? key,
    required this.authService,
    required this.firestoreService,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final hasSelectedLanguage = widget.sharedPreferences.getBool('hasSelectedLanguage') ?? false;

      if (hasSelectedLanguage) {
        if (authViewModel.isAuthenticated) {
          print("Kullanıcı giriş yapmış, home ekranına yönlendiriliyor.");
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          print("Kullanıcı giriş yapmamış, login ekranına yönlendiriliyor.");
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        print("Dil seçimi yapılmamış, language_selection ekranına yönlendiriliyor.");
        Navigator.of(context).pushReplacementNamed('/language_selection');
      }
    } catch (e) {
      print("Yönlendirme sırasında hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'NÛBAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}