// lib/viewmodels/auth_viewmodel.dart
// Kimlik doğrulama ViewModel'i
// Firebase Authentication ve Firestore kullanarak kimlik doğrulama işlemlerini yönetir

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Services
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

// Models
import '../models/user_model.dart';

// Utils
import '../utils/constants.dart';

class AuthViewModel with ChangeNotifier {
  // Servis sınıfları
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final AnalyticsService? _analyticsService;

  // Kullanıcı bilgileri
  UserModel? _user;
  User? get currentUser => _authService.currentUser;
  UserModel? get userModel => _user;
  bool get isLoggedIn => currentUser != null;
  UserRole get userRole => _user?.role ?? UserRole.user;

  // Kimlik doğrulama durumu
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor
  AuthViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
    AnalyticsService? analyticsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _analyticsService = analyticsService {
    // Oturum durum değişikliklerini dinle
    _authService.userStream.listen(_onAuthStateChanged);
  }

  // Oturum durum değişikliği dinleyici
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // Oturum kapatıldıysa veya kullanıcı yoksa
      _user = null;
      notifyListeners();
      return;
    }

    // Firestore'dan kullanıcı verisini al
    try {
      final userData = await _firestoreService.getUser(firebaseUser.uid);

      if (userData != null) {
        // Kullanıcı zaten var, verileri atama
        _user = userData;
      } else {
        // Kullanıcı veri modelini oluştur ve Firestore'a kaydet
        final newUser = UserModel(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'Kullanıcı',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          role: UserRole.user,
          preferredLanguage: 'ku', // Varsayılan olarak Kürtçe
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          likedContents: [],
          savedContents: [],
        );

        // Firestore'a kaydet
        await _firestoreService.createUser(newUser);
        _user = newUser;
      }

      // Son giriş tarihini güncelle
      await _firestoreService.updateUser(
          _user!.copyWith(lastLoginAt: DateTime.now())
      );

      // Kullanıcı ID'sini analytics'e gönder
      _analyticsService?.setUserId(firebaseUser.uid);

      notifyListeners();
    } catch (e) {
      print('Kullanıcı verisi alınırken hata: $e');
    }
  }

  // E-posta ve şifre ile kayıt olma
  Future<void> registerWithEmailAndPassword(
      String email,
      String password,
      String username,
      ) async {
    _setLoading(true);

    try {
      // Firebase Auth ile kayıt ol
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        // Profil bilgisini güncelle
        await _authService.updateProfile(displayName: username);

        // Analytics
        _analyticsService?.logSignUp(method: 'email');
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // E-posta ve şifre ile giriş yapma
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);

    try {
      // Firebase Auth ile giriş yap
      await _authService.signInWithEmailAndPassword(email, password);

      // Analytics
      _analyticsService?.logLogin(method: 'email');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Google ile giriş yapma
  Future<void> signInWithGoogle() async {
    _setLoading(true);

    try {
      // Firebase Auth ile Google girişi
      await _authService.signInWithGoogle();

      // Analytics
      _analyticsService?.logLogin(method: 'google');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Şifremi unuttum
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Çıkış yap
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();

      // Analytics user ID'sini temizle
      _analyticsService?.setUserId(null);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Kullanıcı profilini güncelle
  Future<void> updateUserProfile({
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    _setLoading(true);

    try {
      if (_user == null) throw Exception('Kullanıcı bulunamadı');

      // Profil fotoğrafı güncellendiyse Firebase Auth'a da güncelle
      if (photoUrl != null) {
        await _authService.updateProfile(photoURL: photoUrl);
      }

      // Username güncellendiyse Firebase Auth'a da güncelle
      if (username != null) {
        await _authService.updateProfile(displayName: username);
      }

      // UserModel'i güncelle
      final updatedUser = _user!.copyWith(
        username: username ?? _user!.username,
        bio: bio ?? _user!.bio,
        photoUrl: photoUrl ?? _user!.photoUrl,
      );

      // Firestore'da güncelle
      await _firestoreService.updateUser(updatedUser);

      // Local state'i güncelle
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Kullanıcı dil tercihini güncelle
  Future<void> updateUserLanguage(String languageCode) async {
    try {
      if (_user == null) throw Exception('Kullanıcı bulunamadı');

      // UserModel'i güncelle
      final updatedUser = _user!.copyWith(
        preferredLanguage: languageCode,
      );

      // Firestore'da güncelle
      await _firestoreService.updateUserLanguage(_user!.uid, languageCode);

      // Local state'i güncelle
      _user = updatedUser;
      notifyListeners();

      // Analytics
      _analyticsService?.logEvent(
        AnalyticsEventType.changeLanguage,
        {
          'previous_language': _user!.preferredLanguage,
          'new_language': languageCode,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // E-posta adresini güncelle
  Future<void> updateEmail(String newEmail, String password) async {
    _setLoading(true);

    try {
      // Önce kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        password,
      );

      // E-posta güncelle
      await _authService.updateEmail(newEmail);

      // UserModel'i güncelle
      final updatedUser = _user!.copyWith(
        email: newEmail,
      );

      // Firestore'da güncelle
      await _firestoreService.updateUser(updatedUser);

      // Local state'i güncelle
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Şifreyi güncelle
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);

    try {
      // Önce kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        currentPassword,
      );

      // Şifre güncelle
      await _authService.updatePassword(newPassword);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Hesabı sil
  Future<void> deleteAccount(String password) async {
    _setLoading(true);

    try {
      // Önce kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        password,
      );

      // Firestore'dan kullanıcı verilerini sil
      // TODO: Kullanıcıya ait diğer verileri (yorumlar, beğeniler, vb.) silme işlemleri eklenebilir

      // Firebase Auth'dan hesabı sil
      await _authService.deleteAccount();

      // Analytics user ID'sini temizle
      _analyticsService?.setUserId(null);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  // Loading durumunu güncelle
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}