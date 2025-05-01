// Dosya: lib/models/comment_model.dart
// Amaç: Yorum verilerini temsil eden model sınıfı.
// Bağlantı: content_viewmodel.dart ve content_detail_screen.dart içinde kullanılır.
// Not: copyWith metodu tamamlandı, varsayılan değerler eklendi.

import 'package:cloud_firestore/cloud_firestore.dart';

// Yorum verilerini temsil eden sınıf
class CommentModel {
  // Yorumun benzersiz kimliği
  final String id;
  // Yorumu yapan kullanıcının kimliği
  final String userId;
  // Yorumu yapan kullanıcının adı
  final String userName;
  // Yorum metni
  final String text;
  // Yorumun oluşturulma tarihi
  final DateTime createdAt;

  // Constructor: Tüm alanları zorunlu olarak alır
  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  // Firestore'dan veri çekmek için factory constructor
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      userId: map['userId'] ?? '', // Kullanıcı ID'si yoksa boş string
      userName:
          map['userName'] ?? 'Bilinmeyen', // Kullanıcı adı yoksa varsayılan
      text: map['text'] ?? '', // Yorum metni yoksa boş string
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Tarih yoksa şu anki zaman
    );
  }

  // Firestore'a veri kaydetmek için map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Nesneyi kopyalayarak yeni bir nesne oluşturur (immutability için)
  CommentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Nesneyi string olarak temsil eder (hata ayıklama için)
  @override
  String toString() {
    return 'CommentModel(id: $id, userId: $userId, userName: $userName)';
  }
}
