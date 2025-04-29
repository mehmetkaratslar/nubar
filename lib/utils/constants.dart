// lib/utils/constants.dart
// Uygulama genelinde kullanılan sabit değerleri tanımlar

import 'package:flutter/material.dart';

// Uygulama genel bilgileri
class AppConstants {
  // Uygulama adı
  static const String appName = 'Nûbar';

  // Uygulama açıklaması
  static const String appDescription = 'Kürt Kültür Platformu';

  // Uygulama versiyon bilgisi
  static const String appVersion = '1.0.0';

  // Uygulama üreticisi
  static const String appAuthor = 'Kürt Kültür Platformu Ekibi';

  // Uygulama web sitesi
  static const String appWebsite = 'https://nubar.app';

  // Uygulama e-posta adresi
  static const String appEmail = 'info@nubar.app';

  // Sosyal medya bağlantıları
  static const String appInstagram = 'https://instagram.com/nubarapp';
  static const String appTwitter = 'https://twitter.com/nubarapp';
  static const String appFacebook = 'https://facebook.com/nubarapp';

  // Gizlilik politikası ve kullanım şartları bağlantıları
  static const String privacyPolicyUrl = 'https://nubar.app/privacy';
  static const String termsOfServiceUrl = 'https://nubar.app/terms';
}

// API ve Firebase ile ilgili sabitler
class ApiConstants {
  // Firebase collection isimleri
  static const String usersCollection = 'users';
  static const String contentsCollection = 'contents';
  static const String commentsCollection = 'comments';
  static const String reportsCollection = 'reports';

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String contentImagesPath = 'content_images';
  static const String contentVideosPath = 'content_videos';
  static const String contentAudioPath = 'content_audio';
  static const String thumbnailsPath = 'thumbnails';

  // Dosya boyutu limitleri (byte cinsinden)
  static const int maxProfileImageSize = 2 * 1024 * 1024; // 2MB
  static const int maxContentImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxContentVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxContentAudioSize = 10 * 1024 * 1024; // 10MB
}

// Uygulama renklerini tanımlar
class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFFE74C3C); // Kırmızı
  static const Color secondary = Color(0xFF2ECC71); // Yeşil
  static const Color tertiary = Color(0xFFF1C40F); // Sarı

  // Metin renkleri
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);

  // Arka plan renkleri
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFFE0E0E0);

  // Diğer renkler
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
}

// Uygulama içindeki metin boyutlarını tanımlar
class AppTextSizes {
  static const double extraSmall = 10.0;
  static const double small = 12.0;
  static const double medium = 14.0;
  static const double regular = 16.0;
  static const double large = 18.0;
  static const double extraLarge = 20.0;
  static const double title = 22.0;
  static const double heading = 24.0;
  static const double subheading = 20.0;
  static const double caption = 12.0;
}

// Uygulama içindeki boşluk ve kenar boşluğu değerlerini tanımlar
class AppSizes {
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
  static const double xxl = 48.0;

  // Kenar boşlukları
  static const EdgeInsets paddingExtraSmall = EdgeInsets.all(extraSmall);
  static const EdgeInsets paddingSmall = EdgeInsets.all(small);
  static const EdgeInsets paddingMedium = EdgeInsets.all(medium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(large);
  static const EdgeInsets paddingExtraLarge = EdgeInsets.all(extraLarge);

  // Standart ekran kenar boşluğu
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: medium);

  // Formlar için standart boşluk
  static const double formFieldSpacing = medium;

  // Buton boyutları
  static const double buttonHeight = 48.0;
  static const double iconButtonSize = 40.0;

  // Avatar boyutları
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 72.0;

  // Kart yuvarlak köşe yarıçapı
  static const double cardBorderRadius = 8.0;

  // Buton yuvarlak köşe yarıçapı
  static const double buttonBorderRadius = 8.0;
}

// Hata mesajları
class ErrorMessages {
  static const String networkError = 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
  static const String generalError = 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String authError = 'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String invalidEmail = 'Geçerli bir e-posta adresi girin.';
  static const String weakPassword = 'Şifre en az 6 karakter olmalıdır.';
  static const String passwordMismatch = 'Şifreler eşleşmiyor.';
  static const String requiredField = 'Bu alan zorunludur.';
  static const String uploadError = 'Dosya yüklenirken bir hata oluştu.';
  static const String contentLoadError = 'İçerik yüklenirken bir hata oluştu.';
  static const String contentCreateError = 'İçerik oluşturulurken bir hata oluştu.';
  static const String commentError = 'Yorum gönderilirken bir hata oluştu.';
  static const String permissionDenied = 'Bu işlemi yapmak için yetkiniz yok.';
}

// Şikayet nedenleri
class ReportReasons {
  static const Map<String, String> reasons = {
    'inappropriate': 'Uygunsuz İçerik',
    'spam': 'Spam',
    'offensive': 'Hakaret/Saldırgan İçerik',
    'violence': 'Şiddet',
    'copyright': 'Telif Hakkı İhlali',
    'other': 'Diğer',
  };
}

// Desteklenen diller
class SupportedLanguages {
  static const Map<String, String> languages = {
    'ku': 'Kurdî (Kurmancî)',
    'tr': 'Türkçe',
    'en': 'English',
  };

  // Gelecekte eklenecek diller
  static const Map<String, String> futurePlannedLanguages = {
    'ckb': 'کوردی (سۆرانی)', // Sorani
    'ar': 'العربية', // Arapça
    'de': 'Deutsch', // Almanca
    'fr': 'Français', // Fransızca
  };
}

// Uygulama içerik kategorileri
class ContentCategories {
  static const Map<String, String> categories = {
    'history': 'Tarih',
    'language': 'Dil',
    'art': 'Sanat',
    'music': 'Müzik',
    'traditions': 'Gelenekler',
  };

  // Kategori açıklamaları
  static const Map<String, String> categoryDescriptions = {
    'history': 'Kürt tarihine dair bilgiler, olaylar ve önemli kişiler.',
    'language': 'Kürtçe dil bilgisi, kelimeler, deyimler ve lehçeler.',
    'art': 'Kürt sanatı, edebiyatı, şiir ve resim.',
    'music': 'Kürt müziği, şarkıları, enstrümanları ve sanatçıları.',
    'traditions': 'Kürt kültürel gelenekleri, kutlamaları ve yaşam tarzı.',
  };

  // Kategori ikonları
  static const Map<String, IconData> categoryIcons = {
    'history': Icons.history,
    'language': Icons.language,
    'art': Icons.palette,
    'music': Icons.music_note,
    'traditions': Icons.celebration,
  };
}