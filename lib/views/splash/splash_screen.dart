// lib/views/splash/splash_screen.dart
// Açılış ekranı
// Uygulama başlatıldığında gösterilen ilk ekran, dil seçimi ve temel bilgileri içerir

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';

// Utils
import '../../utils/constants.dart';
import '../../utils/theme.dart';

// Çoklu dil desteği
<<<<<<< HEAD
import '../../l10n/l10n.dart';
=======
import '../../generated/l10n.dart';

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

class SplashScreen extends StatefulWidget {
  // Dil seçimi için callback
  final Function(String) onLanguageSelected;

  // Seçilen dil kodu
  final String initialLanguage;

  // Constructor
  const SplashScreen({
    Key? key,
    required this.onLanguageSelected,
    required this.initialLanguage,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Yükleniyor durumu
  bool _isLoading = true;

  // Geçerli sayfa indeksi (onboarding slider için)
  int _currentPage = 0;

  // Dil seçimi yapıldı mı
  bool _languageSelected = false;

  // Seçilen dil kodu
  late String _selectedLanguage;

  // PageController (onboarding slider için)
  final PageController _pageController = PageController();

  // Onboarding sayfa sayısı
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;

    // İlk yüklenme işlemleri
    _initializeApp();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Uygulama başlangıç işlemleri
  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();

    // Dil tercihi daha önce yapılmış mı kontrol et
    final hasSelectedLanguage = prefs.containsKey('language');

    // Uygulama daha önce açılmış mı kontrol et (ilk kez açılışta onboarding göster)
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    setState(() {
      _languageSelected = hasSelectedLanguage;
      _isLoading = false;

      // Eğer onboarding daha önce görüntülendiyse, dil seçimi ekranından başla
      if (hasSeenOnboarding) {
        _currentPage = _numPages - 1;
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  // Dil seçimini kaydet
  Future<void> _saveLanguagePreference(String langCode) async {
    setState(() {
      _selectedLanguage = langCode;
      _languageSelected = true;
    });

    // Callback fonksiyonu çağır
    widget.onLanguageSelected(langCode);
  }

  // Onboarding tamamlandı, kullanıcıyı giriş ekranına yönlendir
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    // Giriş ekranına yönlendir
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Yükleniyor durumunda basit bir spinner göster
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Üst kısım: Logo ve dil seçimi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nûbar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Dil seçimi dropdown
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: AppColors.textPrimary),
                    underline: Container(
                      height: 2,
                      color: AppColors.primary,
                    ),
                    onChanged: (String? value) {
                      if (value != null) {
                        _saveLanguagePreference(value);
                      }
                    },
                    items: SupportedLanguages.languages.entries
                        .map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Orta kısım: Sayfa içeriği (onboarding veya dil seçimi)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Sayfa 1: Hoş geldiniz
                  _buildOnboardingPage(
                    title: S.of(context).welcomeToNubar,
                    description: S.of(context).discoverKurdishCulture,
                    imagePath: 'assets/images/onboarding_1.svg',
                  ),

                  // Sayfa 2: Kültürel içerik hakkında bilgi
                  _buildOnboardingPage(
                    title: S.of(context).categories,
                    description: '${S.of(context).historyDescription}\n'
                        '${S.of(context).languageDescription}\n'
                        '${S.of(context).artDescription}',
                    imagePath: 'assets/images/onboarding_2.svg',
                  ),

                  // Sayfa 3: Dil seçimi ve başlangıç
                  _buildLanguageSelectionPage(),
                ],
              ),
            ),

            // Alt kısım: Sayfa indikatörleri ve ileri/geri butonları
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri butonu (ilk sayfada gösterme)
                  _currentPage == 0
                      ? const SizedBox(width: 60)
                      : TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      S.of(context).back,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Sayfa indikatörleri
                  Row(
                    children: List.generate(
                      _numPages,
                          (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),

                  // İleri/Başla butonu
                  _currentPage != _numPages - 1
                      ? TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      S.of(context).next,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : TextButton(
                    onPressed: _languageSelected
                        ? _finishOnboarding
                        : null,
                    child: Text(
                      S.of(context).getStarted,
                      style: TextStyle(
                        color: _languageSelected
                            ? AppColors.primary
                            : AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Onboarding sayfası widget'ı
  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath,
            height: 200,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Dil seçimi sayfası widget'ı
  Widget _buildLanguageSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).selectLanguage,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),

          // Dil seçenekleri
          ...SupportedLanguages.languages.entries.map((entry) {
            return _buildLanguageOption(
              languageName: entry.value,
              languageCode: entry.key,
              isSelected: _selectedLanguage == entry.key,
            );
          }).toList(),
        ],
      ),
    );
  }

  // Dil seçeneği widget'ı
  Widget _buildLanguageOption({
    required String languageName,
    required String languageCode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _saveLanguagePreference(languageCode),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.backgroundDark,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  // Sayfa indikatörü widget'ı
  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: isCurrentPage ? 20 : 10,
      decoration: BoxDecoration(
        color: isCurrentPage ? AppColors.primary : AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}