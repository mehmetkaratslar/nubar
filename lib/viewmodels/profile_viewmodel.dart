// Dosya: lib/viewmodels/profile_viewmodel.dart
// Amaç: Kullanıcı profil bilgilerini ve paylaşımlarını yönetir.
// Bağlantı: profile_screen.dart, edit_profile_screen.dart, content_detail_screen.dart ile çalışır.
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/content_model.dart';

class ProfileViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<ContentModel> _contents = [];
  Map<String, dynamic>? _user;
  List<String> _savedContentIds = [];

  ProfileViewModel(this._firestoreService);

  List<ContentModel> get contents => _contents;
  Map<String, dynamic>? get user => _user;
  List<String> get savedContentIds => _savedContentIds;

  // Kullanıcı profilini yükler
  Future<void> loadUserProfile(String userId) async {
    _user = await _firestoreService.getUserData(userId);
    notifyListeners();
  }

  // Kullanıcının paylaşımlarını yükler
  Future<void> loadUserContents(String userId) async {
    final data = await _firestoreService.getContents();
    _contents = data
        .map((map) => ContentModel.fromMap(map, map['id']))
        .where((content) => content.userId == userId)
        .toList();
    notifyListeners();
  }

  // Kullanıcının kaydedilen içeriklerini yükler
  Future<void> loadSavedContents(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data();
      _savedContentIds = data != null && data['savedContents'] != null
          ? List<String>.from(data['savedContents'])
          : [];
      notifyListeners();
    } catch (e) {
      print('Kaydedilen içerikler yüklenirken hata: $e');
    }
  }

  // İçeriği kaydetme/kaldırma
  Future<void> toggleSaveContent(String userId, String contentId) async {
    try {
      await loadSavedContents(userId);
      if (_savedContentIds.contains(contentId)) {
        _savedContentIds.remove(contentId);
      } else {
        _savedContentIds.add(contentId);
      }
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'savedContents': _savedContentIds,
      });
      notifyListeners();
    } catch (e) {
      print('İçerik kaydetme/kaldırma hatası: $e');
    }
  }

  // Profil fotoğrafını günceller
  Future<String?> updateProfilePhoto(String userId, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('profile_photos/$userId.jpg');
      await storageRef.putFile(imageFile);
      final photoUrl = await storageRef.getDownloadURL();
      await _firestoreService.updateUserProfile(userId, {'photoUrl': photoUrl});
      _user?['photoUrl'] = photoUrl;
      notifyListeners();
      return photoUrl;
    } catch (e) {
      print('Fotoğraf güncelleme hatası: $e');
      return null;
    }
  }

  // Profil bilgilerini günceller
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateUserProfile(userId, data);
      _user = {...?_user, ...data};
      notifyListeners();
      return true;
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      return false;
    }
  }

  // Medya URL’lerini kullanma
  List<String> getMediaUrls(String contentId) {
    final content = _contents.firstWhere(
          (c) => c.id == contentId,
      orElse: () => ContentModel(
        id: '',
        title: '',
        description: '',
        category: '',
        language: '',
        userId: '',
        authorName: '',
        isFeatured: false,
        viewCount: 0,
        likeCount: 0,
        commentCount: 0,
      ),
    );
    return content.mediaUrls ?? [];
  }
}