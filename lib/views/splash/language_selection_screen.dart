// Dosya: lib/views/splash/language_selection_screen.dart
// Amaç: Kullanıcının dil seçimi yaptığı ekran.
// Bağlantı: splash_screen.dart’tan çağrılır, login_screen.dart’a yönlendirir.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> languages = const [
    {
      'name': 'Kurdî (Kurmancî)',
      'code': 'ku',
      'flag': '🟢🔴🟡',
    },
    {
      'name': 'Türkçe',
      'code': 'tr',
      'flag': '🇹🇷',
    },
    {
      'name': 'English',
      'code': 'en',
      'flag': '🇬🇧',
    },
  ];

  Future<void> _selectLanguage(BuildContext context, String languageCode) async {
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', languageCode);
      await prefs.setBool('hasSelectedLanguage', true);
      await authViewModel.updateUserLanguage(languageCode);
      print("LanguageSelectionScreen: Dil seçildi: $languageCode, login ekranına yönlendiriliyor.");
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("LanguageSelectionScreen: Dil seçimi hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'NÛBAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Zimanê xwe hilbijêre / Dilinizi seçin / Select your language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => _selectLanguage(context, language['code']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                language['flag'],
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                language['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}