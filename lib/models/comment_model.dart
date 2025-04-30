// Dosya: lib/models/comment_model.dart
// Amaç: Yorum verilerini temsil eder.
// Bağlantı: content_viewmodel.dart, content_detail_screen.dart’ta kullanılır.
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Bilinmeyen',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    String? userId,
    String? userName,
    String? text,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, userId: $userId, userName: $userName)';
  }
}