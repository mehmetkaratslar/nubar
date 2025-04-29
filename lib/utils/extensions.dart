import 'package:flutter/material.dart';

// Dosya: lib/utils/extensions.dart
// Amaç: Flutter widget'ları için yardımcı uzantılar içerir.
// Bağlantılar:
// - LoginScreen: Hata mesajları göstermek ve klavyeyi gizlemek için kullanılır.
// - RegisterScreen: Hata mesajları göstermek ve klavyeyi gizlemek için kullanılır.

extension ContextExtensions on BuildContext {
  // Hata mesajı göster
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Klavyeyi gizle
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}