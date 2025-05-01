// Dosya: lib/viewmodels/profile_viewmodel.dart
// Amaç: Kullanıcı profil işlemlerini yönetir.
// Bağlantı: profile_screen.dart, edit_profile_screen.dart ile entegre çalışır, FirestoreService ve StorageService ile veri yönetimi yapar.
// Not: summary ve text parametreleri eklendi.

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/content_model.dart';
import '../models/content_status.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/service_exception.dart';

class ProfileViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  String? _userId;
  String? _userDisplayName;
  String? _userPhotoUrl;
  String? _bio;
  List<ContentModel> _userContents = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProfileViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  String? get userId => _userId;
  String? get userDisplayName => _userDisplayName;
  String? get userPhotoUrl => _userPhotoUrl;
  String? get bio => _bio;
  List<ContentModel> get userContents => _userContents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Kullanıcı profilini yükler
  Future<void> loadProfile(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      _userId = userId;
      final userData = await _firestoreService.getUserData(userId);
      if (userData != null) {
        _userDisplayName = userData['displayName'];
        _userPhotoUrl = userData['photoUrl'];
        _bio = userData['bio'];
      }
      await loadUserContents(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı içeriklerini yükler
  Future<void> loadUserContents(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final contentDocs = await _firestoreService.getContents();
      _userContents = contentDocs
          .where((doc) => doc['userId'] == userId)
          .map((doc) => ContentModel.fromMap(doc, doc['id']))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Profil resmini günceller
  Future<void> updateProfilePhoto(File photo) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + photo.path.split('/').last;
      _userPhotoUrl = await _storageService.uploadFile('profile_photos/$fileName', photo);
      await _firestoreService.updateUserProfile(_userId!, {'photoUrl': _userPhotoUrl});
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Profili günceller
  Future<void> updateProfile({String? displayName, String? bio}) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final updatedData = <String, dynamic>{};
      if (displayName != null) {
        _userDisplayName = displayName;
        updatedData['displayName'] = displayName;
      }
      if (bio != null) {
        _bio = bio;
        updatedData['bio'] = bio;
      }
      await _firestoreService.updateUserProfile(_userId!, updatedData);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Yeni içerik oluşturur
  Future<void> createContent() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final content = ContentModel(
        id: '',
        title: 'Yeni İçerik',
        description: '',
        contentJson: null,
        category: 'history',
        mediaUrls: [],
        thumbnailUrl: null,
        userId: _userId!,
        userDisplayName: _userDisplayName!,
        authorName: _userDisplayName!,
        userPhotoUrl: _userPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        viewCount: 0,
        isFeatured: false,
        status: ContentStatus.draft,
        summary: 'Yeni içerik özeti', // Özet eklendi
        text: 'Yeni içerik metni', // Metin eklendi
      );
      await _firestoreService.createContent(content);
      await loadUserContents(_userId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}