// Dosya: lib/models/notification_model.dart
// Amaç: Bildirim verilerini temsil eden bir model sınıfı sağlar.
// Bağlantı: notifications_screen.dart üzerinden FirestoreService ile entegre çalışır.

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });

  // Firestore'dan veri çekmek için
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  // Firestore'a veri kaydetmek için
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}