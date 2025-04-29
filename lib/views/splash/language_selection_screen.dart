// lib/views/splash/language_selection_screen.dart
// Purpose: Allows the user to select their preferred language on first app launch.
// Location: lib/views/splash/
// Connection: Navigates to HomeScreen after language selection.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/home/home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.darkGray,
              ),
            ),
            const SizedBox(height: 40),
            _buildLanguageButton(context, 'Kurdish (Kurmanji)', 'ku'),
            const SizedBox(height: 20),
            _buildLanguageButton(context, 'Turkish', 'tr'),
            const SizedBox(height: 20),
            _buildLanguageButton(context, 'English', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String language, String locale) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        language, // Corrected: 'language' is a String parameter
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}