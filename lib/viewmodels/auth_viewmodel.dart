// Dosya: lib/viewmodels/auth_viewmodel.dart
// Amaç: Kullanıcı kimlik doğrulama işlemlerini yönetir.
// Bağlantı: login_screen.dart, register_screen.dart, splash_screen.dart ile entegre çalışır, AuthService ve SharedPreferences ile veri yönetimi yapar.
// Not: BuildContext bağımlılığı kaldırıldı, hata yönetimi optimize edildi.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/service_exception.dart';

class AuthViewModel with ChangeNotifier {
  late AuthService _authService;
  final SharedPreferences _sharedPreferences;
  String? _userId;
  String? _userDisplayName;
  String? _userPhotoUrl;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  // AuthService bağımlılığını başlatır
  void initialize(AuthService authService) {
    _authService = authService;
  }

  String? get userId => _userId;
  String? get userDisplayName => _userDisplayName;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get firebaseUser => _authService.currentUser; // Mevcut kullanıcıyı getirir
  bool get isAuthenticated => _authService.currentUser != null; // Kullanıcı giriş yapmış mı?

  // Kullanıcı girişi yapar
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final user = await _authService.signInWithEmailAndPassword(email, password);
      _userId = user.uid;
      _userDisplayName = user.displayName;
      _userPhotoUrl = user.photoURL;
      await _sharedPreferences.setString('user_id', _userId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Google ile giriş yapar
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final user = await _authService.signInWithGoogle();
      _userId = user.uid;
      _userDisplayName = user.displayName;
      _userPhotoUrl = user.photoURL;
      await _sharedPreferences.setString('user_id', _userId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Şifre sıfırlama e-postası gönderir
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _authService.resetPassword(email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı kaydı yapar
  Future<void> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final user = await _authService.registerWithEmailAndPassword(email, password, displayName);
      _userId = user.uid;
      _userDisplayName = user.displayName;
      _userPhotoUrl = user.photoURL;
      await _sharedPreferences.setString('user_id', _userId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı çıkış yapar
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _authService.signOut();
      _userId = null;
      _userDisplayName = null;
      _userPhotoUrl = null;
      await _sharedPreferences.remove('user_id');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı dil tercihini günceller
  Future<void> updateUserLanguage(String language) async {
    try {
      _errorMessage = null;
      await _sharedPreferences.setString('preferred_language', language);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Dil güncelleme hatası: $e';
      notifyListeners();
      throw ServiceException(_errorMessage!);
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}