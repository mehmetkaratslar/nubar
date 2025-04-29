// lib/generated/l10n.dart
// Otomatik oluşturulan lokalizasyon dosyası
// ARB dosyalarından intl paketi kullanılarak oluşturulur
// Not: Bu dosya normalde flutter gen-l10n komutunu kullanarak otomatik oluşturulur

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

<<<<<<< HEAD
import 'l10n/messages_all.dart';
=======
import '../l10n/messages_all.dart';
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

/// Uygulama için çoklu dil desteği sağlayan sınıf
class S {
  S();

  static S current = S();

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S current = S();
      return current;
    });
  }

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S) ?? S();
  }

  // Uygulama adı ve açıklaması
  String get appName => Intl.message('Nûbar', name: 'appName');
  String get appDescription => Intl.message('Kurdish Cultural Platform', name: 'appDescription');

  // Genel
  String get ok => Intl.message('OK', name: 'ok');
  String get cancel => Intl.message('Cancel', name: 'cancel');
  String get save => Intl.message('Save', name: 'save');
  String get delete => Intl.message('Delete', name: 'delete');
  String get edit => Intl.message('Edit', name: 'edit');
  String get share => Intl.message('Share', name: 'share');
  String get search => Intl.message('Search', name: 'search');
  String get loading => Intl.message('Loading...', name: 'loading');
  String get retry => Intl.message('Retry', name: 'retry');
  String get error => Intl.message('Error', name: 'error');
  String get success => Intl.message('Success', name: 'success');
  String get warning => Intl.message('Warning', name: 'warning');
  String get info => Intl.message('Information', name: 'info');
  String get confirm => Intl.message('Confirm', name: 'confirm');
  String get close => Intl.message('Close', name: 'close');
  String get next => Intl.message('Next', name: 'next');
  String get previous => Intl.message('Previous', name: 'previous');
  String get back => Intl.message('Back', name: 'back');
  String get readMore => Intl.message('Read More', name: 'readMore');
  String get seeAll => Intl.message('See All', name: 'seeAll');
  String get submit => Intl.message('Submit', name: 'submit');
  String get required => Intl.message('Required', name: 'required');
  String get optional => Intl.message('Optional', name: 'optional');
  String get all => Intl.message('All', name: 'all');
  String get or => Intl.message('or', name: 'or');
  String get noSearchResults => Intl.message('No search results found', name: 'noSearchResults');
  String get noContents => Intl.message('No contents available', name: 'noContents');

  // Kimlik doğrulama
  String get login => Intl.message('Log In', name: 'login');
  String get signup => Intl.message('Sign Up', name: 'signup');
  String get logout => Intl.message('Log Out', name: 'logout');
  String get email => Intl.message('Email', name: 'email');
  String get password => Intl.message('Password', name: 'password');
  String get confirmPassword => Intl.message('Confirm Password', name: 'confirmPassword');
  String get username => Intl.message('Username', name: 'username');
  String get forgotPassword => Intl.message('Forgot Password', name: 'forgotPassword');
  String get resetPassword => Intl.message('Reset Password', name: 'resetPassword');
  String get createAccount => Intl.message('Create Account', name: 'createAccount');
  String get alreadyHaveAccount => Intl.message('Already have an account? Log in', name: 'alreadyHaveAccount');
  String get dontHaveAccount => Intl.message('Don\'t have an account? Sign up', name: 'dontHaveAccount');

  String loginWith(String provider) {
    return Intl.message(
      'Log in with $provider',
      name: 'loginWith',
      args: [provider],
    );
  }

  String signupWith(String provider) {
    return Intl.message(
      'Sign up with $provider',
      name: 'signupWith',
      args: [provider],
    );
  }

  // Profil
  String get profile => Intl.message('Profile', name: 'profile');
  String get editProfile => Intl.message('Edit Profile', name: 'editProfile');
  String get bio => Intl.message('Biography', name: 'bio');
  String get changePhoto => Intl.message('Change Photo', name: 'changePhoto');
  String get changePassword => Intl.message('Change Password', name: 'changePassword');
  String get accountSettings => Intl.message('Account Settings', name: 'accountSettings');
  String get savedContents => Intl.message('Saved Contents', name: 'savedContents');
  String get likedContents => Intl.message('Liked Contents', name: 'likedContents');
  String get myComments => Intl.message('My Comments', name: 'myComments');

  String joinedOn(String date) {
    return Intl.message(
      'Joined on $date',
      name: 'joinedOn',
      args: [date],
    );
  }

  // İçerik
  String get categories => Intl.message('Categories', name: 'categories');
  String get history => Intl.message('History', name: 'history');
  String get language => Intl.message('Language', name: 'language');
  String get art => Intl.message('Art', name: 'art');
  String get music => Intl.message('Music', name: 'music');
  String get traditions => Intl.message('Traditions', name: 'traditions');
  String get featuredContents => Intl.message('Featured Contents', name: 'featuredContents');
  String get recentContents => Intl.message('Recent Contents', name: 'recentContents');
  String get popularContents => Intl.message('Popular Contents', name: 'popularContents');
  String get contentDetails => Intl.message('Content Details', name: 'contentDetails');
  String get likes => Intl.message('Likes', name: 'likes');
  String get comments => Intl.message('Comments', name: 'comments');
  String get views => Intl.message('Views', name: 'views');
  String get addComment => Intl.message('Add Comment', name: 'addComment');
  String get writeComment => Intl.message('Write a comment...', name: 'writeComment');
