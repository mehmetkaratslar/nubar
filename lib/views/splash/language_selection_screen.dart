// Dosya: lib/views/splash/language_selection_screen.dart
// Amaç: Kullanıcıya dil seçimi yaptırır ve seçimi kaydeder.
// Bağlantı: splash_screen.dart üzerinden çağrılır, login_screen.dart veya home_screen.dart'a yönlendirir.
// Not: Dil seçimi ve yönlendirme mantığı optimize edildi.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Varsayılan dil olarak 'tr' (Türkçe) seçiliyor
    _selectedLanguage = 'tr';
  }

  // Dil seçimini kaydeder ve yönlendirme yapar
  Future<void> _saveLanguageAndNavigate() async {
    if (_selectedLanguage == null) return;

    // SharedPreferences ile dil seçimini kaydet
    final sharedPreferences = Provider.of<SharedPreferences>(context, listen: false);
    await sharedPreferences.setString('languageCode', _selectedLanguage!);
    await sharedPreferences.setBool('hasSelectedLanguage', true);

    // AuthViewModel'i alır ve oturum durumunu kontrol eder
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Yönlendirme mantığı
    if (authViewModel.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppConstants.primaryRed,
              AppConstants.primaryGreen,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlık
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Dil seçenekleri
                _buildLanguageOption(l10n.english, 'en'),
                const SizedBox(height: 16),
                _buildLanguageOption(l10n.turkish, 'tr'),
                const SizedBox(height: 16),
                _buildLanguageOption(l10n.kurdishKurmanji, 'ku'),
                const SizedBox(height: 32),
                // Devam et butonu
                ElevatedButton(
                  onPressed: _saveLanguageAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.getStarted,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dil seçeneği için yardımcı widget
  Widget _buildLanguageOption(String languageName, String languageCode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedLanguage == languageCode
              ? AppConstants.primaryYellow.withOpacity(0.3)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedLanguage == languageCode
                ? AppConstants.primaryYellow
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            if (_selectedLanguage == languageCode)
              const Icon(
                Icons.check_circle,
                color: AppConstants.primaryYellow,
              ),
          ],
        ),
      ),
    );
  }
}