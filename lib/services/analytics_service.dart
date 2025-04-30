// Dosya: lib/services/analytics_service.dart
// Amaç: Firebase Analytics ile kullanıcı etkileşimlerini izler.
// Bağlantı: home_screen.dart, content_detail_screen.dart’ta kullanıcı eylemlerini izler.
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Olay kaydeder
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      print('Analitik hatası: $e');
    }
  }
}