// Dosya: lib/utils/app_constants.dart
// Amaç: Uygulama genelinde kullanılan sabit değerleri tanımlar (renkler, kategoriler, boyutlar).
// Bağlantı: app.dart, home_screen.dart, category_screen.dart gibi dosyalarda kullanılır.
import 'package:flutter/material.dart';

class AppConstants {
  // Renk paleti
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryYellow = Color(0xFFF1C40F);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  // Kategoriler
  static const List<String> categories = [
    'Tümü',
    'Tarih',
    'Dil',
    'Sanat',
    'Müzik',
    'Gelenekler',
  ];

  // Kategori ikonları
  static const Map<String, IconData> categoryIcons = {
    'Tarih': Icons.history,
    'Dil': Icons.language,
    'Sanat': Icons.brush,
    'Müzik': Icons.music_note,
    'Gelenekler': Icons.people,
  };

  // Boyutlar
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double textLarge = 18.0;
}