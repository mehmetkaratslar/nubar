// lib/main.dart
// Purpose: Entry point of the Nubar app, initializes Firebase and runs the app.
// Location: lib/
// Connection: Sets up the app's theme, localization, and navigates to SplashScreen.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nubar/firebase_options.dart';
import 'package:nubar/views/splash/splash_screen.dart'; // Updated import path
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nubar/utils/constants.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nûbar',
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        scaffoldBackgroundColor: Constants.backgroundColor,
        fontFamily: 'NotoSans',
      ),
      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ku', ''), // Kurdish (Kurmanji)
        Locale('tr', ''), // Turkish
      ],
      home: const SplashScreen(),
    );
  }
}