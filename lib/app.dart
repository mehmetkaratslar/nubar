// Dosya: lib/app.dart
// Amaç: Uygulamanın ana yapısını ve navigasyonunu yönetir.
// Bağlantı: main.dart üzerinden çağrılır, tüm ekranlarla entegre çalışır.
// Not: Import'lar netleştirildi, ProfileScreen ve EditProfileScreen çakışmaları düzeltildi.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';
import 'utils/app_constants.dart';
import 'views/home/home_screen.dart';
import 'views/search/search_screen.dart';
import 'views/editor/content_editor_screen.dart';
import 'views/notifications/notifications_screen.dart';
import 'views/profile/profile_screen.dart' as profile; // ProfileScreen için alias
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/splash/splash_screen.dart';
import 'views/splash/language_selection_screen.dart';
import 'views/content/content_detail_screen.dart';
import 'views/content/content_list_screen.dart';
import 'views/home/category_screen.dart';
import 'views/profile/edit_profile_screen.dart' as editProfile; // EditProfileScreen için alias

// Uygulamanın ana widget'ı
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0; // Alt navigasyon çubuğu için seçili sekme indeksi
  late List<Widget> _screens; // Ekranlar listesi
  Locale? _locale; // Dinamik locale
  bool _isLoading = true; // Yükleme durumu

  @override
  void initState() {
    super.initState();
    // Ekranlar listesi, her sekme için bir ekran
    _screens = [
      const HomeScreen(),
      const SearchScreen(),
      const ContentEditorScreen(),
      const NotificationsScreen(),
      const profile.EditProfileScreen(), // Alias ile ProfileScreen kullanıldı
    ];
    // Locale'i yükle
    _loadLocale();
  }

  // Kullanıcı dil tercihini yükle
  Future<void> _loadLocale() async {
    final sharedPreferences = Provider.of<SharedPreferences>(context, listen: false);
    final languageCode = sharedPreferences.getString('languageCode') ?? 'tr'; // Varsayılan dil Türkçe
    setState(() {
      _locale = Locale(languageCode);
      _isLoading = false;
    });
  }

  // Sekme değişimini yönetir
  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Nûbar',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale, // Dinamik locale
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/language_selection': (context) => const LanguageSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/content_editor': (context) => const ContentEditorScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const profile.EditProfileScreen(), // Alias ile ProfileScreen kullanıldı
        '/edit_profile': (context) => const editProfile.EditProfileScreen(), // Alias ile EditProfileScreen kullanıldı
        '/content_detail': (context) => ContentDetailScreen(
          contentId: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/content_list': (context) => ContentListScreen(
          category: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/category': (context) => CategoryScreen(
          category: ModalRoute.of(context)!.settings.arguments as String,
        ),
      },
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          if (l10n == null) {
            return const Scaffold(
              body: Center(
                child: Text('Localization failed to load'),
              ),
            );
          }
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavBarTapped,
              selectedItemColor: AppConstants.primaryRed,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: l10n.homeLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  label: l10n.searchLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.add_box),
                  label: l10n.createLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications),
                  label: l10n.notificationsLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: l10n.profile,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}