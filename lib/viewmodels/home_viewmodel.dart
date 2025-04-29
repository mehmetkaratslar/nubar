import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class HomeViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<ContentModel> _featuredContents = [];
  Map<String, List<ContentModel>> _categoryContents = {
    Constants.historyCategory: [],
    Constants.languageCategory: [],
    Constants.artCategory: [],
    Constants.musicCategory: [],
    Constants.traditionCategory: [],
  };

  bool _isLoading = false;
  String? _errorMessage;
  String _currentLanguage = Constants.languageTurkish;

  HomeViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<ContentModel> get featuredContents => _featuredContents;
  Map<String, List<ContentModel>> get categoryContents => _categoryContents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentLanguage => _currentLanguage;

  // Dil tercihini ayarla
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;

      // İçerikleri yeniden yükle
      loadHomeContents();

      notifyListeners();
    }
  }

  // Ana sayfa içeriklerini yükle
  Future<void> loadHomeContents() async {
    try {
      _setLoading(true);

      // Öne çıkan içerikleri yükle
      await _loadFeaturedContents();

      // Her kategoriden son içerikleri yükle
      await Future.wait([
        _loadCategoryContents(Constants.historyCategory),
        _loadCategoryContents(Constants.languageCategory),
        _loadCategoryContents(Constants.artCategory),
        _loadCategoryContents(Constants.musicCategory),
        _loadCategoryContents(Constants.traditionCategory),
      ]);

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Öne çıkan içerikleri yükle
  Future<void> _loadFeaturedContents() async {
    try {
      _featuredContents = await _firestoreService.getFeaturedContents(
        language: _currentLanguage,
        limit: 5,
      );
    } catch (e) {
      print('Öne çıkan içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Kategori içeriklerini yükle
  Future<void> _loadCategoryContents(String category) async {
    try {
      List<ContentModel> contents = await _firestoreService.getContentsByCategory(
        category,
        language: _currentLanguage,
        limit: 5,
      );

      _categoryContents[category] = contents;
    } catch (e) {
      print('$category kategori içerikleri yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Daha fazla kategori içeriği yükle
  Future<List<ContentModel>> loadMoreCategoryContents(
      String category, {
        int limit = 10,
        int skip = 0,
      }) async {
    try {
      // Kategori içeriklerini getir
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(Constants.contentsCollection)
          .where('category', isEqualTo: category)
          .where('isPublished', isEqualTo: true)
          .where('language', isEqualTo: _currentLanguage)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<ContentModel> contents = snapshot.docs.map((doc) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      return contents;
    } catch (e) {
      print('Daha fazla içerik yüklenirken hata oluştu: ${e.toString()}');
      return [];
    }
  }

  // Tek bir içerik detayını getir
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      return await _firestoreService.getContentById(contentId);
    } catch (e) {
      print('İçerik detayı alınırken hata oluştu: ${e.toString()}');
      return null;
    }
  }

  // İçerik bildir
  Future<bool> reportContent(
      String contentId,
      String reporterId,
      String reason,
      ) async {
    try {
      _setLoading(true);

      // Bildirim koleksiyonuna ekle
      await FirebaseFirestore.instance
          .collection('reports')
          .add({
        'contentId': contentId,
        'reporterId': reporterId,
        'reason': reason,
        'type': 'content',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'İçerik bildirilirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Yorum bildir
  Future<bool> reportComment(
      String contentId,
      String commentId,
      String reporterId,
      String reason,
      ) async {
    try {
      _setLoading(true);

      // Bildirim koleksiyonuna ekle
      await FirebaseFirestore.instance
          .collection('reports')
          .add({
        'contentId': contentId,
        'commentId': commentId,
        'reporterId': reporterId,
        'reason': reason,
        'type': 'comment',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Yorum bildirilirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Tüm kategorileri al
  List<Map<String, dynamic>> getAllCategories() {
    return [
      {
        'id': Constants.historyCategory,
        'name': Constants.historyCategory,
        'description': Constants.historyCategoryDesc,
        'color': Constants.historyColor,
        'icon': Constants.historyIcon,
        'imageAsset': Constants.historyCategoryImageAsset,
      },
      {
        'id': Constants.languageCategory,
        'name': Constants.languageCategory,
        'description': Constants.languageCategoryDesc,
        'color': Constants.languageColor,
        'icon': Constants.languageIcon,
        'imageAsset': Constants.languageCategoryImageAsset,
      },
      {
        'id': Constants.artCategory,
        'name': Constants.artCategory,
        'description': Constants.artCategoryDesc,
        'color': Constants.artColor,
        'icon': Constants.artIcon,
        'imageAsset': Constants.artCategoryImageAsset,
      },
      {
        'id': Constants.musicCategory,
        'name': Constants.musicCategory,
        'description': Constants.musicCategoryDesc,
        'color': Constants.musicColor,
        'icon': Constants.musicIcon,
        'imageAsset': Constants.musicCategoryImageAsset,
      },
      {
        'id': Constants.traditionCategory,
        'name': Constants.traditionCategory,
        'description': Constants.traditionCategoryDesc,
        'color': Constants.traditionColor,
        'icon': Constants.traditionIcon,
        'imageAsset': Constants.traditionCategoryImageAsset,
      },
    ];
  }

  // Loading durumunu ayarla
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // İçerikleri yeniden yükle (pull-to-refresh için)
  Future<void> refreshContents() async {
    await loadHomeContents();
  }
}