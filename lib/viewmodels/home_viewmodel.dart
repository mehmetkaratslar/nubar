// Dosya: lib/viewmodels/home_viewmodel.dart
// Amaç: Ana sayfa verilerini yönetir (içerikler, kategoriler).
// Bağlantı: home_screen.dart ile çalışır.
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/content_model.dart';
import '../utils/app_constants.dart';

class HomeViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ContentModel> _contents = [];
  List<ContentModel> _featuredContents = [];
  String? _selectedCategory;
  List<ContentModel> _filteredContents = [];
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _cachedCategories = AppConstants.categories;

  HomeViewModel(this._firestoreService) {
    loadHomePageData();
  }

  List<ContentModel> get contents => _contents;
  List<ContentModel> get featuredContents => _featuredContents;
  String? get selectedCategory => _selectedCategory;
  List<ContentModel> get filteredContents => _filteredContents;
  List<String> get categories => _cachedCategories; // Cached categories for performance
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ana sayfa verilerini yükler
  Future<void> loadHomePageData() async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContents();
      final newContents = data.map((map) => ContentModel.fromMap(map, map['id'])).toList();

      // Check if contents have changed to avoid unnecessary notifications
      if (!_areContentsEqual(_contents, newContents)) {
        _contents = newContents;
        _featuredContents = _contents.where((content) => content.isFeatured).take(5).toList();
        _filteredContents = _selectedCategory == null || _selectedCategory == 'Tümü'
            ? _contents
            : _contents.where((content) => content.category == _selectedCategory).toList();
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenirken bir hata oluştu. Lütfen tekrar deneyin: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Tek bir içeriği yeniler (örneğin, bookmark sonrası güncelleme için)
  Future<void> refreshContent(String contentId) async {
    try {
      _setLoading(true);
      final contentData = await _firestoreService.getContentById(contentId);
      if (contentData != null) {
        final updatedContent = ContentModel.fromMap(contentData, contentId);
        final contentIndex = _contents.indexWhere((content) => content.id == contentId);
        if (contentIndex != -1) {
          _contents[contentIndex] = updatedContent;
          _featuredContents = _contents.where((content) => content.isFeatured).take(5).toList();
          _filteredContents = _selectedCategory == null || _selectedCategory == 'Tümü'
              ? _contents
              : _contents.where((content) => content.category == _selectedCategory).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'İçerik yenilenirken bir hata oluştu: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriyi ayarlar
  void setCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      if (category == null || category == 'Tümü') {
        _filteredContents = _contents;
      } else {
        _filteredContents = _contents.where((content) => content.category == category).toList();
      }
      notifyListeners();
    }
  }

  // Hata mesajını temizler (örneğin, tekrar dene butonu için)
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      notifyListeners();
    }
  }

  // İçerik listelerinin eşitliğini kontrol eder
  bool _areContentsEqual(List<ContentModel> oldContents, List<ContentModel> newContents) {
    if (oldContents.length != newContents.length) return false;
    for (int i = 0; i < oldContents.length; i++) {
      if (oldContents[i].id != newContents[i].id ||
          oldContents[i].title != newContents[i].title ||
          oldContents[i].category != newContents[i].category ||
          oldContents[i].isFeatured != newContents[i].isFeatured) {
        return false;
      }
    }
    return true;
  }
}