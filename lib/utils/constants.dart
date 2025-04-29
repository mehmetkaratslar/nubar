import 'package:flutter/material.dart';

class Constants {
  // Ana Tema Renkleri
  static const Color primaryColor = Color(0xFFE74C3C); // Kırmızı
  static const Color secondaryColor = Color(0xFF2ECC71); // Yeşil
  static const Color accentColor = Color(0xFFF1C40F); // Sarı

  // Nötr Renkler
  static const Color bgColor = Colors.white;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF333333);
  static const Color textColor = Color(0xFF333333);
  static const Color subtextColor = Color(0xFF666666);

  // Kategori Renkleri
  static const Color historyColor = Color(0xFFC0392B); // Koyu kırmızı
  static const Color languageColor = Color(0xFF27AE60); // Koyu yeşil
  static const Color artColor = Color(0xFFE67E22); // Turuncu
  static const Color musicColor = Color(0xFF8E44AD); // Mor
  static const Color traditionColor = Color(0xFF2980B9); // Mavi

  // Metin Stilleri
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: subtextColor,
  );

  // Paddings
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Radii
  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 16.0;

  // Kategoriler
  static const String historyCategory = "Tarih";
  static const String languageCategory = "Dil";
  static const String artCategory = "Sanat";
  static const String musicCategory = "Müzik";
  static const String traditionCategory = "Gelenekler";

  // Kategori açıklamaları
  static const String historyCategoryDesc = "Kürt tarihini keşfedin";
  static const String languageCategoryDesc = "Kürtçe dilini öğrenin";
  static const String artCategoryDesc = "Kürt sanatını inceleyin";
  static const String musicCategoryDesc = "Kürt müziğini dinleyin";
  static const String traditionCategoryDesc = "Kürt geleneklerini tanıyın";

  // Kategori ikonları (Material ikonu adları)
  static const IconData historyIcon = Icons.history;
  static const IconData languageIcon = Icons.translate;
  static const IconData artIcon = Icons.palette;
  static const IconData musicIcon = Icons.music_note;
  static const IconData traditionIcon = Icons.local_florist;

  // Firebase koleksiyon adları
  static const String usersCollection = "users";
  static const String contentsCollection = "contents";
  static const String commentsCollection = "comments";
  static const String likesCollection = "likes";
  static const String savedCollection = "saved";
  static const String categoriesCollection = "categories";

  // Şifrelenmiş tercihler için anahtarlar
  static const String prefUserId = "user_id";
  static const String prefUserName = "user_name";
  static const String prefUserEmail = "user_email";
  static const String prefUserRole = "user_role";
  static const String prefLanguage = "app_language";

  // Dil kodları
  static const String languageKurdishKur = "ku-KMR"; // Kurmanci
  static const String languageKurdishSor = "ku-SOR"; // Sorani
  static const String languageTurkish = "tr";
  static const String languageEnglish = "en";

  // Kullanıcı rolleri
  static const String roleUser = "user";
  static const String roleEditor = "editor";
  static const String roleAdmin = "admin";

  // Varsayılan avatar URL'si
  static const String defaultAvatarUrl = "https://firebasestorage.googleapis.com/v0/b/nubar-app.appspot.com/o/default%2Fdefault_avatar.png?alt=media";

  // Varsayılan içerik resmi URL'si
  static const String defaultContentImageUrl = "https://firebasestorage.googleapis.com/v0/b/nubar-app.appspot.com/o/default%2Fdefault_content.png?alt=media";

  // Kategori görsel varlıkları
  static const String historyCategoryImageAsset = "assets/images/category_history.jpg";
  static const String languageCategoryImageAsset = "assets/images/category_language.jpg";
  static const String artCategoryImageAsset = "assets/images/category_art.jpg";
  static const String musicCategoryImageAsset = "assets/images/category_music.jpg";
  static const String traditionCategoryImageAsset = "assets/images/category_tradition.jpg";
}