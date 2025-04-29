import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/content_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/editor_viewmodel.dart';
import 'views/splash/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Paylaşılan servisleri başlat
  final firestoreService = FirestoreService();
  final authService = AuthService();

  // Paylaşılan tercih deposunu başlat
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Servisler
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<AuthService>.value(value: authService),
        Provider<SharedPreferences>.value(value: sharedPreferences),

        // ViewModeller
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authService: authService,
            firestoreService: firestoreService,
            sharedPreferences: sharedPreferences,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentViewModel(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => EditorViewModel(firestoreService: firestoreService),
        ),
      ],
      child: const NubarApp(),
    ),
  );
}

class NubarApp extends StatelessWidget {
  const NubarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nûbar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        hintColor: Constants.accentColor,
        scaffoldBackgroundColor: Constants.bgColor,
        fontFamily: 'NotoSans',
        textTheme: const TextTheme(
          headlineLarge: Constants.headingStyle,
          headlineMedium: Constants.subheadingStyle,
          titleLarge: Constants.titleStyle,
          bodyLarge: Constants.bodyStyle,
          bodySmall: Constants.captionStyle,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Constants.primaryColor,
          secondary: Constants.secondaryColor,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ku', 'TR'), // Kurmancî
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce
      ],
      home: SplashScreen(),
    );
  }
}