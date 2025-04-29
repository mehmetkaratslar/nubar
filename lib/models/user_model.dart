// lib/models/user_model.dart
// Kullanıcı veri modeli
// Firebase Authentication ve Firestore'dan alınan kullanıcı verilerini temsil eder

import 'package:cloud_firestore/cloud_firestore.dart';

// Kullanıcı rolleri enum
enum UserRole {
  // Normal kullanıcı - sadece içerik okuyan, beğenen, yorum yapan
  user,

  // Editör - içerik ekleyebilen, düzenleyebilen ve modere edebilen
  editor,
}

// UserModel sınıfı - Kullanıcı verilerini tutar
class UserModel {
  // Kullanıcı kimliği (Firebase Auth UID)
  final String uid;

  // Kullanıcı adı
  final String username;

  // E-posta adresi
  final String email;

  // Profil fotoğrafı URL'si
  final String? photoUrl;

  // Kullanıcı rolü (normal/editör)
  final UserRole role;

  // Kullanıcı biyografisi
  final String? bio;

  // Tercih edilen dil kodu (ku, tr, en)
  final String preferredLanguage;

  // Hesap oluşturma tarihi
  final DateTime createdAt;

  // Son giriş tarihi
  final DateTime? lastLoginAt;

  // Kullanıcının beğendiği içeriklerin ID'leri
  final List<String> likedContents;

  // Kullanıcının kaydettiği içeriklerin ID'leri
  final List<String> savedContents;

  // Constructor
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.role,
    this.bio,
    required this.preferredLanguage,
    required this.createdAt,
    this.lastLoginAt,
    required this.likedContents,
    required this.savedContents,
  });

  // Firestore belgesi verilerinden UserModel nesnesi oluştur
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] == 'editor' ? UserRole.editor : UserRole.user,
      bio: data['bio'],
      preferredLanguage: data['preferredLanguage'] ?? 'ku',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      likedContents: List<String>.from(data['likedContents'] ?? []),
      savedContents: List<String>.from(data['savedContents'] ?? []),
    );
  }

  // UserModel nesnesinden Firestore belgesi verisi oluştur
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'role': role == UserRole.editor ? 'editor' : 'user',
      'bio': bio,
      'preferredLanguage': preferredLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'likedContents': likedContents,
      'savedContents': savedContents,
    };
  }

  // Güncellenmiş özelliklerle yeni bir kopya oluştur
  UserModel copyWith({
    String? username,
    String? email,
    String? photoUrl,
    UserRole? role,
    String? bio,
    String? preferredLanguage,
    DateTime? lastLoginAt,
    List<String>? likedContents,
    List<String>? savedContents,
  }) {
    return UserModel(
      uid: this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      likedContents: likedContents ?? this.likedContents,
      savedContents: savedContents ?? this.savedContents,
    );
  }
}