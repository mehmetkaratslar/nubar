// lib/l10n/l10n.dart
// Çoklu dil desteği yardımcı fonksiyonları ve sabitleri
// intl ve generated/l10n.dart ile entegrasyonu sağlar

import 'package:flutter/material.dart';
import '../generated/l10n.dart';

// Desteklenen diller
class L10n {
  // Desteklenen tüm dil locale'leri
  static const List<Locale> supportedLocales = [
    Locale('ku'), // Kürtçe (Kurmancî)
    Locale('tr'), // Türkçe
    Locale('en'), // İngilizce
  ];

  // Dil kodu ile yerel isim eşleşmeleri
  static const Map<String, String> languageNames = {
    'ku': 'Kurdî (Kurmancî)',
    'tr': 'Türkçe',
    'en': 'English',
  };

  // Cihaz dilini al
  static Locale getDeviceLocale(BuildContext context) {
    final deviceLocale = Localizations.localeOf(context);

    // Desteklenen dillerde cihaz dili var mı kontrol et
    for (var locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }

    // Yoksa varsayılan dil olarak Kürtçe'yi döndür
    return const Locale('ku');
  }

  // Dil kodundan yerel isim
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'Unknown';
  }
}