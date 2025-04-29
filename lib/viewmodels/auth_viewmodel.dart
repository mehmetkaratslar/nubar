import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final SharedPreferences _preferences;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
    required SharedPreferences sharedPreferences,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _preferences = sharedPreferences {
    // Oturum değişikliklerini dinle
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _user = null;
        _saveUserDataToPrefs(null);
        notifyListeners();
      }
    });

    // Tercihlerden kullanıcı verilerini yüklemeyi dene
    _loadUserDataFromPrefs();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isEditor => _user?.role == Constants.roleEditor || _user?.role == Constants.roleAdmin;

  // Tercihlerden kullanıcı verilerini yükle
  void _loadUserDataFromPrefs() {
    final userId = _preferences.getString(Constants.prefUserId);
    if (userId != null) {
      final email = _preferences.getString(Constants.prefUserEmail) ?? '';
      final displayName = _preferences.getString(Constants.prefUserName) ?? '';
      final role = _preferences.getString(Constants.prefUserRole) ?? Constants.roleUser;

      _user = UserModel(
        id: userId,
        email: email,
        displayName: displayName,
        role: role,
        preferredLanguage: Constants.languageTurkish,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );

      notifyListeners();

      // Firebase'den en güncel verileri al
      if (_authService.currentUser != null) {
        _loadUserData(_authService.currentUser!.uid);
      }
    }
  }

  // Tercihlere kullanıcı verilerini kaydet
  void _saveUserDataToPrefs(UserModel? user) {
    if (user != null) {
      _preferences.setString(Constants.prefUserId, user.id);
      _preferences.setString(Constants.prefUserEmail, user.email);
      _preferences.setString(Constants.prefUserName, user.displayName);
      _preferences.setString(Constants.prefUserRole, user.role);
    } else {
      _preferences.remove(Constants.prefUserId);
      _preferences.remove(Constants.prefUserEmail);
      _preferences.remove(Constants.prefUserName);
      _preferences.remove(Constants.prefUserRole);
    }
  }

  // Firestore'dan kullanıcı verilerini yükle
  Future<void> _loadUserData(String userId) async {
    try {
      _setLoading(true);

      UserModel? userModel = await _firestoreService.getUser(userId);

      if (userModel != null) {
        _user = userModel;
        _saveUserDataToPrefs(userModel);
      } else {
        // Kullanıcı Firestore'da yoksa, Firebase Auth'dan bilgileri al ve oluştur
        User? firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          userModel = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'Kullanıcı',
            photoUrl: firebaseUser.photoURL,
            role: Constants.roleUser,
            preferredLanguage: Constants.languageTurkish,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            isActive: true,
          );

          await _firestoreService.createUser(userModel);
          _user = userModel;
          _saveUserDataToPrefs(userModel);
        }
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Kullanıcı verileri yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve şifre ile kayıt ol
  Future<bool> registerWithEmailPassword(
      String email,
      String password,
      String displayName,
      ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Firebase Auth ile kayıt ol
      UserCredential credential = await _authService.registerWithEmailPassword(email, password);

      // Kullanıcı adını güncelle
      await _authService.updateDisplayName(displayName);

      // Firestore'a kullanıcı verilerini kaydet
      UserModel newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: Constants.roleUser,
        preferredLanguage: Constants.languageTurkish,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );

      await _firestoreService.createUser(newUser);

      // Yerel verileri güncelle
      _user = newUser;
      _saveUserDataToPrefs(newUser);

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e);
      print(_errorMessage);
      return false;
    } catch (e) {
      _errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve şifre ile giriş yap
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.signInWithEmailPassword(email, password);

      // _loadUserData işlemi dinleyici tarafından tetiklenecek
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e);
      print(_errorMessage);
      return false;
    } catch (e) {
      _errorMessage = 'Giriş sırasında bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google ile giriş yap
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      UserCredential? credential = await _authService.signInWithGoogle();

      if (credential == null) {
        // Kullanıcı işlemi iptal etti
        _errorMessage = 'Google girişi iptal edildi';
        return false;
      }

      // _loadUserData işlemi dinleyici tarafından tetiklenecek
      return true;
    } catch (e) {
      _errorMessage = 'Google girişi sırasında bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Şifre sıfırlama
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.sendPasswordResetEmail(email);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e);
      print(_errorMessage);
      return false;
    } catch (e) {
      _errorMessage = 'Şifre sıfırlama sırasında bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _authService.signOut();

      _user = null;
      _saveUserDataToPrefs(null);
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? preferredLanguage,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);

      Map<String, dynamic> updates = {};

      if (displayName != null) {
        updates['displayName'] = displayName;
        // Firebase Auth'da da güncelle
        await _authService.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        // Firebase Auth'da da güncelle
        await _authService.updatePhotoURL(photoUrl);
      }

      if (bio != null) {
        updates['bio'] = bio;
      }

      if (preferredLanguage != null) {
        updates['preferredLanguage'] = preferredLanguage;
      }

      if (updates.isNotEmpty) {
        await _firestoreService.updateUser(_user!.id, updates);

        // Yerel kullanıcı verisini güncelle
        _user = _user!.copyWith(
          displayName: displayName ?? _user!.displayName,
          photoUrl: photoUrl ?? _user!.photoUrl,
          bio: bio ?? _user!.bio,
          preferredLanguage: preferredLanguage ?? _user!.preferredLanguage,
        );

        _saveUserDataToPrefs(_user);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenirken bir hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
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
}