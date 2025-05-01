// Dosya: lib/viewmodels/editor_viewmodel.dart
// Amaç: İçerik oluşturma ve düzenleme işlemlerini yönetir.
// Bağlantı: content_editor_screen.dart ile entegre çalışır.
// Not: summary ve text parametreleri eklendi, contentJson türü düzeltildi.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/foundation.dart';
import '../models/content_model.dart';
import '../models/content_status.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class EditorViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  quill.QuillController? _controller;
  ContentModel? _content;
  String? _title;
  String? _summary;
  String? _category;
  List<File> _mediaFiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  EditorViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  quill.QuillController? get controller => _controller;
  ContentModel? get content => _content;
  String? get title => _title;
  String? get summary => _summary;
  String? get category => _category;
  List<File> get mediaFiles => _mediaFiles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Editör kontrolcüsünü başlatır
  void initializeEditor() {
    _controller = quill.QuillController.basic();
    notifyListeners();
  }

  // Başlığı günceller
  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  // Özeti günceller
  void setSummary(String summary) {
    _summary = summary;
    notifyListeners();
  }

  // Kategoriyi günceller
  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  // Medya dosyalarını ekler
  Future<void> addMediaFiles(List<File> files) async {
    _mediaFiles.addAll(files);
    notifyListeners();
  }

  // İçeriği kaydeder
  Future<void> saveContent(String userId, String userDisplayName, String? userPhotoUrl) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Medya dosyalarını yükle
      List<String> mediaUrls = [];
      for (File file in _mediaFiles) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() + file.path.split('/').last;
        String url = await _storageService.uploadFile('content_media/$fileName', file);
        mediaUrls.add(url);
      }

      // İçeriği oluştur
      final content = ContentModel(
        id: '',
        title: _title ?? 'Başlıksız',
        description: _summary ?? '',
        contentJson: jsonEncode(_controller?.document.toDelta().toJson()), // Map'ten String'e çevir
        category: _category ?? 'history',
        mediaUrls: mediaUrls,
        thumbnailUrl: mediaUrls.isNotEmpty ? mediaUrls.first : null,
        userId: userId,
        userDisplayName: userDisplayName,
        authorName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        viewCount: 0,
        isFeatured: false,
        status: ContentStatus.draft,
        summary: _summary ?? 'Özet yok',
        text: _controller?.document.toPlainText() ?? '',
      );

      await _firestoreService.createContent(content);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // İçeriği yayınlar
  Future<void> publishContent(String userId, String userDisplayName, String? userPhotoUrl) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Medya dosyalarını yükle
      List<String> mediaUrls = [];
      for (File file in _mediaFiles) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() + file.path.split('/').last;
        String url = await _storageService.uploadFile('content_media/$fileName', file);
        mediaUrls.add(url);
      }

      // İçeriği oluştur
      final content = ContentModel(
        id: '',
        title: _title ?? 'Başlıksız',
        description: _summary ?? '',
        contentJson: jsonEncode(_controller?.document.toDelta().toJson()), // Map'ten String'e çevir
        category: _category ?? 'history',
        mediaUrls: mediaUrls,
        thumbnailUrl: mediaUrls.isNotEmpty ? mediaUrls.first : null,
        userId: userId,
        userDisplayName: userDisplayName,
        authorName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        viewCount: 0,
        isFeatured: false,
        status: ContentStatus.published,
        summary: _summary ?? 'Özet yok',
        text: _controller?.document.toPlainText() ?? '',
      );

      await _firestoreService.createContent(content);
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