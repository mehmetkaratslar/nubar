// Dosya: lib/viewmodels/content_viewmodel.dart
// Amaç: İçerik detayları ve ilgili işlemleri yönetir.
// Bağlantı: content_detail_screen.dart, content_list_screen.dart, category_screen.dart, profile_screen.dart ile entegre çalışır, FirestoreService ve StorageService ile veri yönetimi yapar.
// Not: BuildContext bağımlılığı kaldırıldı, getContentById korundu.

import 'package:flutter/foundation.dart';
import '../models/content_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class ContentViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AnalyticsService _analyticsService;
  ContentModel? _content;
  List<ContentModel> _contents = [];
  bool _isLoading = false;
  String? _errorMessage;

  ContentViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        _analyticsService = analyticsService;

  ContentModel? get content => _content;
  List<ContentModel> get contents => _contents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Belirli bir içeriği yükler
  Future<void> loadContent(String contentId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final contentData = await _firestoreService.getContentById(contentId);
      if (contentData != null) {
        _content = ContentModel.fromMap(contentData, contentId);
        // İçerik detay ekranı görüntüleme olayını kaydet
        await _analyticsService.logScreenView('content_detail');
        notifyListeners();
      } else {
        _errorMessage = 'İçerik bulunamadı';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'İçerik yükleme hatası: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Belirli bir içeriği ID ile getirir
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final contentData = await _firestoreService.getContentById(contentId);
      if (contentData != null) {
        return ContentModel.fromMap(contentData, contentId);
      }
      return null;
    } catch (e) {
      _errorMessage = 'İçerik alma hatası: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriye göre içerikleri getirir
  Future<void> getContentsByCategory(String category) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final snapshot = await _firestoreService
          .getContentsQuery()
          .where('category', isEqualTo: category)
          .get();
      final data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _contents = await Future.microtask(() =>
          data.map((map) => ContentModel.fromMap(map, map['id'])).toList());
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Kategoriye göre içerik yükleme hatası: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // İçeriği beğenir
  Future<void> likeContent() async {
    try {
      if (_content != null) {
        _setLoading(true);
        _errorMessage = null;
        _content = _content!.copyWith(likeCount: _content!.likeCount + 1);
        await _firestoreService.updateContent(_content!);
        // Beğenme olayını kaydet
        await _analyticsService
            .logEvent('content_like', {'content_id': _content!.id});
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Beğenme hatası: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // İçeriğe yorum ekler
  Future<void> addComment(String comment) async {
    try {
      if (_content != null) {
        _setLoading(true);
        _errorMessage = null;
        _content = _content!.copyWith(commentCount: _content!.commentCount + 1);
        await _firestoreService.updateContent(_content!);
        // Yorum ekleme olayını kaydet
        await _analyticsService
            .logEvent('content_comment', {'content_id': _content!.id});
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Yorum ekleme hatası: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // İçeriği siler
  Future<void> deleteContent() async {
    try {
      if (_content != null) {
        _setLoading(true);
        _errorMessage = null;
        // Medya dosyalarını sil
        if (_content!.mediaUrls != null) {
          for (String url in _content!.mediaUrls!) {
            await _storageService.deleteFile(url);
          }
        }
        if (_content!.thumbnailUrl != null) {
          await _storageService.deleteFile(_content!.thumbnailUrl!);
        }
        // Firestore'dan içeriği sil
        await _firestoreService.deleteContent(_content!.id);
        // Silme olayını kaydet
        await _analyticsService
            .logEvent('content_delete', {'content_id': _content!.id});
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'İçerik silme hatası: $e';
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