// Dosya: lib/utils/service_exception.dart
// Amaç: Servislerde kullanılan özel hata sınıfını tanımlar.
// Bağlantı: analytics_service.dart, storage_service.dart, firestore_service.dart gibi servislerde kullanılır.

class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);

  @override
  String toString() => 'ServiceException: $message';
}