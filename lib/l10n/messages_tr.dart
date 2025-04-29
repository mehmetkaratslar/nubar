// lib/l10n/messages_tr.dart
// Türkçe dil desteği için oluşturulan mesaj dosyası
// Bu dosya normalde Flutter gen-l10n komutu tarafından otomatik oluşturulur
// Şu an için temel mesajlar manuel olarak eklenmiştir

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookupByLibrary();

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'tr';

  final messages = _notInlinedMessages();
  static Map<String, Function> _notInlinedMessages() => <String, Function>{
    // Genel mesajlar
    'appName': () => 'Nûbar',
    'appDescription': () => 'Kürt Kültür Platformu',
    'ok': () => 'Tamam',
    'cancel': () => 'İptal',
    'save': () => 'Kaydet',
    'delete': () => 'Sil',
    'edit': () => 'Düzenle',
    'share': () => 'Paylaş',
    'search': () => 'Ara',
    'loading': () => 'Yükleniyor...',
    'retry': () => 'Tekrar Dene',
    'error': () => 'Hata',
    'success': () => 'Başarılı',
    'warning': () => 'Uyarı',
    'info': () => 'Bilgi',
    'confirm': () => 'Onayla',
    'close': () => 'Kapat',
    'next': () => 'İleri',
    'previous': () => 'Geri',
    'back': () => 'Geri',
    'readMore': () => 'Devamını Oku',
    'seeAll': () => 'Hepsini Gör',
    'submit': () => 'Gönder',
    'required': () => 'Zorunlu',
    'optional': () => 'İsteğe Bağlı',
    'all': () => 'Tümü',
    'or': () => 'veya',
    'noSearchResults': () => 'Arama sonucu bulunamadı',
    'noContents': () => 'İçerik bulunamadı',

    // Kimlik doğrulama
    'login': () => 'Giriş Yap',
    'signup': () => 'Kayıt Ol',
    'logout': () => 'Çıkış Yap',
    'email': () => 'E-posta',
    'password': () => 'Şifre',
    'confirmPassword': () => 'Şifre (Tekrar)',
    'username': () => 'Kullanıcı Adı',
    'forgotPassword': () => 'Şifremi Unuttum',
    'resetPassword': () => 'Şifremi Sıfırla',
    'createAccount': () => 'Hesap Oluştur',
    'alreadyHaveAccount': () => 'Zaten hesabınız var mı? Giriş yapın',
    'dontHaveAccount': () => 'Hesabınız yok mu? Kayıt olun',

    // Profil
    'profile': () => 'Profil',
    'editProfile': () => 'Profili Düzenle',
    'bio': () => 'Hakkımda',
    'changePhoto': () => 'Fotoğrafı Değiştir',
    'changePassword': () => 'Şifreyi Değiştir',
    'accountSettings': () => 'Hesap Ayarları',
    'savedContents': () => 'Kaydedilen İçerikler',
    'likedContents': () => 'Beğenilen İçerikler',
    'myComments': () => 'Yorumlarım',

    // İçerik
    'categories': () => 'Kategoriler',
    'history': () => 'Tarih',
    'language': () => 'Dil',
    'art': () => 'Sanat',
    'music': () => 'Müzik',
    'traditions': () => 'Gelenekler',
    'featuredContents': () => 'Öne Çıkan İçerikler',
    'recentContents': () => 'Son Eklenen İçerikler',
    'popularContents': () => 'Popüler İçerikler',
    'contentDetails': () => 'İçerik Detayları',
    'likes': () => 'Beğeni',
    'comments': () => 'Yorum',
    'views': () => 'Görüntülenme',
    'addComment': () => 'Yorum Ekle',
    'writeComment': () => 'Bir yorum yazın...',
    'contentNotFound': () => 'İçerik bulunamadı',

    // Editör
    'editor': () => 'Editör',
    'editorDashboard': () => 'Editör Paneli',
    'createContent': () => 'İçerik Oluştur',
    'editContent': () => 'İçerik Düzenle',
    'contentTitle': () => 'İçerik Başlığı',
    'contentSummary': () => 'İçerik Özeti',
    'contentText': () => 'İçerik Metni',
    'contentCategory': () => 'İçerik Kategorisi',
    'contentTags': () => 'İçerik Etiketleri',
    'addTags': () => 'Etiket Ekle',
    'uploadMedia': () => 'Medya Yükle',
    'uploadThumbnail': () => 'Küçük Resim Yükle',
    'savedAsDraft': () => 'Taslak Olarak Kaydedildi',
    'publish': () => 'Yayınla',
    'unpublish': () => 'Yayından Kaldır',
    'draft': () => 'Taslak',
    'published': () => 'Yayınlandı',
    'archived': () => 'Arşivlendi',

    // Report
    'report': () => 'Bildir',
    'reportContent': () => 'İçeriği Bildir',
    'reportComment': () => 'Yorumu Bildir',
    'reportReason': () => 'Bildirim Nedeni',
    'reportDescription': () => 'Açıklama',
    'inappropriate': () => 'Uygunsuz İçerik',
    'spam': () => 'Spam',
    'offensive': () => 'Hakaret/Saldırgan',
    'violence': () => 'Şiddet',
    'copyright': () => 'Telif Hakkı İhlali',
    'other': () => 'Diğer',
    'thanksForReporting': () => 'Bildirdiğiniz için teşekkürler. En kısa sürede inceleyeceğiz.',

    // Languages
    'kurdishKurmanji': () => 'Kurdî (Kurmancî)',
    'turkish': () => 'Türkçe',
    'english': () => 'English',
    'selectLanguage': () => 'Dil Seçin',

    // Splash Screen
    'welcomeToNubar': () => 'Nûbar\'a Hoş Geldiniz',
    'discoverKurdishCulture': () => 'Kürt Kültürünü Keşfedin',
    'getStarted': () => 'Başlayın',

    // Categories descriptions
    'historyDescription': () => 'Kürt tarihine dair bilgiler, olaylar ve önemli kişiler.',
    'languageDescription': () => 'Kürtçe dil bilgisi, kelimeler, deyimler ve lehçeler.',
    'artDescription': () => 'Kürt sanatı, edebiyatı, şiir ve resim.',
    'musicDescription': () => 'Kürt müziği, şarkıları, enstrümanları ve sanatçıları.',
    'traditionsDescription': () => 'Kürt kültürel gelenekleri, kutlamaları ve yaşam tarzı.',
  };
}