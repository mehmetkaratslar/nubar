// Dosya: lib/utils/helpers.dart
// Amaç: Uygulama genelinde kullanılan yardımcı metotları içerir.
// Bağlantı: ContentViewModel ve EditorViewModel içinde kullanılır.

class Helpers {
  // Firebase Storage URL'sinden dosya yolunu çıkarır
  static String getPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length > 1 && pathSegments[0] == 'v0') {
        // Firebase Storage URL formatı: /v0/b/{bucket}/o/{encoded_path}
        final fullPath = Uri.decodeComponent(pathSegments[3]);
        return fullPath;
      }
      return ''; // Geçersiz URL için boş string
    } catch (e) {
      print("URL'den yol çıkarılamadı: $e");
      return ''; // Hata durumunda boş string
    }
  }
}
