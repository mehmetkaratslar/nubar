// Dosya: lib/utils/app_constants.dart
// Amaç: Uygulama genelinde kullanılan sabit değerleri tanımlar (renkler, boyutlar, kategoriler, dil kodları, roller, olay isimleri).
// Bağlantı: Tüm ekranlar, ViewModel'ler ve servislerde kullanılır (örneğin, login_screen.dart, home_viewmodel.dart).
// Not: constants.dart ile birleştirildi, kategoriler AppLocalizations ile çevrildi.

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';


// Sabit değerleri içeren sınıf
class AppConstants {
  // Renk sabitleri
  static const Color primaryRed = Color(0xFFEF5350); // Birincil kırmızı renk
  static const Color primaryGreen = Color(0xFF66BB6A); // Birincil yeşil renk
  static const Color primaryYellow = Color(0xFFFFCA28); // Birincil sarı renk
  static const Color backgroundColor = Color(0xFFF5F5F5); // Arka plan rengi
  static const Color lightGray = Color(0xFFE0E0E0); // Açık gri renk
  static const Color darkGray = Color(0xFF616161); // Koyu gri renk

  // Boyut sabitleri
  static const double spacingSmall = 8.0; // Küçük boşluk
  static const double spacingMedium = 16.0; // Orta boşluk
  static const double spacingLarge = 24.0; // Büyük boşluk
  static const double cardBorderRadius = 12.0; // Kart kenar yuvarlama
  static const double buttonHeight = 48.0; // Buton yüksekliği

  // Kategoriler (AppLocalizations ile çevrilecek)
  static List<String> getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.all, // Tümü
      l10n.history, // Tarih
      l10n.language, // Dil
      l10n.art, // Sanat
      l10n.music, // Müzik
      l10n.traditions, // Gelenekler
    ];
  }

  // Dil kodları
  static const String languageKurdishKur = 'ku'; // Kürtçe (Kurmanci)
  static const String languageTurkish = 'tr'; // Türkçe
  static const String languageEnglish = 'en'; // İngilizce

  // Kullanıcı rolleri
  static const String roleUser = 'normal'; // Normal kullanıcı
  static const String roleEditor = 'editor'; // Editör
  static const String roleAdmin = 'admin'; // Yönetici

  // Analitik olay isimleri
  static const String eventScreenView =
      'screen_view'; // Ekran görüntüleme olayı
  static const String eventLogin = 'login'; // Giriş olayı
  static const String eventSignUp = 'sign_up'; // Kayıt olayı
  static const String eventContentCreate =
      'content_create'; // İçerik oluşturma olayı
  static const String eventContentLike = 'content_like'; // İçerik beğenme olayı
  static const String eventCommentAdd = 'comment_add'; // Yorum ekleme olayı
}
