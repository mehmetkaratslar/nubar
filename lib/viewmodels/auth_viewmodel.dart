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
  bool get isLoggedIn => _isAuthenticated; // Added for HomeScreen compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get userModel => _userData; // Added for HomeScreen compatibility
  bool get isEditor => _isEditor;

  // Authentication durumunu dinler
  void _initAuthListener() {
    try {
      _authService.getFirebaseAuth().authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser != null) {
          debugPrint("AuthViewModel: Kullanıcı giriş yaptı, UID: ${firebaseUser.uid}");
          await _fetchUserData(firebaseUser.uid);
        } else {
          debugPrint("AuthViewModel: Kullanıcı çıkış yaptı.");
          _user = null;
          _userData = null;
          _isAuthenticated = false;
          _isEditor = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("AuthViewModel: Authentication dinleme hatası: $e");
    }
  }

  // Firestore’dan kullanıcı verilerini çeker
  Future<void> _fetchUserData(String uid) async {
    try {
      _setLoading(true);
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        // Ensure preferredLanguage exists, default to 'ku' if missing
        if (!_userData!.containsKey('preferredLanguage')) {
          _userData!['preferredLanguage'] = 'ku';
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'preferredLanguage': 'ku',
          });
        }
        _user = _authService.getCurrentUser();
        _isAuthenticated = true;
        _isEditor = _userData?['role'] == 'editor';
        debugPrint("AuthViewModel: Kullanıcı verileri alındı: ${_userData?['displayName']}");
      } else {
        final firebaseUser = _authService.getCurrentUser()!;
        final userData = {
          'displayName': firebaseUser.displayName ?? 'Kullanıcı',
          'email': firebaseUser.email,
          'photoUrl': firebaseUser.photoURL,
          'role': 'user',
          'preferredLanguage': 'ku', // Default language
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
        _userData = userData;
        _user = firebaseUser;
        _isAuthenticated = true;
        _isEditor = false;
        debugPrint("AuthViewModel: Yeni kullanıcı verileri oluşturuldu: ${_userData?['displayName']}");
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Kullanıcı bilgileri alınırken bir hata oluştu. Lütfen tekrar deneyin: $e';
      debugPrint("AuthViewModel: Kullanıcı verileri alınırken hata: $_errorMessage");
      notifyListeners();
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
        debugPrint("AuthViewModel: E-posta ile giriş başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
        debugPrint("AuthViewModel: E-posta ile giriş başarısız.");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      debugPrint("AuthViewModel: E-posta ile giriş hatası: $e");
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
        debugPrint("AuthViewModel: Google ile giriş başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Google ile giriş başarısız. Lütfen tekrar deneyin.';
        debugPrint("AuthViewModel: Google ile giriş başarısız.");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      debugPrint("AuthViewModel: Google ile giriş hatası: $e");
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
          'preferredLanguage': 'ku', // Default language
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _fetchUserData(user.uid);
        debugPrint("AuthViewModel: Kayıt başarılı: ${user.uid}");
        return true;
      } else {
        _errorMessage = 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.';
        debugPrint("AuthViewModel: Kayıt başarısız.");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      debugPrint("AuthViewModel: Kayıt hatası: $e");
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
      debugPrint("AuthViewModel: Kullanıcı çıkış yaptı.");
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken bir hata oluştu. Lütfen tekrar deneyin: $e';
      debugPrint("AuthViewModel: Çıkış hatası: $_errorMessage");
      notifyListeners();
    }
  }

  // Şifre sıfırlama e-postası gönderir
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _authService.getFirebaseAuth().sendPasswordResetEmail(email: email);
      debugPrint("AuthViewModel: Şifre sıfırlama e-postası gönderildi: $email");
      return true;
    } catch (e) {
      _handleAuthError(e);
      debugPrint("AuthViewModel: Şifre sıfırlama hatası: $e");
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
        debugPrint("AuthViewModel: Profil güncellendi: $updates");
      }
      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenirken bir hata oluştu. Lütfen tekrar deneyin: $e';
      debugPrint("AuthViewModel: Profil güncelleme hatası: $_errorMessage");
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı dilini günceller
  Future<void> updateUserLanguage(String languageCode) async {
    try {
      await _sharedPreferences.setString('language', languageCode);
      if (_user != null) {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'preferredLanguage': languageCode,
        });
        _userData?['preferredLanguage'] = languageCode;
      }
      notifyListeners();
      debugPrint("AuthViewModel: Kullanıcı dili güncellendi: $languageCode");
    } catch (e) {
      debugPrint("AuthViewModel: Dil güncelleme hatası: $e");
    }
  }

  // Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      notifyListeners();
    }
  }

  // Hata mesajını temizler
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
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
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin: $error';
    }
    notifyListeners();
  }
}