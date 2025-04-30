// Dosya: lib/viewmodels/editor_viewmodel.dart
// Amaç: Editör işlemlerini (taslak oluşturma, düzenleme, şikayet yönetimi) yönetir.
// Bağlantı: editor_dashboard.dart, content_editor_screen.dart ile çalışır.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/content_model.dart';
import '../models/report_model.dart';

class EditorViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<ContentModel> _draftContents = [];
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  int likeCount = 0;
  int commentCount = 0;

  EditorViewModel();

  List<ContentModel> get draftContents => _draftContents;
  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Taslak içerik listesini getir
  Future<void> fetchDraftContents() async {
    try {
      _setLoading(true);
      QuerySnapshot snapshot = await _firestore
          .collection('drafts')
          .orderBy('createdAt', descending: true)
          .get();
      _draftContents = snapshot.docs.map((doc) {
        return ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Taslaklar yüklenirken hata oluştu: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Şikayetleri getir
  Future<void> fetchReports() async {
    try {
      _setLoading(true);
      QuerySnapshot snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();
      _reports = snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Şikayetler yüklenirken hata oluştu: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Taslak oluştur
  Future<bool> createDraft({
    required String title,
    required String description,
    required String category,
    required String language,
    File? imageFile,
    required String userId,
    required String authorName,
  }) async {
    try {
      _setLoading(true);
      String? imageUrl;
      if (imageFile != null) {
        String fileName = 'draft_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final newDraft = {
        'title': title,
        'description': description,
        'category': category,
        'language': language,
        'imageUrl': imageUrl,
        'userId': userId,
        'authorName': authorName,
        'status': 'draft',
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference draftRef = await _firestore.collection('drafts').add(newDraft);
      final draftModel = ContentModel(
        id: draftRef.id,
        title: title,
        description: description,
        category: category,
        language: language,
        imageUrl: imageUrl,
        userId: userId,
        authorName: authorName,
        isFeatured: false,
        viewCount: 0,
        likeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
      );
      _draftContents.insert(0, draftModel);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Taslak oluşturulurken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Taslak düzenle
  Future<bool> updateDraft({
    required String draftId,
    required String title,
    required String description,
    required String category,
    required String language,
    File? imageFile,
  }) async {
    try {
      _setLoading(true);
      final existingDraftIndex = _draftContents.indexWhere((d) => d.id == draftId);
      if (existingDraftIndex == -1) {
        _errorMessage = 'Düzenlenecek taslak bulunamadı.';
        return false;
      }

      final existingDraft = _draftContents[existingDraftIndex];
      final updates = <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'language': language,
      };

      String? imageUrl = existingDraft.imageUrl;
      if (imageFile != null) {
        String fileName = 'draft_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
        updates['imageUrl'] = imageUrl;
      }

      await _firestore.collection('drafts').doc(draftId).update(updates);
      final updatedDraft = existingDraft.copyWith(
        title: title,
        description: description,
        category: category,
        language: language,
        imageUrl: imageUrl,
      );
      _draftContents[existingDraftIndex] = updatedDraft;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Taslak güncellenirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Taslak sil
  Future<bool> deleteDraft(String draftId) async {
    try {
      _setLoading(true);
      await _firestore.collection('drafts').doc(draftId).delete();
      _draftContents.removeWhere((draft) => draft.id == draftId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Taslak silinirken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Taslağı yayınla (içeriği ana koleksiyona taşır)
  Future<bool> publishDraft(String draftId) async {
    try {
      _setLoading(true);
      final draftIndex = _draftContents.indexWhere((d) => d.id == draftId);
      if (draftIndex == -1) {
        _errorMessage = 'Yayınlanacak taslak bulunamadı.';
        return false;
      }

      final draft = _draftContents[draftIndex];
      final contentData = draft.toMap();
      contentData['createdAt'] = FieldValue.serverTimestamp();
      contentData.remove('status');

      DocumentReference contentRef = await _firestore.collection('contents').add(contentData);
      await _firestore.collection('drafts').doc(draftId).delete();
      _draftContents.removeAt(draftIndex);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Taslak yayınlanırken hata oluştu: $e';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Beğeni sayısını güncelle
  void setLikeCount(num value) {
    likeCount = value.toInt();
    notifyListeners();
  }

  // Yorum sayısını güncelle
  void setCommentCount(num value) {
    commentCount = value.toInt();
    notifyListeners();
  }

  // Yükleme durumunu ayarla
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}