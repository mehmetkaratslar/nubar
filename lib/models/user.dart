// lib/models/user.dart
// Amaç: Kullanıcı modelini tanımlar.
// Konum: lib/models/
// Bağlantı: AuthViewModel ve FirestoreService tarafından kullanılır.

import 'package:nubar/models/user_role.dart';

class User {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String preferredLanguage;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.preferredLanguage,
  });

  // Firestore'dan veri çekerken kullanmak için factory constructor
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.normal,
      ),
      preferredLanguage: data['preferredLanguage'] ?? 'ku',
    );
  }

  // Firestore'a veri kaydederken kullanmak için toMap metodu
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'preferredLanguage': preferredLanguage,
    };
  }
}