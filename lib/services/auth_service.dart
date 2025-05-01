// Dosya: lib/services/auth_service.dart
// Amaç: Firebase Authentication ile kullanıcı kimlik doğrulama işlemlerini yönetir.
// Bağlantı: AuthViewModel ile entegre çalışır, login_screen.dart ve register_screen.dart üzerinden çağrılır.
// Not: signInWithEmailAndPassword ve registerWithEmailAndPassword metodları eklendi.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/service_exception.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // E-posta ve şifre ile giriş yapar
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } catch (e) {
      throw ServiceException('Giriş hatası: $e');
    }
  }

  // E-posta ve şifre ile kayıt yapar
  Future<User> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(displayName);
      return userCredential.user!;
    } catch (e) {
      throw ServiceException('Kayıt hatası: $e');
    }
  }

  // Google ile giriş yapar
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw ServiceException('Google girişi iptal edildi');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user!;
    } catch (e) {
      throw ServiceException('Google ile giriş hatası: $e');
    }
  }

  // Şifre sıfırlama e-postası gönderir
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw ServiceException('Şifre sıfırlama hatası: $e');
    }
  }

  // Çıkış yapar
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw ServiceException('Çıkış hatası: $e');
    }
  }

  // Mevcut kullanıcıyı getirir
  User? get currentUser => _auth.currentUser;
}