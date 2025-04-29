// lib/app.dart
// Uygulamanın ana widget'ını ve temel yapısını tanımlar
// Tema, rota yönetimi ve uygulama genelindeki davranışları içerir

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';

// Views
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/content/content_detail_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/editor/editor_dashboard.dart';
import 'views/editor/content_editor_screen.dart';

// Utils
import 'utils/theme.dart';
import 'utils/constants.dart';

// Çoklu dil desteği
import 'generated/l10n.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Seçilen dil kodu (varsayılan: Kürtçe)
  String _selectedLanguage = 'ku';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Kullanıcının dil tercihini SharedPreferences'dan yükle
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');

    if (savedLanguage != null) {
      setState(() {
        _selectedLanguage = savedLanguage;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kullanıcının dil tercihini güncelle ve SharedPreferences'e kaydet
  Future<void> _updateLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading durumunda basit bir yükleniyor göster
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // AuthViewModel durumunu izle
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return MaterialApp(
          // Uygulama başlığı
          title: 'Nûbar - Kürt Kültür Platformu',

          // Hata ayıklama banner'ını gizle
          debugShowCheckedModeBanner: false,

          // Uygulama teması - utils/theme.dart içinde tanımlanmış
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Sistem temasını kullan

          // Çoklu dil desteği
          locale: Locale(_selectedLanguage),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          // Rota yönetimi
          initialRoute: '/',
          onGenerateRoute: (settings) {
            // Rota parametrelerini kontrol et
            final args = settings.arguments as Map<String, dynamic>? ?? {};

            // Rotaları tanımla
            switch (settings.name) {
              case '/':
              // Uygulama başlangıcı - Splash ekranı (Dil seçimi içerir)
                return MaterialPageRoute(
                  builder: (_) => SplashScreen(
                    onLanguageSelected: _updateLanguage,
                    initialLanguage: _selectedLanguage,
                  ),
                );

              case '/login':
              // Giriş ekranı
                return MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                );

              case '/register':
              // Kayıt ekranı
                return MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                );

              case '/home':
              // Ana sayfa
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                );

              case '/content':
              // İçerik detay sayfası
                return MaterialPageRoute(
                  builder: (_) => ContentDetailScreen(
                    contentId: args['contentId'] as String,
                  ),
                );

              case '/profile':
              // Profil sayfası
                return MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: args['userId'] as String? ?? authViewModel.currentUser?.uid ?? '',
                  ),
                );

              case '/editor/dashboard':
              // Editör paneli - Oturum doğrulama ve rol kontrolü
                if (authViewModel.isLoggedIn &&
                    authViewModel.userRole == UserRole.editor) {
                  return MaterialPageRoute(
                    builder: (_) => const EditorDashboard(),
                  );
                } else {
                  // Yetkisi olmayan kullanıcıları ana sayfaya yönlendir
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                }

              case '/editor/content':
              // İçerik düzenleme sayfası - Oturum doğrulama ve rol kontrolü
                if (authViewModel.isLoggedIn &&
                    authViewModel.userRole == UserRole.editor) {
                  return MaterialPageRoute(
                    builder: (_) => ContentEditorScreen(
                      contentId: args['contentId'] as String?,
                    ),
                  );
                } else {
                  // Yetkisi olmayan kullanıcıları ana sayfaya yönlendir
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                }

              default:
              // Geçersiz rotaları ana sayfaya yönlendir
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                );
            }
          },

          // Kullanıcının oturum durumuna göre başlangıç sayfasını belirle
          home: authViewModel.isLoggedIn
              ? const HomeScreen()  // Oturum açılmışsa ana sayfa
              : const SplashScreen(), // Oturum açılmamışsa splash ekranı
        );
      },
    );
  }
}