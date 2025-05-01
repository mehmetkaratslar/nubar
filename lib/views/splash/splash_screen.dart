// Dosya: lib/views/splash/splash_screen.dart
// Amaç: Açılış ekranı, kullanıcı durumunu kontrol eder ve yönlendirme yapar.
// Bağlantı: language_selection_screen.dart, login_screen.dart veya home_screen.dart'a yönlendirir.
// Not: Yönlendirme mantığı tekrar doğrulandı, hasSelectedLanguage kontrolü optimize edildi.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_constants.dart';

// Açılış ekranı sınıfı
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Açılış ekranı durumu
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isNavigating = false; // Yönlendirme durumunu takip eder

  // Widget başlatıldığında çalışır
  @override
  void initState() {
    super.initState();
    // Animasyon kontrolcüsü ve animasyonlar oluştur
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  // Bağımlılıklar değiştiğinde çalışır (Localizations için güvenli)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNavigating) {
      _isNavigating = true; // Tekrar tekrar yönlendirme yapmasını önler
      _navigateToNextScreen();
    }
  }

  // Widget dispose edildiğinde kaynakları temizler
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sonraki ekrana yönlendirme yapar
  Future<void> _navigateToNextScreen() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // AuthViewModel'i alır ve oturum durumunu kontrol eder
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // 2 saniye bekleyerek splash ekranının görünmesini sağlar (kullanıcı deneyimi için)
      await Future.delayed(const Duration(seconds: 2));

      // Widget'ın hala mounted olduğundan emin olun
      if (!mounted) return;

      // Dil seçimi durumunu kontrol eder
      final sharedPreferences = Provider.of<SharedPreferences>(context, listen: false);
      final hasSelectedLanguage = sharedPreferences.getBool('hasSelectedLanguage') ?? false;

      // Yönlendirme mantığı
      if (hasSelectedLanguage) {
        if (authViewModel.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/language_selection');
      }
    } catch (e) {
      // Hata durumunda kullanıcıyı bilgilendir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.generalError)),
        );
        // Hata sonrası varsayılan bir yönlendirme yap
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
    // Maksimum süre kontrolü: Eğer 5 saniye içinde yönlendirme olmazsa, varsayılan olarak /login'e yönlendir
    Timer(const Duration(seconds: 5), () {
      if (mounted && !_isNavigating) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  // Ana yapı fonksiyonu
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Arka plan: Kırmızı, beyaz, yeşil gradyan
          gradient: LinearGradient(
            colors: [
              Colors.white, // Kürt bayrağı beyaz
              AppConstants.primaryRed, // Kürt bayrağı kırmızı
              AppConstants.primaryGreen, // Kürt bayrağı yeşil
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ve animasyon
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.appName,
                      style: const TextStyle(
                        color: AppConstants.primaryRed,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppConstants.primaryYellow,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Karşılama mesajı
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  l10n.discoverKurdishCulture, // "Kürt Kültürünü Keşfedin"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Yükleme göstergesi (SpinKitFadingCircle)
              SpinKitFadingCircle(
                color: AppConstants.primaryRed, // Tema rengi yerine sabit renk
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}