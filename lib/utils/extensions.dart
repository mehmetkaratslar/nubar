// Dosya: lib/utils/extensions.dart
// Amaç: String, DateTime, File sınıflarına ek işlevsellik katar.
// Bağlantı: StorageService, ContentCard gibi bileşenlerde kullanılır.
// Not: Kullanılmayan metotlar kaldırıldı, dosya türü kontrolü genişletildi.

import 'dart:io';
import 'package:intl/intl.dart';

// String sınıfına genişletmeler
extension StringExtension on String {
  // İlk harfi büyük yapar
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  // Tarih formatına çevirir
  String toDateTime({String format = 'dd/MM/yyyy HH:mm'}) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(format).format(date);
    } catch (e) {
      return this; // Hata durumunda orijinal string'i döndür
    }
  }

  // E-posta formatını kontrol eder
  bool isValidEmail() {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(this);
  }
}

// DateTime sınıfına genişletmeler
extension DateTimeExtension on DateTime {
  // Tarih formatına çevirir
  String formatDate({String format = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(format).format(this);
  }

  // Bugünden önceki gün sayısını hesaplar
  int daysAgo() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

// File sınıfına genişletmeler
extension FileExtension on File {
  // Dosyanın resim dosyası olup olmadığını kontrol eder
  bool isImageFile() {
    final extension = path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.gif') ||
        extension.endsWith('.bmp');
  }

  // Dosyanın video dosyası olup olmadığını kontrol eder
  bool isVideoFile() {
    final extension = path.toLowerCase();
    return extension.endsWith('.mp4') ||
        extension.endsWith('.mov') ||
        extension.endsWith('.avi') ||
        extension.endsWith('.mkv');
  }

  // Dosya boyutunu MB cinsinden döndürür
  double getSizeInMB() {
    final bytes = lengthSync();
    return bytes / (1024 * 1024);
  }
}