<<<<<<< HEAD
=======
  String get contentNotFound => Intl.message('Content not found', name: 'contentNotFound');
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

  String publishedOn(String date) {
    return Intl.message(
      'Published on $date',
      name: 'publishedOn',
      args: [date],
    );
  }

  String createdBy(String username) {
    return Intl.message(
      'Created by $username',
      name: 'createdBy',
      args: [username],
    );
  }

  String lastEdited(String date) {
    return Intl.message(
      'Last edited on $date',
      name: 'lastEdited',
      args: [date],
    );
  }

  // Kategori açıklamaları
  String get historyDescription => Intl.message('Kurdish history information, events, and important figures.', name: 'historyDescription');
  String get languageDescription => Intl.message('Kurdish grammar, words, expressions and dialects.', name: 'languageDescription');
  String get artDescription => Intl.message('Kurdish art, literature, poetry and painting.', name: 'artDescription');
  String get musicDescription => Intl.message('Kurdish music, songs, instruments and artists.', name: 'musicDescription');
  String get traditionsDescription => Intl.message('Kurdish cultural traditions, celebrations and lifestyle.', name: 'traditionsDescription');

  // Editör
  String get editor => Intl.message('Editor', name: 'editor');
  String get editorDashboard => Intl.message('Editor Dashboard', name: 'editorDashboard');
  String get createContent => Intl.message('Create Content', name: 'createContent');
  String get editContent => Intl.message('Edit Content', name: 'editContent');
  String get contentTitle => Intl.message('Content Title', name: 'contentTitle');
  String get contentSummary => Intl.message('Content Summary', name: 'contentSummary');
  String get contentText => Intl.message('Content Text', name: 'contentText');
  String get contentCategory => Intl.message('Content Category', name: 'contentCategory');
<<<<<<< HEAD
  String get contentType => Intl.message('Content Type', name: 'contentType');
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  String get contentTags => Intl.message('Content Tags', name: 'contentTags');
  String get addTags => Intl.message('Add Tags', name: 'addTags');
  String get uploadMedia => Intl.message('Upload Media', name: 'uploadMedia');
  String get uploadThumbnail => Intl.message('Upload Thumbnail', name: 'uploadThumbnail');
  String get savedAsDraft => Intl.message('Saved as Draft', name: 'savedAsDraft');
  String get publish => Intl.message('Publish', name: 'publish');
  String get unpublish => Intl.message('Unpublish', name: 'unpublish');
  String get draft => Intl.message('Draft', name: 'draft');
  String get published => Intl.message('Published', name: 'published');
  String get archived => Intl.message('Archived', name: 'archived');
<<<<<<< HEAD
  String get pending => Intl.message('Pending', name: 'pending');
  String get publishedContents => Intl.message('Published Contents', name: 'publishedContents');
  String get draftContents => Intl.message('Draft Contents', name: 'draftContents');
  String get moderationQueue => Intl.message('Moderation Queue', name: 'moderationQueue');
  String get reportedContents => Intl.message('Reported Contents', name: 'reportedContents');
  String get reportedComments => Intl.message('Reported Comments', name: 'reportedComments');

  // Reports
=======

  // Report
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  String get report => Intl.message('Report', name: 'report');
  String get reportContent => Intl.message('Report Content', name: 'reportContent');
  String get reportComment => Intl.message('Report Comment', name: 'reportComment');
  String get reportReason => Intl.message('Report Reason', name: 'reportReason');
  String get reportDescription => Intl.message('Description', name: 'reportDescription');
  String get inappropriate => Intl.message('Inappropriate Content', name: 'inappropriate');
  String get spam => Intl.message('Spam', name: 'spam');
  String get offensive => Intl.message('Offensive/Abusive', name: 'offensive');
  String get violence => Intl.message('Violence', name: 'violence');
  String get copyright => Intl.message('Copyright Violation', name: 'copyright');
  String get other => Intl.message('Other', name: 'other');
  String get thanksForReporting => Intl.message('Thank you for reporting. We will review this soon.', name: 'thanksForReporting');

