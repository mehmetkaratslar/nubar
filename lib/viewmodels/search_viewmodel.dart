// Dosya: lib/viewmodels/search_viewmodel.dart
// Amaç: Arama işlemlerini yönetir.
// Bağlantı: search_screen.dart ile entegre çalışır, FirestoreService ile veri yönetimi yapar.
// Not: navigatorKey bağımlılığı kaldırıldı, ServiceException import çakışması çözüldü.

import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/firestore_service.dart';
import '../utils/service_exception.dart'; // Özel hata sınıfı

class SearchViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ContentModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  SearchViewModel(this._firestoreService);

  List<ContentModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // İçerik arar
  Future<void> searchContents(BuildContext context, String query) async {
    try {
      _setLoading(true);
      final results = await _firestoreService.searchContents(query);
      _searchResults = results.map((data) => ContentModel.fromMap(data, data['id'])).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
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