import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> languages = [
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
    // AuthViewModel'e dil seçimini kaydet
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.updateUserLanguage(languageCode);

    // Seçilen dili SharedPreferences'a kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    await prefs.setBool('hasSelectedLanguage', true);

    // Daha sonra giriş ekranına yönlendir
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
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
              SizedBox(height: 40),
              // Logo veya Başlık
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
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
              SizedBox(height: 48),
              // Dil seçimi başlığı
              Text(
                'Zimanê xwe hilbijêre / Dilinizi seçin / Select your language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              // Dil seçenekleri
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
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                language['flag'],
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: 12),
                              Text(
                                language['name'],
                                style: TextStyle(
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