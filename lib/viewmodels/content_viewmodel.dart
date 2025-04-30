// Dosya: lib/viewmodels/content_viewmodel.dart
// Amaç: İçerik işlemlerini yönetir (listeleme, alma, beğenme, yorumlama).
// Bağlantı: content_detail_screen.dart, home_screen.dart ile çalışır.
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/content_model.dart';
import '../models/comment_model.dart';

class ContentViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<ContentModel> _contents = [];
  List<ContentModel> _featuredContents = [];
  ContentModel? _selectedContent;
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isLiked = false;

  ContentViewModel(this._firestoreService);

  List<ContentModel> get contents => _contents;
  List<ContentModel> get featuredContents => _featuredContents;
  ContentModel? get currentContent => _selectedContent;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isLiked => _isLiked;

  // Tüm içerikleri çeker
  Future<void> fetchContents() async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContents();
      _contents = data.map((map) => ContentModel.fromMap(map, map['id'])).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenemedi: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Öne çıkan içerikleri çeker
  Future<void> fetchFeaturedContents() async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContents();
      _featuredContents = data
          .map((map) => ContentModel.fromMap(map, map['id']))
          .where((content) => content.isFeatured)
          .take(5)
          .toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Öne çıkan içerikler yüklenemedi: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // ID’ye göre içerik alır
  Future<ContentModel?> getContentById(String id) async {
    try {
      final data = await _firestoreService.getContentById(id);
      if (data != null) {
        return ContentModel.fromMap(data, id);
      }
      return null;
    } catch (e) {
      print('İçerik alma hatası: $e');
      return null;
    }
  }

  // ID’ye göre içerik yükler
  Future<void> loadContent(String id) async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContentById(id);
      if (data != null) {
        _selectedContent = ContentModel.fromMap(data, id);
        await FirebaseFirestore.instance.collection('contents').doc(id).update({
          'viewCount': (_selectedContent!.viewCount + 1),
        });
        _selectedContent = _selectedContent!.copyWith(
          viewCount: _selectedContent!.viewCount + 1,
        );
        await fetchComments(id);
      } else {
        _errorMessage = 'İçerik bulunamadı.';
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerik yüklenemedi: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriye göre içerikleri alır
  Future<void> getContentsByCategory(String category) async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContents();
      _contents = data
          .map((map) => ContentModel.fromMap(map, map['id']))
          .where((content) => content.category == category)
          .toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenemedi: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Yorumları yükler
  Future<void> fetchComments(String contentId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('contents')
          .doc(contentId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();
      _comments = snapshot.docs.map((doc) => CommentModel.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Yorumlar yüklenemedi: $e';
      print(_errorMessage);
    }
  }

  // Yeni içerik ekler
  Future<bool> addContent({
    required String title,
    required String description,
    required String category,
    required String language,
    File? imageFile,
    bool isFeatured = false,
    required String userId,
    required String authorName,
  }) async {
    try {
      _setLoading(true);
      String? imageUrl;
      if (imageFile != null) {
        String fileName = 'content_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final newContent = {
        'title': title,
        'description': description,
        'category': category,
        'language': language,
        'imageUrl': imageUrl,
        'userId': userId,
        'authorName': authorName,
        'isFeatured': isFeatured,
        'viewCount': 0,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await FirebaseFirestore.instance.collection('contents').add(newContent);
      final contentModel = ContentModel(
        id: docRef.id,
        title: title,
        description: description,
        category: category,
        language: language,
        imageUrl: imageUrl,
        userId: userId,
        authorName: authorName,
        isFeatured: isFeatured,
        viewCount: 0,
        likeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
      );

      _contents.insert(0, contentModel);
      if (isFeatured) {
        _featuredContents.insert(0, contentModel);
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik eklenirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik günceller
  Future<bool> updateContent({
    required String contentId,
    required String title,
    required String description,
    required String category,
    required String language,
    File? imageFile,
    bool? isFeatured,
  }) async {
    try {
      _setLoading(true);
      final existingContentIndex = _contents.indexWhere((c) => c.id == contentId);
      if (existingContentIndex == -1) {
        _errorMessage = 'Düzenlenecek içerik bulunamadı.';
        return false;
      }

      final existingContent = _contents[existingContentIndex];
      final updates = <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'language': language,
      };

      String? imageUrl = existingContent.imageUrl;
      if (imageFile != null) {
        String fileName = 'content_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
        updates['imageUrl'] = imageUrl;
      }

      if (isFeatured != null) {
        updates['isFeatured'] = isFeatured;
      }

      await FirebaseFirestore.instance.collection('contents').doc(contentId).update(updates);
      final updatedContent = existingContent.copyWith(
        title: title,
        description: description,
        category: category,
        language: language,
        imageUrl: imageUrl,
        isFeatured: isFeatured ?? existingContent.isFeatured,
      );

      _contents[existingContentIndex] = updatedContent;
      int featuredIndex = _featuredContents.indexWhere((c) => c.id == contentId);
      if (featuredIndex != -1) {
        if (isFeatured == false) {
          _featuredContents.removeAt(featuredIndex);
        } else {
          _featuredContents[featuredIndex] = updatedContent;
        }
      } else if (isFeatured == true) {
        _featuredContents.add(updatedContent);
      }

      if (_selectedContent?.id == contentId) {
        _selectedContent = updatedContent;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik güncellenirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik siler
  Future<bool> deleteContent(String contentId) async {
    try {
      _setLoading(true);
      await FirebaseFirestore.instance.collection('contents').doc(contentId).delete();
      _contents.removeWhere((content) => content.id == contentId);
      _featuredContents.removeWhere((content) => content.id == contentId);
      if (_selectedContent?.id == contentId) {
        _selectedContent = null;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik silinirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Yorum ekler
  Future<bool> addComment({
    required String contentId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    try {
      _setLoading(true);
      final newComment = {
        'userId': userId,
        'userName': userName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };
      DocumentReference commentRef = await FirebaseFirestore.instance
          .collection('contents')
          .doc(contentId)
          .collection('comments')
          .add(newComment);
      await FirebaseFirestore.instance.collection('contents').doc(contentId).update({
        'commentCount': FieldValue.increment(1),
      });
      final commentModel = CommentModel(
        id: commentRef.id,
        userId: userId,
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      );
      _comments.insert(0, commentModel);
      int index = _contents.indexWhere((content) => content.id == contentId);
      if (index != -1) {
        _contents[index] = _contents[index].copyWith(
          commentCount: _contents[index].commentCount + 1,
        );
      }
      int featuredIndex = _featuredContents.indexWhere((content) => content.id == contentId);
      if (featuredIndex != -1) {
        _featuredContents[featuredIndex] = _featuredContents[featuredIndex].copyWith(
          commentCount: _featuredContents[featuredIndex].commentCount + 1,
        );
      }
      if (_selectedContent?.id == contentId) {
        _selectedContent = _selectedContent!.copyWith(
          commentCount: _selectedContent!.commentCount + 1,
        );
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yorum eklenirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Beğenme durumunu değiştirir
  Future<bool> toggleLike(String contentId, String userId) async {
    try {
      DocumentSnapshot userLikeDoc = await FirebaseFirestore.instance
          .collection('contents')
          .doc(contentId)
          .collection('likes')
          .doc(userId)
          .get();
      bool isLiked = userLikeDoc.exists;
      int likeChange = isLiked ? -1 : 1;
      if (isLiked) {
        await FirebaseFirestore.instance
            .collection('contents')
            .doc(contentId)
            .collection('likes')
            .doc(userId)
            .delete();
        _isLiked = false;
      } else {
        await FirebaseFirestore.instance
            .collection('contents')
            .doc(contentId)
            .collection('likes')
            .doc(userId)
            .set({'createdAt': FieldValue.serverTimestamp()});
        _isLiked = true;
      }
      await FirebaseFirestore.instance.collection('contents').doc(contentId).update({
        'likeCount': FieldValue.increment(likeChange),
      });
      _updateLikeStatus(contentId, likeChange);
      notifyListeners();
      return true;
    } catch (e) {
      print('Beğeni işlemi sırasında hata oluştu: $e');
      return false;
    }
  }

  // Beğeni durumunu yerel olarak günceller
  void _updateLikeStatus(String contentId, int likeChange) {
    int index = _contents.indexWhere((content) => content.id == contentId);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(
        likeCount: _contents[index].likeCount + likeChange,
      );
    }
    int featuredIndex = _featuredContents.indexWhere((content) => content.id == contentId);
    if (featuredIndex != -1) {
      _featuredContents[featuredIndex] = _featuredContents[featuredIndex].copyWith(
        likeCount: _featuredContents[featuredIndex].likeCount + likeChange,
      );
    }
    if (_selectedContent?.id == contentId) {
      _selectedContent = _selectedContent!.copyWith(
        likeCount: _selectedContent!.likeCount + likeChange,
      );
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // Hata mesajını temizler
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}