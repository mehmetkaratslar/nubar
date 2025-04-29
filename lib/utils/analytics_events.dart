// lib/utils/analytics_events.dart

// Analitik olay türlerini tanımlar

enum AnalyticsEventType {
  // Genel Uygulama Olayları
  appOpen,
  appBackground,
  appTerminate,
  changeLanguage,
  viewHomePage, // HomeViewModel'den eklendi

  // Kimlik Doğrulama Olayları
  login,
  signup,
  logout,
  resetPassword,

  // Kullanıcı Profili Olayları
  profileUpdate, // ProfileViewModel'den eklendi
  viewProfile,

  // İçerik Olayları
  viewContent, // ContentViewModel'den eklendi
  likeContent, // ContentViewModel'den eklendi
  saveContent, // ContentViewModel'den eklendi
  shareContent, // ContentViewModel'den eklendi
  reportContent, // ContentViewModel'den eklendi
  filterByCategory, // ContentViewModel'den eklendi
  searchContent, // ContentViewModel'den eklendi

  // Yorum Olayları
  createComment, // ContentViewModel'den eklendi
  reportComment, // ContentViewModel'den eklendi
  toggleLikeComment, // ContentViewModel'de kullanılıyor olabilir

  // Editör Olayları
  editorCreateContent, // ContentViewModel'den eklendi
  editorUpdateContent, // ContentViewModel'de kullanılıyor olabilir
  editorPublishContent, // ContentViewModel'den eklendi
  editorArchiveContent, // ContentViewModel'de kullanılıyor olabilir
  editorViewDashboard, // Editör paneli için eklendi
  editorViewContentList, // Editör içerik listesi için eklendi


  // Diğer Olaylar (Uygulamanızın ihtiyaçlarına göre eklenebilir)
  // clickButton,
  // viewScreen,
  // completeTutorial,
}

// Basit bir AnalyticsService sınıfı yapısı (Örnek - Gerçek implementasyon farklılık gösterebilir)
// Gerçek bir uygulamada, bu sınıf Firebase Analytics gibi bir servisle entegre edilmelidir.
class AnalyticsService {
  // FirebaseAnalytics gibi bir servisin örneği burada tutulabilir
  // final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  // Kullanıcı kimliğini ayarlama
  Future<void> setUserId(String? userId) async {
    // await _firebaseAnalytics.setUserId(id: userId);
    print('Analytics: User ID set to $userId');
  }

  // Ekran görüntüleme olayını loglama
  Future<void> logScreenView({required String screenName}) async {
    // await _firebaseAnalytics.logScreenView(screenName: screenName);
    print('Analytics: Screen viewed: $screenName');
  }

  // Özel olayları loglama
  Future<void> logEvent(
      AnalyticsEventType eventType,
      Map<String, dynamic>? parameters,
      ) async {
    // await _firebaseAnalytics.logEvent(
    //   name: eventType.toString().split('.').last, // Enum adını kullan
    //   parameters: parameters,
    // );
    print('Analytics: Event logged: ${eventType.toString().split('.').last}');
    if (parameters != null) {
      print('Parameters: $parameters');
    }
  }

// Uygulamanızın ihtiyaç duyduğu diğer analitik metodları buraya ekleyebilirsiniz.
}