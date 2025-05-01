// Dosya: lib/models/user_model.dart
// Amaç: Kullanıcı verilerini temsil eden model sınıfı.
// Bağlantı: auth_viewmodel.dart, profile_viewmodel.dart içinde kullanılır.
// Not: User sınıfı ile birleştirildi, preferredLanguage constants.dart ile uyumlu hale getirildi.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart'; // Dil kodları için

// Kullanıcı verilerini temsil eden sınıf
class UserModel {
  // Kullanıcının benzersiz kimliği
  final String id;
  // Kullanıcı e-posta adresi
  final String email;
  // Kullanıcı görünen adı
  final String displayName;
  // Kullanıcı profil resmi URL'si
  final String? photoUrl;
  // Kullanıcı biyografisi
  final String? bio;
  // Kullanıcı rolü (user, editor, admin)
  final String role;
  // Kullanıcının tercih ettiği dil
  final String preferredLanguage;
  // Kullanıcının hesap oluşturma tarihi
  final DateTime createdAt;
  // Kullanıcının son giriş tarihi
  final DateTime lastLoginAt;
  // Kullanıcı hesabının aktiflik durumu
  final bool isActive;
  // Kullanıcı tercihleri (özel ayarlar)
  final Map<String, dynamic>? preferences;
  // Kullanıcının ilgilendiği kategoriler
  final List<String>? interests;

  // Constructor: Tüm alanları zorunlu veya opsiyonel olarak alır
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.role,
    required this.preferredLanguage,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
    this.preferences,
    this.interests,
  });

  // Firestore'dan veri çekmek için factory constructor
  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      id: userId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      role: map['role'] ?? Constants.roleUser, // Varsayılan rol: user
      preferredLanguage: map['preferredLanguage'] ??
          Constants.languageKurdishKur, // Varsayılan dil: ku-KMR
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt:
          (map['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      preferences: map['preferences'],
      interests:
          map['interests'] != null ? List<String>.from(map['interests']) : null,
    );
  }

  // Firestore'a veri kaydetmek için map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'preferredLanguage': preferredLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isActive': isActive,
      'preferences': preferences,
      'interests': interests,
    };
  }

  // Nesneyi kopyalayarak yeni bir nesne oluşturur (immutability için)
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? role,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
    List<String>? interests,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      interests: interests ?? this.interests,
    );
  }

  // Nesneyi string olarak temsil eder (hata ayıklama için)
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }
}
