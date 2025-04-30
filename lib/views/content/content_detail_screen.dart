// Dosya: lib/models/content_model.dart
// Amaç: İçerik verilerini temsil eder (başlık, açıklama, medya, kategori).
// Bağlantı: content_viewmodel.dart, home_screen.dart, content_detail_screen.dart’ta kullanılır.
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String language;
  final String? imageUrl;
  final List<String>? mediaUrls;
  final String? videoUrl;
  final String userId;
  final String authorName;
  final String? userPhotoUrl;
  final String? userDisplayName;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime? createdAt;
  final String? thumbnailUrl;
  final String? content;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.language,
    this.imageUrl,
    this.mediaUrls,
    this.videoUrl,
    required this.userId,
    required this.authorName,
    this.userPhotoUrl,
    this.userDisplayName,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    this.createdAt,
    this.thumbnailUrl,
    this.content,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Genel',
      language: map['language'] ?? 'tr',
      imageUrl: map['imageUrl'],
      mediaUrls: map['mediaUrls'] != null ? List<String>.from(map['mediaUrls']) : null,
      videoUrl: map['videoUrl'],
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? 'Bilinmeyen',
      userPhotoUrl: map['userPhotoUrl'],
      userDisplayName: map['userDisplayName'],
      isFeatured: map['isFeatured'] ?? false,
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null),
      thumbnailUrl: map['thumbnailUrl'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'language': language,
      'imageUrl': imageUrl,
      'mediaUrls': mediaUrls,
      'videoUrl': videoUrl,
      'userId': userId,
      'authorName': authorName,
      'userPhotoUrl': userPhotoUrl,
      'userDisplayName': userDisplayName,
      'isFeatured': isFeatured,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'thumbnailUrl': thumbnailUrl,
      'content': content,
    };
  }

  ContentModel copyWith({
    String? title,
    String? description,
    String? category,
    String? language,
    String? imageUrl,
    List<String>? mediaUrls,
    String? videoUrl,
    String? userId,
    String? authorName,
    String? userPhotoUrl,
    String? userDisplayName,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    String? thumbnailUrl,
    String? content,
  }) {
    return ContentModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      language: language ?? this.language,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'ContentModel(id: $id, title: $title, category: $category)';
  }
}