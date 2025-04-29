// lib/l10n/messages_ku.dart
// Kürtçe dil desteği için oluşturulan mesaj dosyası
// Bu dosya normalde Flutter gen-l10n komutu tarafından otomatik oluşturulur
// Şu an için temel mesajlar manuel olarak eklenmiştir

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookupByLibrary();

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'ku';

  final messages = _notInlinedMessages();
  static Map<String, Function> _notInlinedMessages() => <String, Function>{
    // Genel mesajlar
    'appName': () => 'Nûbar',
    'appDescription': () => 'Platforma Çanda Kurdî',
    'ok': () => 'Baş e',
    'cancel': () => 'Betal',
    'save': () => 'Tomar bike',
    'delete': () => 'Jê bibe',
    'edit': () => 'Biguherîne',
    'share': () => 'Parve bike',
    'search': () => 'Lê bigere',
    'loading': () => 'Tê barkirin...',
    'retry': () => 'Dîsa biceribîne',
    'error': () => 'Çewtî',
    'success': () => 'Serkeftî',
    'warning': () => 'Hişyarî',
    'info': () => 'Agahî',
    'confirm': () => 'Piştrast bike',
    'close': () => 'Bigire',
    'next': () => 'Pêşve',
    'previous': () => 'Paşve',
    'back': () => 'Vegere',
    'readMore': () => 'Zêdetir bixwîne',
    'seeAll': () => 'Hemûyan bibîne',
    'submit': () => 'Bişîne',
    'required': () => 'Pêwîst',
    'optional': () => 'Ne pêwîst',
    'all': () => 'Hemû',
    'or': () => 'an',
    'noSearchResults': () => 'Ti encamên lêgerînê nehatin dîtin',
    'noContents': () => 'Ti naverok tune',

    // Kimlik doğrulama
    'login': () => 'Têkeve',
    'signup': () => 'Tomar bibe',
    'logout': () => 'Derkeve',
    'email': () => 'E-peyam',
    'password': () => 'Şîfre',
    'confirmPassword': () => 'Şîfre dubare bike',
    'username': () => 'Navê bikarhêner',
    'forgotPassword': () => 'Şîfre jibîr kir',
    'resetPassword': () => 'Şîfre nû bike',
    'createAccount': () => 'Hesabek çêke',
    'alreadyHaveAccount': () => 'Hesabê te heye? Têkeve',
    'dontHaveAccount': () => 'Hesabê te tune? Tomar bibe',

    // Profil
    'profile': () => 'Profîl',
    'editProfile': () => 'Profîl biguherîne',
    'bio': () => 'Derbarê min de',
    'changePhoto': () => 'Wêne biguherîne',
    'changePassword': () => 'Şîfre biguherîne',
    'accountSettings': () => 'Mîhengên hesab',
    'savedContents': () => 'Naverokên tomarkirî',
    'likedContents': () => 'Naverokên ecibandinî',
    'myComments': () => 'Şîroveyên min',

    // İçerik
    'categories': () => 'Kategorî',
    'history': () => 'Dîrok',
    'language': () => 'Ziman',
    'art': () => 'Huner',
    'music': () => 'Muzîk',
    'traditions': () => 'Kevneşopî',
    'featuredContents': () => 'Naverokên Taybet',
    'recentContents': () => 'Naverokên Nû',
    'popularContents': () => 'Naverokên Populer',
    'contentDetails': () => 'Hûrgiliyên Naverokê',
    'likes': () => 'Ecibîn',
    'comments': () => 'Şîrove',
    'views': () => 'Dîtin',
    'addComment': () => 'Şîrove lê zêde bike',
    'writeComment': () => 'Şîroveyekê binivîse...',
    'contentNotFound': () => 'Naverok nehat dîtin',

    // Editör
    'editor': () => 'Editor',
    'editorDashboard': () => 'Panela Edîtorê',
    'createContent': () => 'Naverok biafirîne',
    'editContent': () => 'Naverok biguherîne',
    'contentTitle': () => 'Sernavê Naverokê',
    'contentSummary': () => 'Kurteya Naverokê',
    'contentText': () => 'Nivîsa Naverokê',
    'contentCategory': () => 'Kategoriya Naverokê',
    'contentTags': () => 'Etîketên Naverokê',
    'addTags': () => 'Etîketan lê zêde bike',
    'uploadMedia': () => 'Medya bar bike',
    'uploadThumbnail': () => 'Wêneyek piçûk bar bike',
    'savedAsDraft': () => 'Wek reşnivîs hat tomarkirin',
    'publish': () => 'Biweşîne',
    'unpublish': () => 'Ji weşanê rake',
    'draft': () => 'Reşnivîs',
    'published': () => 'Hatiye weşandin',
    'archived': () => 'Arşîvkirî',

    // Report
    'report': () => 'Rapor bike',
    'reportContent': () => 'Naverokê rapor bike',
    'reportComment': () => 'Şîroveyê rapor bike',
    'reportReason': () => 'Sedema Raporê',
    'reportDescription': () => 'Danasîn',
    'inappropriate': () => 'Naveroka Neyênî',
    'spam': () => 'Spam',
    'offensive': () => 'Çêrî/Êrîşkar',
    'violence': () => 'Tundî',
    'copyright': () => 'Binpêkirina Mafê Telîfê',
    'other': () => 'Din',
    'thanksForReporting': () => 'Ji bo raporkirinê spas. Em ê di demeke nêz de lê binêrin.',

    // Languages
    'kurdishKurmanji': () => 'Kurdî (Kurmancî)',
    'turkish': () => 'Tirkî',
    'english': () => 'Îngilîzî',
    'selectLanguage': () => 'Ziman hilbijêre',

    // Splash Screen
    'welcomeToNubar': () => 'Bi xêr hatî Nûbar',
    'discoverKurdishCulture': () => 'Çanda Kurdî Keşf Bike',
    'getStarted': () => 'Dest pê bike',

    // Categories descriptions
    'historyDescription': () => 'Agahdarî, bûyer û kesayetiyên girîng ên dîroka Kurdî.',
    'languageDescription': () => 'Rêzimana Kurdî, peyv, gotinên pêşiyan û zarav.',
    'artDescription': () => 'Hunera Kurdî, wêje, helbest û wêne.',
    'musicDescription': () => 'Muzîka Kurdî, stran, amûr û hunermend.',
    'traditionsDescription': () => 'Kevneşopiyên çanda Kurdî, pîrozbahî û awayê jiyanê.',
  };
}