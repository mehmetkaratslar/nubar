// lib/services/analytics_service.dart
// Firebase Analytics servisi
// Kullanıcı davranışlarını ve uygulama etkinliklerini izleme işlemlerini yönetir

import 'package:firebase_analytics/firebase_analytics.dart';

// Olay tipleri enum - Uygulamada izlenecek özel olaylar
enum AnalyticsEventType {
  viewContent,         // İçerik görüntüleme
  likeContent,         // İçerik beğenme
  saveContent,         // İçerik kaydetme
  shareContent,        // İçerik paylaşma
  createComment,       // Yorum oluşturma
  reportContent,       // İçerik şikayet etme
  reportComment,       // Yorum şikayet etme
  searchContent,       // İçerik arama
  filterByCategory,    // Kategori filtreleme
  changeLanguage,      // Dil değiştirme
  editorCreateContent, // Editör içerik oluşturma
  editorPublishContent,// Editör içerik yayınlama
}

class AnalyticsService {
  // Firebase Analytics instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Firebase Analytics Observer - Navigator için
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Kullanıcı kimliğini ayarla
  Future<void> setUserId(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      await _analytics.setUserId(id: userId);
    }
  }

  // Kullanıcı özelliğini ayarla
  Future<void> setUserProperty({required String name, required String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Ekran görüntüleme kaydı
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Oturum açma olayı
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method ?? 'email');
  }

  // Kayıt olma olayı
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'email');
  }

  // İçerik görüntüleme olayı
  Future<void> logViewContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
    String? language,
  }) async {
    await _analytics.logEvent(
      name: 'view_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
        'language': language ?? 'unknown',
      },
    );
  }

  // İçerik beğenme olayı
  Future<void> logLikeContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
  }) async {
    await _analytics.logEvent(
      name: 'like_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
      },
    );
  }

  // İçerik kaydetme olayı
  Future<void> logSaveContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
  }) async {
    await _analytics.logEvent(
      name: 'save_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
      },
    );
  }

  // İçerik paylaşma olayı
  Future<void> logShareContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: method,
    );
  }

  // Yorum oluşturma olayı
  Future<void> logCreateComment({
    required String contentId,
    required String contentType,
    String? parentId,
  }) async {
    await _analytics.logEvent(
      name: 'create_comment',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'is_reply': parentId != null,
        'parent_id': parentId ?? '',
      },
    );
  }

  // İçerik şikayet etme olayı
  Future<void> logReportContent({
    required String contentId,
    required String contentType,
    required String reportType,
  }) async {
    await _analytics.logEvent(
      name: 'report_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'report_type': reportType,
      },
    );
  }

  // Yorum şikayet etme olayı
  Future<void> logReportComment({
    required String commentId,
    required String reportType,
  }) async {
    await _analytics.logEvent(
      name: 'report_comment',
      parameters: {
        'comment_id': commentId,
        'report_type': reportType,
      },
    );
  }

  // İçerik arama olayı
  Future<void> logSearchContent({
    required String searchTerm,
    required String language,
    int? resultsCount,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'language': language,
        'results_count': resultsCount ?? 0,
      },
    );
  }

  // Kategori filtreleme olayı
  Future<void> logFilterByCategory({
    required String category,
    required String language,
  }) async {
    await _analytics.logEvent(
      name: 'filter_by_category',
      parameters: {
        'category': category,
        'language': language,
      },
    );
  }

  // Dil değiştirme olayı
  Future<void> logChangeLanguage({
    required String previousLanguage,
    required String newLanguage,
  }) async {
    await _analytics.logEvent(
      name: 'change_language',
      parameters: {
        'previous_language': previousLanguage,
        'new_language': newLanguage,
      },
    );
  }

  // Editör içerik oluşturma olayı
  Future<void> logEditorCreateContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
  }) async {
    await _analytics.logEvent(
      name: 'editor_create_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
      },
    );
  }

  // Editör içerik yayınlama olayı
  Future<void> logEditorPublishContent({
    required String contentId,
    required String contentType,
    required String contentCategory,
    required List<String> languages,
  }) async {
    await _analytics.logEvent(
      name: 'editor_publish_content',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
        'languages_count': languages.length,
        'languages': languages.join(','),
      },
    );
  }

  // Genel amaçlı olay loglama
  Future<void> logEvent(AnalyticsEventType eventType, Map<String, dynamic> parameters) async {
    String eventName;

    // Olay tipine göre isim belirle
    switch (eventType) {
      case AnalyticsEventType.viewContent:
        eventName = 'view_content';
        break;
      case AnalyticsEventType.likeContent:
        eventName = 'like_content';
        break;
      case AnalyticsEventType.saveContent:
        eventName = 'save_content';
        break;
      case AnalyticsEventType.shareContent:
        eventName = 'share_content';
        break;
      case AnalyticsEventType.createComment:
        eventName = 'create_comment';
        break;
      case AnalyticsEventType.reportContent:
        eventName = 'report_content';
        break;
      case AnalyticsEventType.reportComment:
        eventName = 'report_comment';
        break;
      case AnalyticsEventType.searchContent:
        eventName = 'search_content';
        break;
      case AnalyticsEventType.filterByCategory:
        eventName = 'filter_by_category';
        break;
      case AnalyticsEventType.changeLanguage:
        eventName = 'change_language';
        break;
      case AnalyticsEventType.editorCreateContent:
        eventName = 'editor_create_content';
        break;
      case AnalyticsEventType.editorPublishContent:
        eventName = 'editor_publish_content';
        break;
    }

    // Olayı logla
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}