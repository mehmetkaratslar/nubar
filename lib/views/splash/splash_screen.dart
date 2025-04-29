// lib/views/splash/splash_screen.dart
// Purpose: Displays the initial splash screen with the app logo and navigates to the language selection screen after a delay.
// Location: lib/views/splash/
// Connection: Entry point of the app (called from main.dart), navigates to LanguageSelectionScreen.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/splash/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nûbar',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor, // Removed const
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Constants.secondaryColor, // Removed const
            ),
          ],
        ),
      ),
    );
  }
}