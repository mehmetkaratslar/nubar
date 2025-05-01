//Dosya:theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Renk Paleti
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryYellow = Color(0xFFF1C40F);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);

  // Ana Tema
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: white,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      foregroundColor: darkGrey,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryRed,
      ),
    ),
    fontFamily: 'NotoSans',
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: darkGrey,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: darkGrey,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: darkGrey,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: darkGrey),
      bodyMedium: TextStyle(color: darkGrey),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryRed,
      secondary: primaryGreen,
      tertiary: primaryYellow,
    ),
  );
}
