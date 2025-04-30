// Dosya: lib/viewmodels/auth_viewmodel.dart
// Amaç: Kullanıcı kimlik doğrulama işlemlerini yönetir.
// Bağlantı: login_screen.dart, register_screen.dart, language_selection_screen.dart ile çalışır.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  final SharedPreferences _sharedPreferences;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isEditor = false;

  AuthViewModel(this._authService, this._sharedPreferences) {
    _initAuthListener();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isEditor => _isEditor;

  // Authentication durumunu dinler
  void _initAuthListener() {
    try {
      _authService.getFirebaseAuth().authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser != null) {
          print("AuthViewModel: Kullanıcı giriş yaptı, UID: ${firebaseUser.uid}");
          await _fetchUserData(firebaseUser.uid);
        } else {
          print("AuthViewModel: Kullanıcı çıkış yaptı.");
          _user = null;
          _userData = null;
          _isAuthenticated = false;
          _isEditor = false;
          notifyListeners();
        }
      });
    } catch (e) {
      print("AuthViewModel: Authentication dinleme hatası: $e");
    }
  }

  // Firestore’dan kullanıcı verilerini çeker
  Future<void> _fetchUserData(String uid) async {
    try {
      _setLoading(true);
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        _user = _authService.getCurrentUser();
        _isAuthenticated = true;
        _isEditor = _userData?['role'] == 'editor';
        print("AuthViewModel: Kullanıcı verileri alındı: ${_userData?['displayName']}");
      } else {
        final firebaseUser = _authService.getCurrentUser()!;
        final userData = {
          'displayName': firebaseUser.displayName ?? 'Kullanıcı',
          'email': firebaseUser.email,
          'photoUrl': firebaseUser.photoURL,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
        _userData = userData;
        _user = firebaseUser;
        _isAuthenticated = true;
        _isEditor = false;
        print("AuthViewModel: Yeni kullanıcı verileri oluşturuldu: ${_userData?['displayName']}");
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Kullanıcı bilgileri alınamadı: $e';
      print("AuthViewModel: Kullanıcı verileri alınırken hata: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve şifre ile giriş yapar
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        await _fetchUserData(user.uid);
        print("AuthViewModel: E-posta ile giriş başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Giriş başarısız.';
        print("AuthViewModel: E-posta ile giriş başarısız.");
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      print("AuthViewModel: E-posta ile giriş hatası: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google ile giriş yapar
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _fetchUserData(user.uid);
        print("AuthViewModel: Google ile giriş başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Google ile giriş başarısız.';
        print("AuthViewModel: Google ile giriş başarısız.");
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      print("AuthViewModel: Google ile giriş hatası: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve şifre ile kayıt yapar
  Future<bool> registerWithEmailPassword(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.register(email, password, displayName);
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': displayName,
          'email': email,
          'photoUrl': null,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _fetchUserData(user.uid);
        print("AuthViewModel: Kayıt başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Kayıt başarısız.';
        print("AuthViewModel: Kayıt başarısız.");
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      print("AuthViewModel: Kayıt hatası: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı çıkışı
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _user = null;
      _userData = null;
      _isAuthenticated = false;
      _isEditor = false;
      notifyListeners();
      print("AuthViewModel: Kullanıcı çıkış yaptı.");
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken hata oluştu: $e';
      print("AuthViewModel: Çıkış hatası: $_errorMessage");
    }
  }

  // Şifre sıfırlama e-postası gönderir
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _authService.getFirebaseAuth().sendPasswordResetEmail(email: email);
      print("AuthViewModel: Şifre sıfırlama e-postası gönderildi: $email");
      return true;
    } catch (e) {
      _handleAuthError(e);
      print("AuthViewModel: Şifre sıfırlama hatası: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Profil bilgilerini günceller
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      final updates = <String, dynamic>{};
      if (displayName != null && displayName.isNotEmpty) {
        updates['displayName'] = displayName;
        await _authService.getFirebaseAuth().currentUser!.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update(updates);
        _userData = {...?_userData, ...updates};
        notifyListeners();
        print("AuthViewModel: Profil güncellendi: $updates");
      }
      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenirken hata oluştu: $e';
      print("AuthViewModel: Profil güncelleme hatası: $_errorMessage");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı dilini günceller
  Future<void> updateUserLanguage(String languageCode) async {
    try {
      await _sharedPreferences.setString('language', languageCode);
      notifyListeners();
      print("AuthViewModel: Kullanıcı dili güncellendi: $languageCode");
    } catch (e) {
      print("AuthViewModel: Dil güncelleme hatası: $e");
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // Hata mesajını temizler
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Authentication hatalarını işler
  void _handleAuthError(dynamic error) {
    final errorCode = error.code ?? '';
    if (errorCode == 'user-not-found') {
      _errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
    } else if (errorCode == 'wrong-password') {
      _errorMessage = 'Hatalı şifre girdiniz.';
    } else if (errorCode == 'invalid-email') {
      _errorMessage = 'Geçersiz e-posta adresi.';
    } else if (errorCode == 'email-already-in-use') {
      _errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
    } else if (errorCode == 'weak-password') {
      _errorMessage = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
    } else if (errorCode == 'too-many-requests') {
      _errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
    } else {
      _errorMessage = 'Bir hata oluştu: $error';
    }
    notifyListeners();
  }
}