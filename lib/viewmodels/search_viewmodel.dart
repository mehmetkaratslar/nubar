import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/firestore_service.dart';

class SearchViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<ContentModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _lastQuery = '';

  SearchViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<ContentModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> searchContents(String query, {String? language}) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _lastQuery = query;
    _setLoading(true);
    _errorMessage = null;

    try {
      final results = await _firestoreService.searchContents(
        query,
        language: language,
      );

      _searchResults = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Arama yapılırken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchResults = [];
    _lastQuery = '';
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}