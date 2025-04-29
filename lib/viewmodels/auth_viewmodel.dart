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

<<<<<<< HEAD
  // Kimlik doğrulama durumu
=======
  // 🆕 Kullanıcının UID bilgisini almak için Getter
  String get userId => _user?.uid ?? '';

  // Kimlik doğrulama durumu (yükleniyor mu?)
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
        // Kullanıcı zaten var, verileri atama
        _user = userData;
      } else {
        // Kullanıcı veri modelini oluştur ve Firestore'a kaydet
=======
        // Kullanıcı zaten varsa verileri yükle
        _user = userData;
      } else {
        // İlk defa giriş yapan kullanıcı için Firestore'a yeni kayıt oluştur
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
        final newUser = UserModel(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'Kullanıcı',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          role: UserRole.user,
<<<<<<< HEAD
          preferredLanguage: 'ku', // Varsayılan olarak Kürtçe
=======
          preferredLanguage: 'ku', // Varsayılan dil Kürtçe
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          likedContents: [],
          savedContents: [],
        );

<<<<<<< HEAD
        // Firestore'a kaydet
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
        await _firestoreService.createUser(newUser);
        _user = newUser;
      }

      // Son giriş tarihini güncelle
      await _firestoreService.updateUser(
          _user!.copyWith(lastLoginAt: DateTime.now())
      );

<<<<<<< HEAD
      // Kullanıcı ID'sini analytics'e gönder
=======
      // Analytics'e user ID gönder
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
      // Firebase Auth ile kayıt ol
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        // Profil bilgisini güncelle
        await _authService.updateProfile(displayName: username);

        // Analytics
=======
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        await _authService.updateProfile(displayName: username);
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
      // Firebase Auth ile giriş yap
      await _authService.signInWithEmailAndPassword(email, password);

      // Analytics
=======
      await _authService.signInWithEmailAndPassword(email, password);
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
      // Firebase Auth ile Google girişi
      await _authService.signInWithGoogle();

      // Analytics
=======
      await _authService.signInWithGoogle();
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      _analyticsService?.logLogin(method: 'google');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

<<<<<<< HEAD
  // Şifremi unuttum
=======
  // Şifremi unuttum işlemi
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // Çıkış yap
=======
  // Oturumu kapatma
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
<<<<<<< HEAD

      // Analytics user ID'sini temizle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      _analyticsService?.setUserId(null);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

<<<<<<< HEAD
  // Kullanıcı profilini güncelle
=======
  // Kullanıcı profilini güncelleme
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> updateUserProfile({
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    _setLoading(true);

    try {
      if (_user == null) throw Exception('Kullanıcı bulunamadı');

<<<<<<< HEAD
      // Profil fotoğrafı güncellendiyse Firebase Auth'a da güncelle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      if (photoUrl != null) {
        await _authService.updateProfile(photoURL: photoUrl);
      }

<<<<<<< HEAD
      // Username güncellendiyse Firebase Auth'a da güncelle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      if (username != null) {
        await _authService.updateProfile(displayName: username);
      }

<<<<<<< HEAD
      // UserModel'i güncelle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      final updatedUser = _user!.copyWith(
        username: username ?? _user!.username,
        bio: bio ?? _user!.bio,
        photoUrl: photoUrl ?? _user!.photoUrl,
      );

<<<<<<< HEAD
      // Firestore'da güncelle
      await _firestoreService.updateUser(updatedUser);

      // Local state'i güncelle
=======
      await _firestoreService.updateUser(updatedUser);

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
      // UserModel'i güncelle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      final updatedUser = _user!.copyWith(
        preferredLanguage: languageCode,
      );

<<<<<<< HEAD
      // Firestore'da güncelle
      await _firestoreService.updateUserLanguage(_user!.uid, languageCode);

      // Local state'i güncelle
      _user = updatedUser;
      notifyListeners();

      // Analytics
=======
      await _firestoreService.updateUserLanguage(_user!.uid, languageCode);

      _user = updatedUser;
      notifyListeners();

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // E-posta adresini güncelle
=======
  // 🆕 updateUserLanguage metoduna kısa bir alias ekliyoruz
  Future<void> updatePreferredLanguage(String languageCode) async {
    await updateUserLanguage(languageCode);
  }

  // E-posta adresini değiştirme
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> updateEmail(String newEmail, String password) async {
    _setLoading(true);

    try {
<<<<<<< HEAD
      // Önce kullanıcıyı doğrula
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        password,
      );

<<<<<<< HEAD
      // E-posta güncelle
      await _authService.updateEmail(newEmail);

      // UserModel'i güncelle
=======
      await _authService.updateEmail(newEmail);

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      final updatedUser = _user!.copyWith(
        email: newEmail,
      );

<<<<<<< HEAD
      // Firestore'da güncelle
      await _firestoreService.updateUser(updatedUser);

      // Local state'i güncelle
=======
      await _firestoreService.updateUser(updatedUser);

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

<<<<<<< HEAD
  // Şifreyi güncelle
=======
  // Şifre değiştirme
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);

    try {
<<<<<<< HEAD
      // Önce kullanıcıyı doğrula
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        currentPassword,
      );

<<<<<<< HEAD
      // Şifre güncelle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      await _authService.updatePassword(newPassword);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

<<<<<<< HEAD
  // Hesabı sil
=======
  // Hesap silme
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> deleteAccount(String password) async {
    _setLoading(true);

    try {
<<<<<<< HEAD
      // Önce kullanıcıyı doğrula
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      await _authService.signInWithEmailAndPassword(
        _user!.email,
        password,
      );

<<<<<<< HEAD
      // Firestore'dan kullanıcı verilerini sil
      // TODO: Kullanıcıya ait diğer verileri (yorumlar, beğeniler, vb.) silme işlemleri eklenebilir

      // Firebase Auth'dan hesabı sil
      await _authService.deleteAccount();

      // Analytics user ID'sini temizle
=======
      // Firestore verileri silinebilir (geliştirilebilir)

      await _authService.deleteAccount();
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      _analyticsService?.setUserId(null);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

<<<<<<< HEAD
  // Loading durumunu güncelle
=======
  // Loading state yönetimi
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
