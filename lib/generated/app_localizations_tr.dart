// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nûbar';

  @override
  String get appDescription => 'Kürt kültürünü korumak ve dünya çapında tanıtmak için bir platform.';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get share => 'Paylaş';

  @override
  String get search => 'Ara';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get warning => 'Uyarı';

  @override
  String get info => 'Bilgi';

  @override
  String get confirm => 'Onayla';

  @override
  String get close => 'Kapat';

  @override
  String get next => 'İleri';

  @override
  String get previous => 'Geri';

  @override
  String get back => 'Geri';

  @override
  String get readMore => 'Devamını Oku';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get submit => 'Gönder';

  @override
  String get required => 'Zorunlu';

  @override
  String get optional => 'İsteğe Bağlı';

  @override
  String get all => 'Tümü';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signup => 'Kayıt Ol';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get resetPassword => 'Şifreyi Sıfırla';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get alreadyHaveAccount => 'Hesabınız var mı? Giriş Yapın';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? Kayıt Olun';

  @override
  String loginWith(Object provider) {
    return '$provider ile Giriş Yap';
  }

  @override
  String signupWith(Object provider) {
    return '$provider ile Kayıt Ol';
  }

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get bio => 'Hakkımda';

  @override
  String get changePhoto => 'Fotoğrafı Değiştir';

  @override
  String get changePassword => 'Şifreyi Değiştir';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String get savedContents => 'Kaydedilen İçerikler';

  @override
  String get likedContents => 'Beğenilen İçerikler';

  @override
  String get myComments => 'Yorumlarım';

  @override
  String joinedOn(Object date) {
    return '$date tarihinde katıldı';
  }

  @override
  String get categories => 'Kategoriler';

  @override
  String get history => 'Tarih';

  @override
  String get language => 'Dil';

  @override
  String get art => 'Sanat';

  @override
  String get music => 'Müzik';

  @override
  String get traditions => 'Gelenekler';

  @override
  String get featuredContents => 'Öne Çıkan İçerikler';

  @override
  String get recentContents => 'Yeni İçerikler';

  @override
  String get popularContents => 'Popüler İçerikler';

  @override
  String get contentDetails => 'İçerik Detayları';

  @override
  String get likes => 'Beğeniler';

  @override
  String get comments => 'Yorumlar';

  @override
  String get views => 'Görüntülenmeler';

  @override
  String get addComment => 'Yorum Ekle';

  @override
  String get writeComment => 'Bir yorum yaz...';

  @override
  String publishedOn(Object date) {
    return '$date tarihinde yayınlandı';
  }

  @override
  String createdBy(Object username) {
    return '$username tarafından oluşturuldu';
  }

  @override
  String lastEdited(Object date) {
    return 'Son düzenleme: $date';
  }

  @override
  String get historyDescription => 'Kürt tarihine dair önemli bilgiler, olaylar ve kişiler.';

  @override
  String get languageDescription => 'Kürtçe dilbilgisi, kelimeler, atasözleri ve lehçeler.';

  @override
  String get artDescription => 'Kürt sanatı, edebiyat, şiir ve resim.';

  @override
  String get musicDescription => 'Kürt müziği, şarkılar, enstrümanlar ve sanatçılar.';

  @override
  String get traditionsDescription => 'Kürt kültürünün gelenekleri, kutlamalar ve yaşam tarzı.';

  @override
  String get editor => 'Editör';

  @override
  String get editorDashboard => 'Editör Paneli';

  @override
  String get createContent => 'İçerik Oluştur';

  @override
  String get editContent => 'İçeriği Düzenle';

  @override
  String get contentTitle => 'İçerik Başlığı';

  @override
  String get contentSummary => 'İçerik Özeti';

  @override
  String get contentText => 'İçerik Metni';

  @override
  String get contentCategory => 'İçerik Kategorisi';

  @override
  String get contentType => 'İçerik Türü';

  @override
  String get contentTags => 'İçerik Etiketleri';

  @override
  String get addTags => 'Etiket Ekle';

  @override
  String get uploadMedia => 'Medya Yükle';

  @override
  String get uploadThumbnail => 'Küçük Resim Yükle';

  @override
  String get savedAsDraft => 'Taslak olarak kaydedildi';

  @override
  String get publish => 'Yayınla';

  @override
  String get unpublish => 'Yayından Kaldır';

  @override
  String get draft => 'Taslak';

  @override
  String get published => 'Yayınlandı';

  @override
  String get archived => 'Arşivlendi';

  @override
  String get pending => 'Beklemede';

  @override
  String get publishedContents => 'Yayınlanan İçerikler';

  @override
  String get draftContents => 'Taslak İçerikler';

  @override
  String get moderationQueue => 'Moderasyon Sırası';

  @override
  String get reportedContents => 'Rapor Edilen İçerikler';

  @override
  String get reportedComments => 'Rapor Edilen Yorumlar';

  @override
  String get report => 'Rapor Et';

  @override
  String get reportContent => 'İçeriği Rapor Et';

  @override
  String get reportComment => 'Yorumu Rapor Et';

  @override
  String get reportReason => 'Rapor Nedeni';

  @override
  String get reportDescription => 'Açıklama';

  @override
  String get inappropriate => 'Uygunsuz İçerik';

  @override
  String get spam => 'Spam';

  @override
  String get offensive => 'Rahatsız Edici';

  @override
  String get violence => 'Şiddet';

  @override
  String get copyright => 'Telif Hakkı İhlali';

  @override
  String get other => 'Diğer';

  @override
  String get thanksForReporting => 'Rapor ettiğiniz için teşekkürler. Kısa sürede inceleyeceğiz.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get general => 'Genel';

  @override
  String get account => 'Hesap';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get privacy => 'Gizlilik';

  @override
  String get helpAndSupport => 'Yardım ve Destek';

  @override
  String get about => 'Hakkında';

  @override
  String get termsOfService => 'Hizmet Şartları';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get contactUs => 'Bize Ulaşın';

  @override
  String get feedback => 'Geri Bildirim';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Koyu Mod';

  @override
  String get lightMode => 'Açık Mod';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get kurdishKurmanji => 'Kürtçe (Kurmanci)';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String get selectLanguage => 'Dil Seç';

  @override
  String languageChanged(Object language) {
    return 'Dil $language olarak değiştirildi';
  }

  @override
  String get networkError => 'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get generalError => 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String get authError => 'Giriş yaparken bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get weakPassword => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get passwordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get requiredField => 'Bu alan zorunludur.';

  @override
  String get uploadError => 'Dosya yüklenirken bir hata oluştu.';

  @override
  String get contentLoadError => 'İçerik yüklenirken bir hata oluştu.';

  @override
  String get contentCreateError => 'İçerik oluşturulurken bir hata oluştu.';

  @override
  String get commentError => 'Yorum gönderilirken bir hata oluştu.';

  @override
  String get permissionDenied => 'Bu işlemi yapmak için izniniz yok.';

  @override
  String get welcomeToNubar => 'Nûbar\'a Hoş Geldiniz';

  @override
  String get discoverKurdishCulture => 'Kürt Kültürünü Keşfet';

  @override
  String get getStarted => 'Başla';

  @override
  String get frequentlyAskedQuestions => 'Sıkça Sorulan Sorular';

  @override
  String get howToUse => 'Nasıl Kullanılır';

  @override
  String get contactSupport => 'Destek Ekibiyle İletişime Geç';

  @override
  String get reportIssue => 'Sorun Bildir';

  @override
  String get giveFeedback => 'Geri Bildirim Ver';

  @override
  String get orLabel => 'veya';

  @override
  String get homeLabel => 'Ana Sayfa';

  @override
  String get exploreLabel => 'Keşfet';

  @override
  String get savedLabel => 'Kaydedilenler';

  @override
  String get noContentsFoundLabel => 'İçerik bulunamadı';

  @override
  String get noSearchResultsLabel => 'Arama sonucu bulunamadı';
}
