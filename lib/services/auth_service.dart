// lib/services/auth_service.dart
// Kimlik doğrulama servisi
// Firebase Authentication ile etkileşimi sağlar ve kimlik doğrulama işlemlerini yönetir

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Şu anki kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumunu dinle
  Stream<User?> get userStream => _auth.authStateChanges();

  // E-posta ve şifre ile kayıt ol
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // E-posta ve şifre ile giriş yap
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google ile giriş yap
  Future<User?> signInWithGoogle() async {
    try {
      // Google ile oturum açma işlemini başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı işlemi iptal etti
        return null;
      }

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Google kimlik bilgilerini kullanarak Firebase'e giriş yap
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google ile giriş yaparken bir hata oluştu: $e');
    }
  }

  // Şifremi unuttum
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // E-posta doğrulama
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      // Google oturumunu kapat (eğer açıksa)
      await _googleSignIn.signOut();
      // Firebase oturumunu kapat
      await _auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yaparken bir hata oluştu: $e');
    }
  }

  // Kullanıcı profilini güncelle
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // E-posta adresini güncelle
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Şifreyi güncelle
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Kullanıcı hesabını sil
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firebase Auth hatalarını işle
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'email-already-in-use':
        message = 'Bu e-posta adresi zaten kullanılıyor.';
        break;
      case 'invalid-email':
        message = 'Geçersiz e-posta adresi formatı.';
        break;
      case 'user-disabled':
        message = 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        break;
      case 'user-not-found':
        message = 'Bu e-posta adresine ait bir kullanıcı bulunamadı.';
        break;
      case 'wrong-password':
        message = 'Yanlış şifre. Lütfen tekrar deneyin.';
        break;
      case 'weak-password':
        message = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
        break;
      case 'operation-not-allowed':
        message = 'Bu işlem şu anda izin verilmiyor.';
        break;
      case 'account-exists-with-different-credential':
        message = 'Bu e-posta farklı bir giriş yöntemiyle zaten kullanılıyor.';
        break;
      case 'requires-recent-login':
        message = 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
        break;
      default:
        message = e.message ?? 'Bilinmeyen bir hata oluştu.';
        break;
    }

    return Exception(message);
  }
}