// Dosya: lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

enum AnalyticsEventType {
  filterByCategory,
  searchContent,
  viewContent,
  createComment,
  likeContent,
  saveContent,
  shareContent,
  reportContent,
  reportComment,
  editorCreateContent,
  editorPublishContent,
  profileUpdate,
  changeLanguage,
  viewHomePage,
}

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Olay kaydet
  Future<void> logEvent(AnalyticsEventType eventType, Map<String, Object?> parameters) async {
    try {
      await _analytics.logEvent(
        name: eventType.toString().split('.').last,
        parameters: parameters,
      );
    } catch (e) {
      print('Analytics olayı kaydedilirken hata: $e');
    }
  }

  // Ekran görüntüleme olayı kaydet
  Future<void> logScreenView({required String screenName}) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      print('Ekran görüntüleme olayı kaydedilirken hata: $e');
    }
  }

  // Kullanıcı ID'sini ayarla
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('Kullanıcı ID\'si ayarlanırken hata: $e');
    }
  }
}