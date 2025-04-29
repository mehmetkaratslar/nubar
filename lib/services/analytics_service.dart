// lib/services/analytics_service.dart
// Amaç: Analitik olayları yönetir.
// Konum: lib/services/
// Bağlantılar:
// - ViewModel'lar tarafından kullanılır (örneğin, ProfileViewModel, EditorViewModel, HomeViewModel).

import 'package:firebase_analytics/firebase_analytics.dart';

enum AnalyticsEventType {
  contentCreated,
  profileUpdated,
  userLogin,
  userSignup,
  searchContent,
  userScreenView,
  filterByCategory,
}

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(AnalyticsEventType eventType, Map<String, Object> parameters) async {
    try {
      String eventName;
      switch (eventType) {
        case AnalyticsEventType.contentCreated:
          eventName = 'content_created';
          break;
        case AnalyticsEventType.profileUpdated:
          eventName = 'profile_updated';
          break;
        case AnalyticsEventType.userLogin:
          eventName = 'user_login';
          break;
        case AnalyticsEventType.userSignup:
          eventName = 'user_signup';
          break;
        case AnalyticsEventType.searchContent:
          eventName = 'search_content';
          break;
        case AnalyticsEventType.userScreenView:
          eventName = 'screen_view';
          break;
        case AnalyticsEventType.filterByCategory:
          eventName = 'filter_by_category';
          break;
      }
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Analitik olay kaydedilirken hata: $e');
      rethrow;
    }
  }
}