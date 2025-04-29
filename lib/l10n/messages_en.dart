// lib/l10n/messages_en.dart
// İngilizce dil desteği için oluşturulan mesaj dosyası
// Bu dosya normalde Flutter gen-l10n komutu tarafından otomatik oluşturulur
// Şu an için temel mesajlar manuel olarak eklenmiştir

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookupByLibrary();

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'en';

  final messages = _notInlinedMessages();
  static Map<String, Function> _notInlinedMessages() => <String, Function>{
    // Genel mesajlar
    'appName': () => 'Nûbar',
    'appDescription': () => 'Kurdish Cultural Platform',
    'ok': () => 'OK',
    'cancel': () => 'Cancel',
    'save': () => 'Save',
    'delete': () => 'Delete',
    'edit': () => 'Edit',
    'share': () => 'Share',
    'search': () => 'Search',
    'loading': () => 'Loading...',
    'retry': () => 'Retry',
    'error': () => 'Error',
    'success': () => 'Success',
    'warning': () => 'Warning',
    'info': () => 'Information',
    'confirm': () => 'Confirm',
    'close': () => 'Close',
    'next': () => 'Next',
    'previous': () => 'Previous',
    'back': () => 'Back',
    'readMore': () => 'Read More',
    'seeAll': () => 'See All',
    'submit': () => 'Submit',
    'required': () => 'Required',
    'optional': () => 'Optional',
    'all': () => 'All',
    'or': () => 'or',
    'noSearchResults': () => 'No search results found',
    'noContents': () => 'No contents available',

    // Kimlik doğrulama
    'login': () => 'Log In',
    'signup': () => 'Sign Up',
    'logout': () => 'Log Out',
    'email': () => 'Email',
    'password': () => 'Password',
    'confirmPassword': () => 'Confirm Password',
    'username': () => 'Username',
    'forgotPassword': () => 'Forgot Password',
    'resetPassword': () => 'Reset Password',
    'createAccount': () => 'Create Account',
    'alreadyHaveAccount': () => 'Already have an account? Log in',
    'dontHaveAccount': () => 'Don\'t have an account? Sign up',

    // Profil
    'profile': () => 'Profile',
    'editProfile': () => 'Edit Profile',
    'bio': () => 'Biography',
    'changePhoto': () => 'Change Photo',
    'changePassword': () => 'Change Password',
    'accountSettings': () => 'Account Settings',
    'savedContents': () => 'Saved Contents',
    'likedContents': () => 'Liked Contents',
    'myComments': () => 'My Comments',

    // İçerik
    'categories': () => 'Categories',
    'history': () => 'History',
    'language': () => 'Language',
    'art': () => 'Art',
    'music': () => 'Music',
    'traditions': () => 'Traditions',
    'featuredContents': () => 'Featured Contents',
    'recentContents': () => 'Recent Contents',
    'popularContents': () => 'Popular Contents',
    'contentDetails': () => 'Content Details',
    'likes': () => 'Likes',
    'comments': () => 'Comments',
    'views': () => 'Views',
    'addComment': () => 'Add Comment',
    'writeComment': () => 'Write a comment...',
    'contentNotFound': () => 'Content not found',

    // Editör
    'editor': () => 'Editor',
    'editorDashboard': () => 'Editor Dashboard',
    'createContent': () => 'Create Content',
    'editContent': () => 'Edit Content',
    'contentTitle': () => 'Content Title',
    'contentSummary': () => 'Content Summary',
    'contentText': () => 'Content Text',
    'contentCategory': () => 'Content Category',
    'contentTags': () => 'Content Tags',
    'addTags': () => 'Add Tags',
    'uploadMedia': () => 'Upload Media',
    'uploadThumbnail': () => 'Upload Thumbnail',
    'savedAsDraft': () => 'Saved as Draft',
    'publish': () => 'Publish',
    'unpublish': () => 'Unpublish',
    'draft': () => 'Draft',
    'published': () => 'Published',
    'archived': () => 'Archived',

    // Report
    'report': () => 'Report',
    'reportContent': () => 'Report Content',
    'reportComment': () => 'Report Comment',
    'reportReason': () => 'Report Reason',
    'reportDescription': () => 'Description',
    'inappropriate': () => 'Inappropriate Content',
    'spam': () => 'Spam',
    'offensive': () => 'Offensive/Abusive',
    'violence': () => 'Violence',
    'copyright': () => 'Copyright Violation',
    'other': () => 'Other',
    'thanksForReporting': () => 'Thank you for reporting. We will review this soon.',

    // Languages
    'kurdishKurmanji': () => 'Kurdish (Kurmanji)',
    'turkish': () => 'Turkish',
    'english': () => 'English',
    'selectLanguage': () => 'Select Language',

    // Splash Screen
    'welcomeToNubar': () => 'Welcome to Nûbar',
    'discoverKurdishCulture': () => 'Discover Kurdish Culture',
    'getStarted': () => 'Get Started',

    // Categories descriptions
    'historyDescription': () => 'Kurdish history information, events, and important figures.',
    'languageDescription': () => 'Kurdish grammar, words, expressions and dialects.',
    'artDescription': () => 'Kurdish art, literature, poetry and painting.',
    'musicDescription': () => 'Kurdish music, songs, instruments and artists.',
    'traditionsDescription': () => 'Kurdish cultural traditions, celebrations and lifestyle.',
  };
}