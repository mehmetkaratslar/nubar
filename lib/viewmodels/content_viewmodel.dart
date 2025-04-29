import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/content_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ContentViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  ContentModel? _currentContent;
  List<ContentModel> _relatedContents = [];
  List<Map<String, dynamic>> _comments = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isLiked = false;
  bool _isSaved = false;

  ContentViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  ContentModel? get currentContent => _currentContent;
  List<ContentModel> get relatedContents => _relatedContents;
  List<Map<String, dynamic>> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isLiked => _isLiked;
  bool get isSaved => _isSaved;

  // İçerik detaylarını yükle
  Future<void> loadContent(String contentId, String userId) async {
    try {
      _setLoading(true);

      // İçerik bilgilerini getir
      _currentContent = await _firestoreService.getContentById(contentId);

      if (_currentContent != null) {
        // İlgili içerikleri getir (aynı kategoriden)
        await _loadRelatedContents(_currentContent!.category);

        // Yorumları getir
        await _loadComments(contentId);

        // Kullanıcının beğeni durumunu kontrol et
        _isLiked = await _firestoreService.isContentLikedByUser(contentId, userId);

        // Kullanıcının kaydetme durumunu kontrol et (sadece UI güncellemesi için)
        // Bu değer gerçek kayıtlı durumu yansıtmayabilir, profile_viewmodel içinde gerçek durum kontrol edilmelidir
        _isSaved = false; // Varsayılan değer

        _errorMessage = null;
      } else {
        _errorMessage = 'İçerik bulunamadı';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerik yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // İlgili içerikleri yükle
  Future<void> _loadRelatedContents(String category) async {
    try {
      // Aynı kategoriden benzer içerikleri getir
      List<ContentModel> contents = await _firestoreService.getContentsByCategory(
        category,
        limit: 5,
      );

      // Mevcut içeriği listeden çıkar (eğer varsa)
      if (_currentContent != null) {
        contents = contents.where((content) => content.id != _currentContent!.id).toList();
      }

      _relatedContents = contents;
    } catch (e) {
      print('İlgili içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Yorumları yükle
  Future<void> _loadComments(String contentId) async {
    try {
      _comments = await _firestoreService.getCommentsForContent(contentId);
    } catch (e) {
      print('Yorumlar yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Yorum ekle
  Future<bool> addComment(String contentId, String userId, String text) async {
    if (text.trim().isEmpty) return false;

    try {
      _setSubmitting(true);

      String commentId = await _firestoreService.addComment(contentId, userId, text);

      // Yorumları yeniden yükle
      await _loadComments(contentId);

      // Mevcut içeriğin yorum sayısını güncelle
      if (_currentContent != null) {
        _currentContent = _currentContent!.copyWith(
          commentCount: _currentContent!.commentCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yorum eklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Yorum sil
  Future<bool> deleteComment(String contentId, String commentId) async {
    try {
      _setSubmitting(true);

      await _firestoreService.deleteComment(contentId, commentId);

      // Yorumları yeniden yükle
      await _loadComments(contentId);

      // Mevcut içeriğin yorum sayısını güncelle
      if (_currentContent != null) {
        _currentContent = _currentContent!.copyWith(
          commentCount: _currentContent!.commentCount - 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yorum silinirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik beğen/beğeni kaldır
  Future<bool> toggleLike(String contentId, String userId) async {
    try {
      _setSubmitting(true);

      await _firestoreService.toggleLikeContent(contentId, userId);

      // Beğeni durumunu güncelle
      _isLiked = !_isLiked;

      // Mevcut içeriğin beğeni sayısını güncelle
      if (_currentContent != null) {
        _currentContent = _currentContent!.copyWith(
          likeCount: _isLiked
              ? _currentContent!.likeCount + 1
              : _currentContent!.likeCount - 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Beğeni işlemi sırasında hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Yeni içerik oluştur
  Future<String?> createContent({
    required String title,
    required String content,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String category,
    required String language,
    List<File>? mediaFiles,
    Map<String, dynamic>? translatedTitles,
    Map<String, dynamic>? translatedContents,
  }) async {
    try {
      _setSubmitting(true);

      List<String>? mediaUrls;
      String? thumbnailUrl;

      // Medya dosyalarını yükle (eğer varsa)
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        mediaUrls = [];

        for (int i = 0; i < mediaFiles.length; i++) {
          String fileName = 'contents/${userId}_${DateTime.now().millisecondsSinceEpoch}_$i';
          Reference ref = _storage.ref().child(fileName);

          await ref.putFile(mediaFiles[i]);
          String url = await ref.getDownloadURL();

          mediaUrls.add(url);

          // İlk dosyayı thumbnail olarak kullan
          if (i == 0) {
            thumbnailUrl = url;
          }
        }
      }

      // İçerik nesnesi oluştur
      ContentModel newContent = ContentModel(
        id: '', // Firestore oluştururken ata
        title: title,
        content: content,
        userId: userId,
        userDisplayName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        category: category,
        language: language,
        mediaUrls: mediaUrls,
        thumbnailUrl: thumbnailUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        isFeatured: false,
        isPublished: true,
        translatedTitles: translatedTitles,
        translatedContents: translatedContents,
      );

      // İçeriği Firestore'a kaydet
      String contentId = await _firestoreService.createContent(newContent);

      return contentId;
    } catch (e) {
      _errorMessage = 'İçerik oluşturulurken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik güncelle
  Future<bool> updateContent({
    required String contentId,
    String? title,
    String? content,
    String? category,
    String? language,
    List<File>? newMediaFiles,
    List<String>? removeMediaUrls,
    String? thumbnailUrl,
    Map<String, dynamic>? translatedTitles,
    Map<String, dynamic>? translatedContents,
  }) async {
    try {
      _setSubmitting(true);

      // Önce mevcut içeriği al
      ContentModel? existingContent = await _firestoreService.getContentById(contentId);
      if (existingContent == null) {
        _errorMessage = 'İçerik bulunamadı';
        return false;
      }

      List<String> updatedMediaUrls = List<String>.from(existingContent.mediaUrls ?? []);

      // Kaldırılacak medya dosyalarını işle
      if (removeMediaUrls != null && removeMediaUrls.isNotEmpty) {
        for (String url in removeMediaUrls) {
          // Storage'dan dosyayı sil
          try {
            Reference ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print('Medya dosyası silinirken hata oluştu: ${e.toString()}');
            // İşlem devam etsin
          }

          // URL'yi listeden kaldır
          updatedMediaUrls.remove(url);
        }
      }

      // Yeni medya dosyalarını yükle
      if (newMediaFiles != null && newMediaFiles.isNotEmpty) {
        for (int i = 0; i < newMediaFiles.length; i++) {
          String fileName = 'contents/${existingContent.userId}_${DateTime.now().millisecondsSinceEpoch}_$i';
          Reference ref = _storage.ref().child(fileName);

          await ref.putFile(newMediaFiles[i]);
          String url = await ref.getDownloadURL();

          updatedMediaUrls.add(url);
        }
      }

      // Thumbnail URL'yi güncelle
      String? updatedThumbnailUrl = thumbnailUrl;
      if (updatedThumbnailUrl == null && updatedMediaUrls.isNotEmpty) {
        // Eğer thumbnail belirtilmemişse ve medya dosyaları varsa, ilk dosyayı kullan
        updatedThumbnailUrl = updatedMediaUrls.first;
      }

      // Güncellenecek alanları topla
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (category != null) updates['category'] = category;
      if (language != null) updates['language'] = language;
      if (updatedMediaUrls.isNotEmpty) updates['mediaUrls'] = updatedMediaUrls;
      if (updatedThumbnailUrl != null) updates['thumbnailUrl'] = updatedThumbnailUrl;
      if (translatedTitles != null) updates['translatedTitles'] = translatedTitles;
      if (translatedContents != null) updates['translatedContents'] = translatedContents;

      // İçeriği güncelle
      await _firestoreService.updateContent(contentId, updates);

      // Mevcut içeriği güncelle
      if (_currentContent != null && _currentContent!.id == contentId) {
        _currentContent = ContentModel.fromMap({
          ..._currentContent!.toMap(),
          ...updates,
        }, contentId);

        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'İçerik güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik sil
  Future<bool> deleteContent(String contentId) async {
    try {
      _setSubmitting(true);

      // Önce mevcut içeriği al
      ContentModel? content = await _firestoreService.getContentById(contentId);
      if (content == null) {
        _errorMessage = 'İçerik bulunamadı';
        return false;
      }

      // Medya dosyalarını sil
      if (content.mediaUrls != null && content.mediaUrls!.isNotEmpty) {
        for (String url in content.mediaUrls!) {
          try {
            Reference ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print('Medya dosyası silinirken hata oluştu: ${e.toString()}');
            // İşlem devam etsin
          }
        }
      }

      // İçeriği sil
      await _firestoreService.deleteContent(contentId);

      // İlgili içerikleri güncelle
      if (_currentContent != null && _currentContent!.id == contentId) {
        _currentContent = null;
        _comments = [];

        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'İçerik silinirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Kategori bazında içerikleri getir
  Future<List<ContentModel>> getContentsByCategory(
      String category, {
        String? language,
        int limit = 20,
      }) async {
    try {
      _setLoading(true);

      List<ContentModel> contents = await _firestoreService.getContentsByCategory(
        category,
        language: language,
        limit: limit,
      );

      _setLoading(false);
      return contents;
    } catch (e) {
      _errorMessage = 'İçerikler yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      _setLoading(false);
      return [];
    }
  }

  // Öne çıkan içerikleri getir
  Future<List<ContentModel>> getFeaturedContents({
    String? language,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);

      List<ContentModel> contents = await _firestoreService.getFeaturedContents(
        language: language,
        limit: limit,
      );

      _setLoading(false);
      return contents;
    } catch (e) {
      _errorMessage = 'Öne çıkan içerikler yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      _setLoading(false);
      return [];
    }
  }

  // Loading durumunu ayarla
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Submitting durumunu ayarla
  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}