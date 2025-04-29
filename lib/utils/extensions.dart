// lib/utils/extensions.dart
// Extension metodları
// Mevcut sınıfları genişleten çeşitli yardımcı metodlar

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
// String extension metotları
extension StringExtension on String {
  // Metnin ilk harfini büyük yap
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Her kelimenin ilk harfini büyük yap
  String capitalizeEachWord() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalizeFirst()).join(' ');
  }

  // Metni kısalt ve sonuna ... ekle
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  // Metni güvenli bir URL parçasına dönüştür (slug)
  String toSlug() {
    var result = toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Özel karakterleri kaldır
        .replaceAll(RegExp(r'\s+'), '-'); // Boşlukları tire ile değiştir

    // Türkçe karakterleri dönüştür
    result = result
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('İ', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('Ç', 'c');

    // Başlangıç ve sondaki tireleri kaldır
    return result.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // HTML etiketlerini temizle
  String stripHtml() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // String'i bool değere dönüştür
  bool toBool() {
    return toLowerCase() == 'true' || toLowerCase() == '1';
  }

  // String'i enum değerine dönüştür
  T? toEnum<T extends Enum>(List<T> values) {
    try {
      return values.firstWhere((element) => element.name == this);
    } catch (_) {
      return null;
    }
  }

  // String'i "timeago" formatında göster
  String toTimeAgo() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'az önce';
    }
  }
}

// DateTime extension metotları
extension DateTimeExtension on DateTime {
  // Tarih formatı: 2023-01-15
  String toYMD() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  // Tarih formatı: 15.01.2023
  String toDMY() {
    return DateFormat('dd.MM.yyyy').format(this);
  }

  // Tarih formatı: 15 Ocak 2023
  String toFullDate() {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(this);
  }

  // Tarih ve saat formatı: 15.01.2023 14:30
  String toDateTime() {
    return DateFormat('dd.MM.yyyy HH:mm').format(this);
  }

  // Saat formatı: 14:30
  String toTime() {
    return DateFormat('HH:mm').format(this);
  }

  // İki tarih arasındaki farkı hesapla
  String timeDifference() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'az önce';
    }
  }

  // Aynı gün mü kontrol et
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Bugün mü kontrol et
  bool isToday() {
    final now = DateTime.now();
    return isSameDay(now);
  }

  // Dün mü kontrol et
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  // Yarın mı kontrol et
  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }
}

// File extension metotları
extension FileExtension on File {
  // Dosya boyutunu insan tarafından okunabilir formatta döndür
  String getFileSizeString() {
    int size = lengthSync();
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var suffixIndex = 0;

    while (size > 1024 && suffixIndex < suffixes.length - 1) {
      size = size ~/ 1024;
      suffixIndex++;
    }

    return '$size ${suffixes[suffixIndex]}';
  }

  // Dosya uzantısını al
  String getExtension() {
    return path.split('.').last.toLowerCase();
  }

  // Dosya türünü kontrol et
  bool isImageFile() {
    final ext = getExtension();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext);
  }

  bool isVideoFile() {
    final ext = getExtension();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  bool isAudioFile() {
    final ext = getExtension();
    return ['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(ext);
  }

  bool isDocumentFile() {
    final ext = getExtension();
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'ppt', 'pptx', 'xls', 'xlsx'].contains(ext);
  }
}

// Context extension metotları
extension ContextExtension on BuildContext {
  // Ekran boyutları
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Ekran Yönü (dikey/yatay)
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  // Tema ve Renkler
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Tema modu (aydınlık/karanlık)
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Navigasyon
  void pop<T>([T? result]) => Navigator.pop(this, result);

