// Dosya: lib/services/auth_service.dart
// Amaç: Firebase Authentication işlemlerini yönetir (kullanıcı girişi, çıkışı, rol yönetimi).
// Bağlantı: auth_viewmodel.dart, login_screen.dart, register_screen.dart gibi ekranlarda kullanılır.
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FirebaseAuth örneğini döndürür
  FirebaseAuth getFirebaseAuth() {
    return _auth;
  }

  // Geçerli kullanıcıyı döndürür
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // E-posta ve şifre ile giriş yapar
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print('Giriş hatası: $e');
      return null;
    }
  }

  // Google ile giriş (opsiyonel, gerektiğinde kullanılır)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final result = await _auth.signInWithProvider(googleProvider);
      return result.user;
    } catch (e) {
      print('Google giriş hatası: $e');
      return null;
    }
  }

  // E-posta ve şifre ile kayıt yapar
  Future<User?> register(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(displayName);
      return result.user;
    } catch (e) {
      print('Kayıt hatası: $e');
      return null;
    }
  }

  // Kullanıcı çıkışı yapar
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Çıkış hatası: $e');
      rethrow;
    }
  }
}