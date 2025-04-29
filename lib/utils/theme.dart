// lib/utils/theme.dart
// Amaç: Uygulamanın temasını (açık tema) renk paletiyle tanımlar.
// Konum: lib/utils/
// Bağlantı: main.dart dosyasında içe aktarılır ve uygulamanın görsel stilini belirler.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart'; // Renkleri constants.dart dosyasından içe aktarır

class AppTheme {
  // Nubar uygulaması için açık tema yapılandırması
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Constants.primaryColor,
      scaffoldBackgroundColor: Constants.backgroundColor,
      colorScheme: ColorScheme.light(
        primary: Constants.primaryColor,
        secondary: Constants.secondaryColor,
        surface: Constants.lightGray,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Constants.darkGray,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Constants.primaryColor,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Constants.darkGray,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Constants.darkGray,
        ),
      ),
      fontFamily: 'NotoSans', // Font ailesi burada tanımlı
    );
  }
}