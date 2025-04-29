// lib/models/comment_model.dart
// Yorum veri modeli
// Firestore'da saklanan kullanıcı yorumlarını temsil eder

import 'package:cloud_firestore/cloud_firestore.dart';

// Yorum durumu enum
enum CommentStatus {
  active,     // Aktif - Herkes görebilir
  hidden,     // Gizli - Moderatör tarafından gizlendi
  deleted,    // Silindi - Kullanıcı tarafından silindi
}

// CommentModel sınıfı - Kullanıcı yorumlarını tutar
class CommentModel {
  // Yorum kimliği
  final String id;

  // Yorum yapılan içerik ID'si
  final String contentId;

  // Yorumu yazan kullanıcı ID'si
  final String userId;

  // Yorumu yazan kullanıcı adı (hızlı erişim için)
  final String username;

  // Yorumu yazan kullanıcının profil fotoğrafı URL'si (hızlı erişim için)
  final String? userPhotoUrl;

  // Yorum metni
  final String text;

  // Yorum durumu
  final CommentStatus status;

  // Yorumu beğenen kullanıcı sayısı
  final int likesCount;

  // Yoruma verilen yanıt sayısı
  final int repliesCount;

  // Üst yorum ID'si (bu bir yanıtsa)
  final String? parentId;

  // Yorum oluşturulma tarihi
  final DateTime createdAt;

  // Yorum düzenlenme tarihi
  final DateTime? updatedAt;

  // Constructor
  CommentModel({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.text,
    required this.status,
    required this.likesCount,
    required this.repliesCount,
    this.parentId,
    required this.createdAt,
    this.updatedAt,
  });

  // Firestore belgesi verilerinden CommentModel nesnesi oluştur
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Yorum durumu dönüşümü
    CommentStatus getStatus(String? statusStr) {
      switch (statusStr) {
        case 'active': return CommentStatus.active;
        case 'hidden': return CommentStatus.hidden;
        case 'deleted': return CommentStatus.deleted;
        default: return CommentStatus.active;
      }
    }

    return CommentModel(
      id: doc.id,
      contentId: data['contentId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      text: data['text'] ?? '',
      status: getStatus(data['status']),
      likesCount: data['likesCount'] ?? 0,
      repliesCount: data['repliesCount'] ?? 0,
      parentId: data['parentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // CommentModel nesnesinden Firestore belgesi verisi oluştur
  Map<String, dynamic> toMap() {
    // Yorum durumu dönüşümü
    String getStatusString(CommentStatus status) {
      switch (status) {
        case CommentStatus.active: return 'active';
        case CommentStatus.hidden: return 'hidden';
        case CommentStatus.deleted: return 'deleted';
      }
    }

    return {
      'contentId': contentId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'status': getStatusString(status),
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Güncellenmiş özelliklerle yeni bir kopya oluştur
  CommentModel copyWith({
    String? text,
    CommentStatus? status,
    int? likesCount,
    int? repliesCount,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: this.id,
      contentId: this.contentId,
      userId: this.userId,
      username: this.username,
      userPhotoUrl: this.userPhotoUrl,
      text: text ?? this.text,
      status: status ?? this.status,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      parentId: this.parentId,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}