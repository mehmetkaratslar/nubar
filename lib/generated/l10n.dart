import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ku.dart';
import 'l10n_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ku'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In ku, this message translates to:
  /// **'Nûbar'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In ku, this message translates to:
  /// **'Platformek ji bo parastin û pêşxistina çanda Kurdî li cîhanê.'**
  String get appDescription;

  /// No description provided for @ok.
  ///
  /// In ku, this message translates to:
  /// **'Baş e'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ku, this message translates to:
  /// **'Betal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ku, this message translates to:
  /// **'Tomar bike'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ku, this message translates to:
  /// **'Jê bibe'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ku, this message translates to:
  /// **'Biguherîne'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In ku, this message translates to:
  /// **'Parve bike'**
  String get share;

  /// No description provided for @search.
  ///
  /// In ku, this message translates to:
  /// **'Lêgerîn'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In ku, this message translates to:
  /// **'Tê barkirin...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In ku, this message translates to:
  /// **'Dîsa biceribîne'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In ku, this message translates to:
  /// **'Çewtî'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ku, this message translates to:
  /// **'Serkeftî'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ku, this message translates to:
  /// **'Hişyarî'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ku, this message translates to:
  /// **'Agahî'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In ku, this message translates to:
  /// **'Piştrast bike'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ku, this message translates to:
  /// **'Bigire'**
  String get close;

  /// No description provided for @next.
  ///
  /// In ku, this message translates to:
  /// **'Pêşve'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ku, this message translates to:
  /// **'Paşve'**
  String get previous;

  /// No description provided for @back.
  ///
  /// In ku, this message translates to:
  /// **'Vegere'**
  String get back;

  /// No description provided for @readMore.
  ///
  /// In ku, this message translates to:
  /// **'Zêdetir bixwîne'**
  String get readMore;

  /// No description provided for @seeAll.
  ///
  /// In ku, this message translates to:
  /// **'Hemûyan bibîne'**
  String get seeAll;

  /// No description provided for @submit.
  ///
  /// In ku, this message translates to:
  /// **'Bişîne'**
  String get submit;

  /// No description provided for @required.
  ///
  /// In ku, this message translates to:
  /// **'Pêwîst'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In ku, this message translates to:
  /// **'Ne pêwîst'**
  String get optional;

  /// No description provided for @all.
  ///
  /// In ku, this message translates to:
  /// **'Hemû'**
  String get all;

  /// No description provided for @login.
  ///
  /// In ku, this message translates to:
  /// **'Têkeve'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In ku, this message translates to:
  /// **'Tomar bibe'**
  String get signup;

  /// No description provided for @logout.
  ///
  /// In ku, this message translates to:
  /// **'Derkeve'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In ku, this message translates to:
  /// **'E-peyam'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre dubare bike'**
  String get confirmPassword;

  /// No description provided for @username.
  ///
  /// In ku, this message translates to:
  /// **'Navê bikarhêner'**
  String get username;

  /// No description provided for @forgotPassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre jibîr kir'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre nû bike'**
  String get resetPassword;

  /// No description provided for @createAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesabek çêke'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesabê te heye? Têkeve'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesabê te tune? Tomar bibe'**
  String get dontHaveAccount;

  /// No description provided for @loginWith.
  ///
  /// In ku, this message translates to:
  /// **'Bi {provider} re têkeve'**
  String loginWith(Object provider);

  /// No description provided for @signupWith.
  ///
  /// In ku, this message translates to:
  /// **'Bi {provider} re tomar bibe'**
  String signupWith(Object provider);

  /// No description provided for @profile.
  ///
  /// In ku, this message translates to:
  /// **'Profîl'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In ku, this message translates to:
  /// **'Profîl biguherîne'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In ku, this message translates to:
  /// **'Derbarê min de'**
  String get bio;

  /// No description provided for @changePhoto.
  ///
  /// In ku, this message translates to:
  /// **'Wêne biguherîne'**
  String get changePhoto;

  /// No description provided for @changePassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre biguherîne'**
  String get changePassword;

  /// No description provided for @accountSettings.
  ///
  /// In ku, this message translates to:
  /// **'Mîhengên hesab'**
  String get accountSettings;

  /// No description provided for @savedContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên tomarkirî'**
  String get savedContents;

  /// No description provided for @likedContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên ecibandinî'**
  String get likedContents;

  /// No description provided for @myComments.
  ///
  /// In ku, this message translates to:
  /// **'Şîroveyên min'**
  String get myComments;

  /// No description provided for @joinedOn.
  ///
  /// In ku, this message translates to:
  /// **'Di {date} de tevlî bû'**
  String joinedOn(Object date);

  /// No description provided for @categories.
  ///
  /// In ku, this message translates to:
  /// **'Kategorî'**
  String get categories;

  /// No description provided for @history.
  ///
  /// In ku, this message translates to:
  /// **'Dîrok'**
  String get history;

  /// No description provided for @language.
  ///
  /// In ku, this message translates to:
  /// **'Ziman'**
  String get language;

  /// No description provided for @art.
  ///
  /// In ku, this message translates to:
  /// **'Huner'**
  String get art;

  /// No description provided for @music.
  ///
  /// In ku, this message translates to:
  /// **'Muzîk'**
  String get music;

  /// No description provided for @traditions.
  ///
  /// In ku, this message translates to:
  /// **'Kevneşopî'**
  String get traditions;

  /// No description provided for @featuredContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Taybet'**
  String get featuredContents;

  /// No description provided for @recentContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Nû'**
  String get recentContents;

  /// No description provided for @popularContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Populer'**
  String get popularContents;

  /// No description provided for @contentDetails.
  ///
  /// In ku, this message translates to:
  /// **'Hûrgiliyên Naverokê'**
  String get contentDetails;

  /// No description provided for @likes.
  ///
  /// In ku, this message translates to:
  /// **'Ecibîn'**
  String get likes;

  /// No description provided for @comments.
  ///
  /// In ku, this message translates to:
  /// **'Şîrove'**
  String get comments;

  /// No description provided for @views.
  ///
  /// In ku, this message translates to:
  /// **'Dîtin'**
  String get views;

  /// No description provided for @addComment.
  ///
  /// In ku, this message translates to:
  /// **'Şîrove lê zêde bike'**
  String get addComment;

  /// No description provided for @writeComment.
  ///
  /// In ku, this message translates to:
  /// **'Şîroveyekê binivîse...'**
  String get writeComment;

  /// No description provided for @publishedOn.
  ///
  /// In ku, this message translates to:
  /// **'Di {date} de hat weşandin'**
  String publishedOn(Object date);

  /// No description provided for @createdBy.
  ///
  /// In ku, this message translates to:
  /// **'Ji aliyê {username} ve hat afirandin'**
  String createdBy(Object username);

  /// No description provided for @lastEdited.
  ///
  /// In ku, this message translates to:
  /// **'Guhertina dawî: {date}'**
  String lastEdited(Object date);

  /// No description provided for @historyDescription.
  ///
  /// In ku, this message translates to:
  /// **'Agahdarî, bûyer û kesayetiyên girîng ên dîroka Kurdî.'**
  String get historyDescription;

  /// No description provided for @languageDescription.
  ///
  /// In ku, this message translates to:
  /// **'Rêzimana Kurdî, peyv, gotinên pêşiyan û zarav.'**
  String get languageDescription;

  /// No description provided for @artDescription.
  ///
  /// In ku, this message translates to:
  /// **'Hunera Kurdî, wêje, helbest û wêne.'**
  String get artDescription;

  /// No description provided for @musicDescription.
  ///
  /// In ku, this message translates to:
  /// **'Muzîka Kurdî, stran, amûr û hunermend.'**
  String get musicDescription;

  /// No description provided for @traditionsDescription.
  ///
  /// In ku, this message translates to:
  /// **'Kevneşopiyên çanda Kurdî, pîrozbahî û awayê jiyanê.'**
  String get traditionsDescription;

  /// No description provided for @editor.
  ///
  /// In ku, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @editorDashboard.
  ///
  /// In ku, this message translates to:
  /// **'Panela Edîtorê'**
  String get editorDashboard;

  /// No description provided for @createContent.
  ///
  /// In ku, this message translates to:
  /// **'Naverok biafirîne'**
  String get createContent;

  /// No description provided for @editContent.
  ///
  /// In ku, this message translates to:
  /// **'Naverok biguherîne'**
  String get editContent;

  /// No description provided for @contentTitle.
  ///
  /// In ku, this message translates to:
  /// **'Sernavê Naverokê'**
  String get contentTitle;

  /// No description provided for @contentSummary.
  ///
  /// In ku, this message translates to:
  /// **'Kurteya Naverokê'**
  String get contentSummary;

  /// No description provided for @contentText.
  ///
  /// In ku, this message translates to:
  /// **'Nivîsa Naverokê'**
  String get contentText;

  /// No description provided for @contentCategory.
  ///
  /// In ku, this message translates to:
  /// **'Kategoriya Naverokê'**
  String get contentCategory;

  /// No description provided for @contentType.
  ///
  /// In ku, this message translates to:
  /// **'Cûreya Naverokê'**
  String get contentType;

  /// No description provided for @contentTags.
  ///
  /// In ku, this message translates to:
  /// **'Etîketên Naverokê'**
  String get contentTags;

  /// No description provided for @addTags.
  ///
  /// In ku, this message translates to:
  /// **'Etîketan lê zêde bike'**
  String get addTags;

  /// No description provided for @uploadMedia.
  ///
  /// In ku, this message translates to:
  /// **'Medya bar bike'**
  String get uploadMedia;

  /// No description provided for @uploadThumbnail.
  ///
  /// In ku, this message translates to:
  /// **'Wêneyek piçûk bar bike'**
  String get uploadThumbnail;

  /// No description provided for @savedAsDraft.
  ///
  /// In ku, this message translates to:
  /// **'Wek reşnivîs hat tomarkirin'**
  String get savedAsDraft;

  /// No description provided for @publish.
  ///
  /// In ku, this message translates to:
  /// **'Biweşîne'**
  String get publish;

  /// No description provided for @unpublish.
  ///
  /// In ku, this message translates to:
  /// **'Ji weşanê rake'**
  String get unpublish;

  /// No description provided for @draft.
  ///
  /// In ku, this message translates to:
  /// **'Reşnivîs'**
  String get draft;

  /// No description provided for @published.
  ///
  /// In ku, this message translates to:
  /// **'Hatiye weşandin'**
  String get published;

  /// No description provided for @archived.
  ///
  /// In ku, this message translates to:
  /// **'Arşîvkirî'**
  String get archived;

  /// No description provided for @pending.
  ///
  /// In ku, this message translates to:
  /// **'Li benda'**
  String get pending;

  /// No description provided for @publishedContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Weşandî'**
  String get publishedContents;

  /// No description provided for @draftContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Reşnivîs'**
  String get draftContents;

  /// No description provided for @moderationQueue.
  ///
  /// In ku, this message translates to:
  /// **'Rêza Moderasyonê'**
  String get moderationQueue;

  /// No description provided for @reportedContents.
  ///
  /// In ku, this message translates to:
  /// **'Naverokên Rapor Kirî'**
  String get reportedContents;

  /// No description provided for @reportedComments.
  ///
  /// In ku, this message translates to:
  /// **'Şîroveyên Rapor Kirî'**
  String get reportedComments;

  /// No description provided for @report.
  ///
  /// In ku, this message translates to:
  /// **'Rapor bike'**
  String get report;

  /// No description provided for @reportContent.
  ///
  /// In ku, this message translates to:
  /// **'Naverokê rapor bike'**
  String get reportContent;

  /// No description provided for @reportComment.
  ///
  /// In ku, this message translates to:
  /// **'Şîroveyê rapor bike'**
  String get reportComment;

  /// No description provided for @reportReason.
  ///
  /// In ku, this message translates to:
  /// **'Sedema Raporê'**
  String get reportReason;

  /// No description provided for @reportDescription.
  ///
  /// In ku, this message translates to:
  /// **'Danasîn'**
  String get reportDescription;

  /// No description provided for @inappropriate.
  ///
  /// In ku, this message translates to:
  /// **'Naveroka Neyênî'**
  String get inappropriate;

  /// No description provided for @spam.
  ///
  /// In ku, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @offensive.
  ///
  /// In ku, this message translates to:
  /// **'Çêrî/Êrîşkar'**
  String get offensive;

  /// No description provided for @violence.
  ///
  /// In ku, this message translates to:
  /// **'Tundî'**
  String get violence;

  /// No description provided for @copyright.
  ///
  /// In ku, this message translates to:
  /// **'Binpêkirina Mafê Telîfê'**
  String get copyright;

  /// No description provided for @other.
  ///
  /// In ku, this message translates to:
  /// **'Din'**
  String get other;

  /// No description provided for @thanksForReporting.
  ///
  /// In ku, this message translates to:
  /// **'Ji bo raporkirinê spas. Em ê di demeke nêz de lê binêrin.'**
  String get thanksForReporting;

  /// No description provided for @settings.
  ///
  /// In ku, this message translates to:
  /// **'Mîheng'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In ku, this message translates to:
  /// **'Giştî'**
  String get general;

  /// No description provided for @account.
  ///
  /// In ku, this message translates to:
  /// **'Hesab'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In ku, this message translates to:
  /// **'Hişyarî'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In ku, this message translates to:
  /// **'Nepenî'**
  String get privacy;

  /// No description provided for @helpAndSupport.
  ///
  /// In ku, this message translates to:
  /// **'Alîkarî û Piştgirî'**
  String get helpAndSupport;

  /// No description provided for @about.
  ///
  /// In ku, this message translates to:
  /// **'Derbarê'**
  String get about;

  /// No description provided for @termsOfService.
  ///
  /// In ku, this message translates to:
  /// **'Mercên Xizmetê'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ku, this message translates to:
  /// **'Polîtîkaya Nepeniyê'**
  String get privacyPolicy;

  /// No description provided for @contactUs.
  ///
  /// In ku, this message translates to:
  /// **'Têkilî'**
  String get contactUs;

  /// No description provided for @feedback.
  ///
  /// In ku, this message translates to:
  /// **'Paşragihandin'**
  String get feedback;

  /// No description provided for @theme.
  ///
  /// In ku, this message translates to:
  /// **'Mijar'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In ku, this message translates to:
  /// **'Moda Tarî'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In ku, this message translates to:
  /// **'Moda Ronî'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In ku, this message translates to:
  /// **'Mîhenga Pergalê'**
  String get systemDefault;

  /// No description provided for @kurdishKurmanji.
  ///
  /// In ku, this message translates to:
  /// **'Kurdî (Kurmancî)'**
  String get kurdishKurmanji;

  /// No description provided for @turkish.
  ///
  /// In ku, this message translates to:
  /// **'Tirkî'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In ku, this message translates to:
  /// **'Îngilîzî'**
  String get english;

  /// No description provided for @selectLanguage.
  ///
  /// In ku, this message translates to:
  /// **'Ziman hilbijêre'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In ku, this message translates to:
  /// **'Ziman guherî bo {language}'**
  String languageChanged(Object language);

  /// No description provided for @networkError.
  ///
  /// In ku, this message translates to:
  /// **'Ji kerema xwe girêdana înternetê kontrol bike û dîsa biceribîne.'**
  String get networkError;

  /// No description provided for @generalError.
  ///
  /// In ku, this message translates to:
  /// **'Çewtiyek çêbû. Ji kerema xwe paşê dîsa biceribîne.'**
  String get generalError;

  /// No description provided for @authError.
  ///
  /// In ku, this message translates to:
  /// **'Di têketinê de çewtiyek çêbû. Ji kerema xwe dîsa biceribîne.'**
  String get authError;

  /// No description provided for @invalidEmail.
  ///
  /// In ku, this message translates to:
  /// **'Ji kerema xwe navnîşana e-peyamê ya derbasdar binivîse.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre divê herî kêm 6 tîp be.'**
  String get weakPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre li hev nakin.'**
  String get passwordMismatch;

  /// No description provided for @requiredField.
  ///
  /// In ku, this message translates to:
  /// **'Ev qad pêwîst e.'**
  String get requiredField;

  /// No description provided for @uploadError.
  ///
  /// In ku, this message translates to:
  /// **'Di barkirina pelê de çewtiyek çêbû.'**
  String get uploadError;

  /// No description provided for @contentLoadError.
  ///
  /// In ku, this message translates to:
  /// **'Di barkirina naverokê de çewtiyek çêbû.'**
  String get contentLoadError;

  /// No description provided for @contentCreateError.
  ///
  /// In ku, this message translates to:
  /// **'Di afirandina naverokê de çewtiyek çêbû.'**
  String get contentCreateError;

  /// No description provided for @commentError.
  ///
  /// In ku, this message translates to:
  /// **'Di şandina şîroveyê de çewtiyek çêbû.'**
  String get commentError;

  /// No description provided for @permissionDenied.
  ///
  /// In ku, this message translates to:
  /// **'Destûra te nîne ku vê çalakiyê bike.'**
  String get permissionDenied;

  /// No description provided for @welcomeToNubar.
  ///
  /// In ku, this message translates to:
  /// **'Bi xêr hatî Nûbar'**
  String get welcomeToNubar;

  /// No description provided for @discoverKurdishCulture.
  ///
  /// In ku, this message translates to:
  /// **'Çanda Kurdî Keşf Bike'**
  String get discoverKurdishCulture;

  /// No description provided for @getStarted.
  ///
  /// In ku, this message translates to:
  /// **'Dest pê bike'**
  String get getStarted;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In ku, this message translates to:
  /// **'Pirsên Pir Tên Pirsîn'**
  String get frequentlyAskedQuestions;

  /// No description provided for @howToUse.
  ///
  /// In ku, this message translates to:
  /// **'Çawa tê bikaranîn'**
  String get howToUse;

  /// No description provided for @contactSupport.
  ///
  /// In ku, this message translates to:
  /// **'Bi Tîma Piştgiriyê re Têkilî Deyne'**
  String get contactSupport;

  /// No description provided for @reportIssue.
  ///
  /// In ku, this message translates to:
  /// **'Pirsgirêkê rapor bike'**
  String get reportIssue;

  /// No description provided for @giveFeedback.
  ///
  /// In ku, this message translates to:
  /// **'Paşragihandin bide'**
  String get giveFeedback;

  /// No description provided for @orLabel.
  ///
  /// In ku, this message translates to:
  /// **'an'**
  String get orLabel;

  /// No description provided for @homeLabel.
  ///
  /// In ku, this message translates to:
  /// **'Mal'**
  String get homeLabel;

  /// No description provided for @exploreLabel.
  ///
  /// In ku, this message translates to:
  /// **'Keşif Bike'**
  String get exploreLabel;

  /// No description provided for @savedLabel.
  ///
  /// In ku, this message translates to:
  /// **'Parastî'**
  String get savedLabel;

  /// No description provided for @noContentsFoundLabel.
  ///
  /// In ku, this message translates to:
  /// **'Naverok nehatin dîtin'**
  String get noContentsFoundLabel;

  /// No description provided for @noSearchResultsLabel.
  ///
  /// In ku, this message translates to:
  /// **'Encamên lêgerînê nehatin dîtin'**
  String get noSearchResultsLabel;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'ku': return SKu();
    case 'tr': return STr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
