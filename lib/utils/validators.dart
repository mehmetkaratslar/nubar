// Dosya: lib/utils/validators.dart
// Amaç: Form doğrulama kurallarını sağlar (e-posta, şifre, kullanıcı adı).
// Bağlantı: login_screen.dart, register_screen.dart gibi ekranlarda kullanılır.
// Not: Hata mesajları AppLocalizations ile çevrildi, şifre doğrulama güçlendirildi.

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';


// Doğrulama kurallarını içeren sınıf
class Validators {
  // E-posta doğrulama
  static String? email({
    required String? value,
    bool isRequired = false,
    required String message,
  }) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return message; // Zorunlu alan boş
    }
    if (value != null && value.isNotEmpty) {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(value.trim())) {
        return message; // Geçersiz e-posta formatı
      }
    }
    return null; // Geçerli
  }

  // Şifre doğrulama
  static String? password({
    required String? value,
    bool isRequired = false,
    int minLength = 6,
    bool requireNumber = false,
    bool requireUppercase = false,
    bool requireSpecialChar = false,
    String message = 'Geçersiz şifre',
  }) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return message; // Zorunlu alan boş
    }
    if (value != null && value.isNotEmpty) {
      if (value.length < minLength) {
        return message; // Şifre çok kısa
      }
      if (requireNumber && !RegExp(r'\d').hasMatch(value)) {
        return message; // Sayı eksik
      }
      if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
        return message; // Büyük harf eksik
      }
      if (requireSpecialChar &&
          !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return message; // Özel karakter eksik
      }
    }
    return null; // Geçerli
  }

  // Kullanıcı adı doğrulama
  static String? username({
    required String? value,
    bool isRequired = false,
    int minLength = 3,
    int maxLength = 50,
    String message = 'Geçersiz kullanıcı adı',
  }) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return message; // Zorunlu alan boş
    }
    if (value != null && value.isNotEmpty) {
      if (value.length < minLength) {
        return message; // Kullanıcı adı çok kısa
      }
      if (value.length > maxLength) {
        return message; // Kullanıcı adı çok uzun
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        return message; // Geçersiz karakterler
      }
    }
    return null; // Geçerli
  }

  // Form doğrulama örneği (context ile)
  static String? validateEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    return email(
      value: value,
      isRequired: true,
      message: l10n.invalidEmail,
    );
  }

  static String? validatePassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    return password(
      value: value,
      isRequired: true,
      minLength: 8,
      requireNumber: true,
      requireUppercase: true,
      requireSpecialChar: true,
      message: l10n.weakPassword,
    );
  }

  static String? validateUsername(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    return username(
      value: value,
      isRequired: true,
      minLength: 3,
      maxLength: 50,
      message: l10n.requiredField,
    );
  }
}
