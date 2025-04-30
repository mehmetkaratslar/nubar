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

  HomeViewModel(this._firestoreService) {
    loadHomePageData();
  }

  List<ContentModel> get contents => _contents;
  List<ContentModel> get featuredContents => _featuredContents;
  String? get selectedCategory => _selectedCategory;
  List<ContentModel> get filteredContents => _filteredContents;
  List<String> get categories => AppConstants.categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ana sayfa verilerini yükler
  Future<void> loadHomePageData() async {
    try {
      _setLoading(true);
      final data = await _firestoreService.getContents();
      _contents = data.map((map) => ContentModel.fromMap(map, map['id'])).toList();
      _featuredContents = _contents.where((content) => content.isFeatured).take(5).toList();
      _filteredContents = _contents;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenemedi: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriyi ayarlar
  void setCategory(String? category) {
    _selectedCategory = category;
    if (category == null || category == 'Tümü') {
      _filteredContents = _contents;
    } else {
      _filteredContents = _contents
          .where((content) => content.category == category)
          .toList();
    }
    notifyListeners();
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}