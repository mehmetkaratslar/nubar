// Dosya: lib/viewmodels/home_viewmodel.dart
// Amaç: Ana ekran için veri yönetimi sağlar.
// Bağlantı: home_screen.dart, category_screen.dart, content_list_screen.dart üzerinden çağrılır, FirestoreService ile entegre çalışır.
// Not: getContentsByCategory metodu eklendi, contents getter'ı zaten mevcut.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../models/story_model.dart';
import '../services/firestore_service.dart';

class HomeViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ContentModel> _contents = [];
  List<ContentModel> _featuredContents = [];
  List<ContentModel> _filteredContents = [];
  List<StoryModel> _stories = [];
  String? _selectedCategory;
  String? _errorMessage;
  bool _isLoading = false;

  HomeViewModel(this._firestoreService);

  List<ContentModel> get contents => _contents; // Zaten tanımlı
  List<ContentModel> get featuredContents => _featuredContents;
  List<ContentModel> get filteredContents => _filteredContents;
  List<StoryModel> get stories => _stories;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // İçerikleri Firestore'dan yükler
  Future<void> loadHomePageData() async {
    try {
      _setLoading(true);
      // Firestore çağrısını asenkron hale getir ve önbellek kullan
      final snapshot = await _firestoreService.getContentsQuery().get(const GetOptions(source: Source.cache));
      final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      final newContents = await Future.microtask(() => data.map((map) => ContentModel.fromMap(map, map['id'])).toList());
      if (!_areContentsEqual(_contents, newContents)) {
        _contents = newContents;
        _featuredContents = _contents.where((content) => content.isFeatured).take(5).toList();
        _filteredContents = _selectedCategory == null || _selectedCategory == 'all'
            ? _contents
            : _contents.where((content) => content.category == _selectedCategory).toList();
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      try {
        // Önbellekten veri alınamadıysa sunucudan dene
        final snapshot = await _firestoreService.getContentsQuery().get(const GetOptions(source: Source.server));
        final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        final newContents = await Future.microtask(() => data.map((map) => ContentModel.fromMap(map, map['id'])).toList());
        if (!_areContentsEqual(_contents, newContents)) {
          _contents = newContents;
          _featuredContents = _contents.where((content) => content.isFeatured).take(5).toList();
          _filteredContents = _selectedCategory == null || _selectedCategory == 'all'
              ? _contents
              : _contents.where((content) => content.category == _selectedCategory).toList();
        }
        _errorMessage = null;
      } catch (e) {
        _errorMessage = 'İçerik yükleme hatası: $e';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriye göre içerikleri getirir
  Future<void> getContentsByCategory(String category) async {
    try {
      _setLoading(true);
      final snapshot = await _firestoreService
          .getContentsQuery()
          .where('category', isEqualTo: category)
          .get();
      final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      _contents = await Future.microtask(() => data.map((map) => ContentModel.fromMap(map, map['id'])).toList());
      _filteredContents = _contents;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Kategoriye göre içerik yükleme hatası: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Hikayeleri Firestore'dan yükler
  Future<void> loadStories() async {
    try {
      _setLoading(true);
      // Firestore çağrısını asenkron hale getir ve önbellek kullan
      final snapshot = await _firestoreService.getStoriesQuery().get(const GetOptions(source: Source.cache));
      final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      _stories = await Future.microtask(() => data.map((doc) => StoryModel.fromMap(doc, doc['id'])).toList());
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      try {
        // Önbellekten veri alınamadıysa sunucudan dene
        final snapshot = await _firestoreService.getStoriesQuery().get(const GetOptions(source: Source.server));
        final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _stories = await Future.microtask(() => data.map((doc) => StoryModel.fromMap(doc, doc['id'])).toList());
        _errorMessage = null;
      } catch (e) {
        _errorMessage = 'Hikaye yükleme hatası: $e';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kategori seçimi
  void selectCategory(String? category) {
    _selectedCategory = category;
    _filteredContents = _selectedCategory == null || _selectedCategory == 'all'
        ? _contents
        : _contents.where((content) => content.category == _selectedCategory).toList();
    notifyListeners();
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // İçerik listelerinin eşitliğini kontrol eder
  bool _areContentsEqual(List<ContentModel> a, List<ContentModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}