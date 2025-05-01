// Dosya: lib/services/analytics_service.dart
// Amaç: Firebase Analytics ile kullanıcı etkileşimlerini izler.
// Bağlantı: home_screen.dart, content_detail_screen.dart, notifications_screen.dart gibi ekranlarda kullanıcı eylemlerini izlemek için kullanılır.
// Not: ServiceException utils/service_exception.dart dosyasından import edildi.

import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/app_constants.dart'; // Sabitler için
import '../utils/service_exception.dart'; // Özel hata sınıfı

// Analytics işlemlerini yöneten servis sınıfı
class AnalyticsService {
  // Firebase Analytics örneği
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Olay kaydeder
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      // Firebase Analytics'e olay gönderir
      await _analytics.logEvent(
        name: name, // Olay adı (örneğin, AppConstants.eventScreenView)
        parameters: parameters, // Ek parametreler
      );
    } catch (e) {
      // Hata durumunda konsola yaz ve özel hata fırlat
      print('Analitik olay kaydı başarısız: $e');
      throw ServiceException('Analitik olay kaydedilemedi: $e');
    }
  }

  // Ekran görüntüleme olayını kaydeder
  Future<void> logScreenView(String screenName) async {
    try {
      await logEvent(
        AppConstants.eventScreenView, // Sabit olay adı
        {
          'screen_name': screenName,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      throw ServiceException('Ekran görüntüleme olayı kaydedilemedi: $e');
    }
  }

  // Bildirim görüntüleme olayını kaydeder
  Future<void> logNotificationView(String notificationId, String title) async {
    try {
      await logEvent(
        'notification_view', // Bildirim görüntüleme olayı
        {
          'notification_id': notificationId,
          'notification_title': title,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      throw ServiceException('Bildirim görüntüleme olayı kaydedilemedi: $e');
    }
  }

  // Bildirim tıklama olayını kaydeder
  Future<void> logNotificationTap(String notificationId, String title) async {
    try {
      await logEvent(
        'notification_tap', // Bildirim tıklama olayı
        {
          'notification_id': notificationId,
          'notification_title': title,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      throw ServiceException('Bildirim tıklama olayı kaydedilemedi: $e');
    }
  }

  // Kullanıcı özelliğini belirler
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(
        name: name, // Özellik adı (örneğin, "user_type")
        value: value, // Özellik değeri (örneğin, "premium")
      );
    } catch (e) {
      throw ServiceException('Kullanıcı özelliği belirlenemedi: $e');
    }
  }

  // Kullanıcı kimliğini belirler
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      throw ServiceException('Kullanıcı kimliği belirlenemedi: $e');
    }
  }
}