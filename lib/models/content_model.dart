// lib/models/content.dart
// Purpose: Defines the Content data model for cultural content.
// Location: lib/models/
// Connection: Used by Firestore services and ViewModels to manage content data.

class Content {
  final String id;
  final String title;
  final String description;
  final String category;
  final String mediaUrl;
  final String language;

  Content({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.mediaUrl,
    required this.language,
  });
}