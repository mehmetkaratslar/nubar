// Dosya: lib/viewmodels/search_viewmodel.dart
// Amaç: Arama işlemlerini yönetir.
// Bağlantı: search_screen.dart ile çalışır.
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/content_model.dart';

class SearchViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ContentModel> _searchResults = [];
  String _query = '';

  SearchViewModel(this._firestoreService);

  List<ContentModel> get searchResults => _searchResults;
  String get query => _query;

  // Arama yapar
  Future<void> searchContents(String query) async {
    _query = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      final data = await _firestoreService.searchContents(query);
      _searchResults = data
          .map((map) => ContentModel.fromMap(map, map['id']))
          .toList();
    }
    notifyListeners();
  }
}