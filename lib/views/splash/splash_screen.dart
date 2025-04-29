import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
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
    // 2 saniye bekle
    await Future.delayed(Duration(seconds: 2));

    // Dil seçimi yapılmış mı kontrol et
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedLanguage = prefs.getBool('hasSelectedLanguage') ?? false;

    if (!mounted) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (hasSelectedLanguage) {
      // Dil seçimi yapılmış, auth durumunu kontrol et
      if (authViewModel.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } else {
      // Dil seçimi yapılmamış
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LanguageSelectionScreen()),
      );
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
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
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
            SizedBox(height: 24),
            // Yükleniyor göstergesi
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}