<<<<<<< HEAD
  // Settings
  String get settings => Intl.message('Settings', name: 'settings');
  String get general => Intl.message('General', name: 'general');
  String get account => Intl.message('Account', name: 'account');
  String get notifications => Intl.message('Notifications', name: 'notifications');
  String get privacy => Intl.message('Privacy', name: 'privacy');
  String get helpAndSupport => Intl.message('Help & Support', name: 'helpAndSupport');
  String get about => Intl.message('About', name: 'about');
  String get termsOfService => Intl.message('Terms of Service', name: 'termsOfService');
  String get privacyPolicy => Intl.message('Privacy Policy', name: 'privacyPolicy');
  String get contactUs => Intl.message('Contact Us', name: 'contactUs');
  String get feedback => Intl.message('Feedback', name: 'feedback');
  String get theme => Intl.message('Theme', name: 'theme');
  String get darkMode => Intl.message('Dark Mode', name: 'darkMode');
  String get lightMode => Intl.message('Light Mode', name: 'lightMode');
  String get systemDefault => Intl.message('System Default', name: 'systemDefault');

  // Languages
  String get kurdishKurmanji => Intl.message('Kurdî (Kurmancî)', name: 'kurdishKurmanji');
  String get turkish => Intl.message('Türkçe', name: 'turkish');
=======
  // Languages
  String get kurdishKurmanji => Intl.message('Kurdish (Kurmanji)', name: 'kurdishKurmanji');
  String get turkish => Intl.message('Turkish', name: 'turkish');
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  String get english => Intl.message('English', name: 'english');
  String get selectLanguage => Intl.message('Select Language', name: 'selectLanguage');

  String languageChanged(String language) {
    return Intl.message(
      'Language changed to $language',
      name: 'languageChanged',
      args: [language],
    );
  }

<<<<<<< HEAD
  // Error Messages
  String get networkError => Intl.message('Please check your internet connection and try again.', name: 'networkError');
  String get generalError => Intl.message('An error occurred. Please try again later.', name: 'generalError');
  String get authError => Intl.message('There was an error logging in. Please try again.', name: 'authError');
  String get invalidEmail => Intl.message('Please enter a valid email address.', name: 'invalidEmail');
  String get weakPassword => Intl.message('Password must be at least 6 characters.', name: 'weakPassword');
  String get passwordMismatch => Intl.message('Passwords do not match.', name: 'passwordMismatch');
  String get requiredField => Intl.message('This field is required.', name: 'requiredField');
  String get uploadError => Intl.message('An error occurred while uploading the file.', name: 'uploadError');
  String get contentLoadError => Intl.message('An error occurred while loading content.', name: 'contentLoadError');
  String get contentCreateError => Intl.message('An error occurred while creating content.', name: 'contentCreateError');
  String get commentError => Intl.message('An error occurred while sending your comment.', name: 'commentError');
  String get permissionDenied => Intl.message('You don\'t have permission to perform this action.', name: 'permissionDenied');

=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  // Splash Screen
  String get welcomeToNubar => Intl.message('Welcome to Nûbar', name: 'welcomeToNubar');
  String get discoverKurdishCulture => Intl.message('Discover Kurdish Culture', name: 'discoverKurdishCulture');
  String get getStarted => Intl.message('Get Started', name: 'getStarted');
<<<<<<< HEAD

  // Help and Support
  String get frequentlyAskedQuestions => Intl.message('Frequently Asked Questions', name: 'frequentlyAskedQuestions');
  String get howToUse => Intl.message('How to Use', name: 'howToUse');
  String get contactSupport => Intl.message('Contact Support', name: 'contactSupport');
  String get reportIssue => Intl.message('Report an Issue', name: 'reportIssue');
  String get giveFeedback => Intl.message('Give Feedback', name: 'giveFeedback');
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
}

/// Uygulama için lokalizasyon delegasyonu
class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ku'), // Kürtçe (Kurmanci)
      Locale.fromSubtags(languageCode: 'tr'), // Türkçe
      Locale.fromSubtags(languageCode: 'en'), // İngilizce
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
<<<<<<< HEAD
}

// Bu dosya gerçek l10n işlemleri için bir simülasyondur.
// Gerçek uygulamada bu dosya flutter gen-l10n komutuyla otomatik olarak oluşturulur
// Burada messages_all.dart dosyası da simüle edilmiştir.

// Simülasyon amacıyla oluşturulan fonksiyon
Future<bool> initializeMessages(String localeName) async {
  return Future.value(true);
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
}