  Future<T?> push<T>(Route<T> route) => Navigator.push(this, route);

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamed<T>(this, routeName, arguments: arguments);

  Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments, TO? result}) =>
      Navigator.pushReplacementNamed<T, TO>(this, routeName, arguments: arguments, result: result);

  Future<T?> pushNamedAndRemoveUntil<T>(String routeName, RoutePredicate predicate, {Object? arguments}) =>
      Navigator.pushNamedAndRemoveUntil<T>(this, routeName, predicate, arguments: arguments);

  // SnackBar gösterme
  void showSnackBar(String message, {Color? backgroundColor, Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // Success SnackBar
  void showSuccessSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  // Error SnackBar
  void showErrorSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  // Info SnackBar
  void showInfoSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  // Dialog gösterme
  Future<T?> showAppDialog<T>({
    required String title,
    required String content,
    String? cancelText,
    String confirmText = 'Tamam',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Onay Dialogu gösterme
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String cancelText = 'İptal',
    String confirmText = 'Onayla',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Loading Dialog gösterme
  Future<void> showLoadingDialog({String message = 'Yükleniyor...'}) {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Klavyeyi kapat
  void hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

// Sayı extension metotları
extension NumExtension on num {
  // Sayıyı para birimine dönüştür
  String toCurrency({String symbol = '₺', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  // Sayıyı formatlı göster (1000 -> 1.000)
  String toFormatted({int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('tr_TR')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(this);
  }

  // Sayıyı yüzde formatına dönüştür
  String toPercentage({int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern('tr_TR')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(this / 100);
  }

  // Küsüratları sınırla
  double toFixedDouble(int fractionDigits) {
    final mod = pow(10, fractionDigits).toDouble();
    return (this * mod).round() / mod;
  }
}

// List extension metotları
extension ListExtension<T> on List<T> {
  // Listeyi gruplandır
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    return fold<Map<K, List<T>>>(
      {},
          (map, element) {
        final key = keyFunction(element);
        if (!map.containsKey(key)) {
          map[key] = [];
        }
        map[key]!.add(element);
        return map;
      },
    );
  }

  // Listeyi karıştır
  List<T> shuffled() {
    final List<T> result = List.from(this);
    result.shuffle();
    return result;
  }

  // Listeden rastgele eleman seç
  T? randomOrNull() {
    if (isEmpty) return null;
    return this[Random().nextInt(length)];
  }

  // Listeden benzersiz elemanları al
  List<T> distinct() {
    return toSet().toList();
  }

  // Listeyi eşsiz elemanlarla filtrele
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final Set<K> seenKeys = {};
    return where((element) {
      final key = keySelector(element);
      if (seenKeys.contains(key)) {
        return false;
      }
      seenKeys.add(key);
      return true;
    }).toList();
  }
}

// Map extension metotları
extension MapExtension<K, V> on Map<K, V> {
  // Map'i tersine çevir (key -> value, value -> key)
  Map<V, K> get reversed {
    return Map<V, K>.fromEntries(
      entries.map((e) => MapEntry(e.value, e.key)),
    );
  }

  // Mapin değerlerini filtrele
  Map<K, V> filterValues(bool Function(V) predicate) {
    return Map<K, V>.fromEntries(
      entries.where((e) => predicate(e.value)),
    );
  }

  // Mapin anahtarlarını filtrele
  Map<K, V> filterKeys(bool Function(K) predicate) {
    return Map<K, V>.fromEntries(
      entries.where((e) => predicate(e.key)),
    );
  }
}

// Enum extension metotları
extension EnumExtension on Enum {
  // Enum adını büyük harfle başlat
  String get capitalized {
    return name.capitalizeFirst();
  }

  // Enum adını boşluklarla ayır ve her kelimeyi büyük harfle başlat
  String get title {
    return name
        .replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (match) => ' ${match.group(0)}')
        .capitalizeEachWord();
  }
}

// Widget extension metotları
extension WidgetExtension on Widget {
  // Widget'ı ortalama fonksiyonu
  Widget center() {
    return Center(child: this);
  }

  // Widget'a padding ekleme fonksiyonları
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  Widget paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  // Widget'a margin ekleme fonksiyonu
  Widget margin(EdgeInsetsGeometry margin) {
    return Container(margin: margin, child: this);
  }

  // Widget'ı genişlet
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  // Widget'ı maksimum genişliğe yay
  Widget constrained({double? maxWidth, double? maxHeight}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  // Widget'a tıklama fonksiyonu ekle
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  // Widget'a çift tıklama fonksiyonu ekle
  Widget onDoubleTap(VoidCallback onDoubleTap) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: this,
    );
  }

  // Widget'a uzun basma fonksiyonu ekle
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: this,
    );
  }

  // Widget'a animasyon ekle
  Widget animate({
    required Duration duration,
    Curve curve = Curves.easeInOut,
    required Widget Function(BuildContext, Animation<double>, Widget) builder,
  }) {
    return Builder(
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) => builder(context, AlwaysStoppedAnimation(value), child!),
        child: this,
      ),
    );
  }
}

