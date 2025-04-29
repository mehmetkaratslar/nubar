// lib/viewmodels/home_viewmodel.dart

// Ana Sayfa ViewModel sınıfı
// Ana sayfa ile ilgili veri ve işlemleri yönetir

import 'package:flutter/foundation.dart';

// Services
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

class HomeViewModel extends ChangeNotifier {
  // Servisler
  final FirestoreService _firestoreService;
  final AnalyticsService? _analyticsService;

  // Yükleme ve hata durumları
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  HomeViewModel({
    required FirestoreService firestoreService,
    AnalyticsService? analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService;

  // Örnek bir metod: Popüler içerikleri yükleme
  // Bu metod, uygulamanızın ana sayfasında göstereceği içeriği yüklemek için kullanılabilir.
  // Gerçek implementasyon, ana sayfa tasarımınıza ve ihtiyaçlarınıza göre değişecektir.
  Future<void> loadPopularContents() async {
    _setLoading(true);
    _clearError();

    try {
      // Burada FirestoreService üzerinden popüler içerikleri çekme işlemleri yapılır.
      // Örneğin:
      // final popularContents = await _firestoreService.getPopularContents();
      // _contents = popularContents; // Eğer contents adında bir listeniz varsa

      // Başarılı işlem sonrası
      // notifyListeners();

      // Analytics için olay kaydetme (isteğe bağlı)
      _analyticsService?.logEvent(
        AnalyticsEventType.viewHomePage,
        {'status': 'success'},
      );

    } catch (e) {
      _setError(e.toString());
      _analyticsService?.logEvent(
        AnalyticsEventType.viewHomePage,
        {'status': 'error', 'error_message': e.toString()},
      );
    } finally {
      _setLoading(false);
    }
  }

  // Helper metotlar

  // Yükleniyor durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Hata durumunu ayarla
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Hata durumunu temizle
  void _clearError() {
    _error = null;
  }
}