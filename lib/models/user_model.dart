import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String role; // "user", "editor", "admin"
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;
  final List<String>? interests; // İlgilendiği kategoriler

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

  // Map'ten UserModel oluştur
  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      id: userId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      role: map['role'] ?? 'user',
      preferredLanguage: map['preferredLanguage'] ?? 'ku-KMR',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      preferences: map['preferences'],
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : null,
    );
  }

  // UserModel'i Map'e dönüştür
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

  // Deep copy ile yeni bir nesne oluştur
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
}