// Dosya: lib/app.dart
// Amaç: Uygulamanın ana widget’ı, tema ve yönlendirme ayarlarını yapar, servisleri alır.
// Bağlantı: splash_screen.dart’a yönlendirir, tüm ekranlara altyapı sağlar.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nubar/search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/app_constants.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/content/content_detail_screen.dart';
import 'views/content/content_list_screen.dart';
import 'views/editor/content_editor_screen.dart';
import 'views/editor/editor_dashboard.dart';
import 'views/home/category_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/edit_profile_screen.dart';
import 'views/profile/profile_screen.dart';

import 'views/splash/language_selection_screen.dart';
import 'views/splash/splash_screen.dart';

class App extends StatelessWidget {
  final AuthService authService;
  final FirestoreService firestoreService;
  final SharedPreferences sharedPreferences;

  const App({
    Key? key,
    required this.authService,
    required this.firestoreService,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nûbar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryRed,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          foregroundColor: AppConstants.darkGray,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryRed,
            foregroundColor: AppConstants.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryRed,
          ),
        ),
        fontFamily: 'NotoSans',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: AppConstants.darkGray,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppConstants.darkGray,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: AppConstants.darkGray,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: AppConstants.darkGray),
          bodyMedium: TextStyle(color: AppConstants.darkGray),
        ),
        colorScheme: ColorScheme.light(
          primary: AppConstants.primaryRed,
          secondary: AppConstants.primaryGreen,
          tertiary: AppConstants.primaryYellow,
        ),
      ),
      supportedLocales: const [
        Locale('ku', ''),
        Locale('tr', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (context) => SplashScreen(
                authService: authService,
                firestoreService: firestoreService,
                sharedPreferences: sharedPreferences,
              ),
            );
          case '/language_selection':
            return MaterialPageRoute(builder: (context) => const LanguageSelectionScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/content_detail':
            final contentId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ContentEditorScreen(contentId: contentId),
            );
          case '/content_list':
            final category = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ContentListScreen(category: category),
            );
          case '/category':
            final category = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => CategoryScreen(category: category),
            );
          case '/search':
            return MaterialPageRoute(builder: (context) => const SearchScreen());
          case '/profile':
            return MaterialPageRoute(builder: (context) => const ProfileScreen());
          case '/edit_profile':
            return MaterialPageRoute(builder: (context) => const EditProfileScreen());
          case '/editor_dashboard':
            return MaterialPageRoute(builder: (context) => const EditorDashboard());
          case '/content_editor':
            final contentId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => ContentEditorScreen(contentId: contentId),
            );
          default:
            return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}