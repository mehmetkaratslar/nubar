// Dosya: lib/models/story_model.dart
// Amaç: Hikaye verilerini temsil eden bir model sınıfı sağlar.
// Bağlantı: home_viewmodel.dart üzerinden FirestoreService ile entegre çalışır.

import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String mediaUrl;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.mediaUrl,
    required this.createdAt,
  });

  // Firestore'dan veri çekmek için
  factory StoryModel.fromMap(Map<String, dynamic> map, String id) {
    return StoryModel(
      id: id,
      userId: map['userId'] ?? '',
      userDisplayName: map['userDisplayName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      mediaUrl: map['mediaUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri kaydetmek için
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt,
    };
  }
}