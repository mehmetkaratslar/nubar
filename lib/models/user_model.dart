// lib/models/user.dart
// Purpose: Defines the User data model for authentication and profiles.
// Location: lib/models/
// Connection: Used by AuthService and ViewModels to manage user data.

class User {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'normal' or 'editor'

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });
}