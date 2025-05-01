// Dosya: lib/models/content_model.dart
// Amaç: İçerik modelini tanımlar.
// Bağlantı: content_viewmodel.dart, content_detail_screen.dart gibi sınıflarla entegre çalışır.
// Not: summary ve text alanları eklendi.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'content_status.dart';

class ContentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? contentJson;
  final String category;
  final List<String>? mediaUrls;
  final String? thumbnailUrl;
  final String userId;
  final String userDisplayName;
  final String authorName;
  final String? userPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isFeatured;
  final ContentStatus status;
  final String summary; // Özet alanı eklendi
  final String text; // Metin alanı eklendi

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.contentJson,
    required this.category,
    this.mediaUrls,
    this.thumbnailUrl,
    required this.userId,
    required this.userDisplayName,
    required this.authorName,
    this.userPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.isFeatured,
    required this.status,
    required this.summary,
    required this.text,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      contentJson: map['contentJson'],
      category: map['category'] ?? '',
      mediaUrls: map['mediaUrls'] != null ? List<String>.from(map['mediaUrls']) : null,
      thumbnailUrl: map['thumbnailUrl'],
      userId: map['userId'] ?? '',
      userDisplayName: map['userDisplayName'] ?? '',
      authorName: map['authorName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      status: ContentStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => ContentStatus.draft,
      ),
      summary: map['summary'] ?? '', // Özet alanı eklendi
      text: map['text'] ?? '', // Metin alanı eklendi
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contentJson': contentJson,
      'category': category,
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'authorName': authorName,
      'userPhotoUrl': userPhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'isFeatured': isFeatured,
      'status': status.toString(),
      'summary': summary, // Özet alanı eklendi
      'text': text, // Metin alanı eklendi
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? contentJson,
    String? category,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    String? userId,
    String? userDisplayName,
    String? authorName,
    String? userPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isFeatured,
    ContentStatus? status,
    String? summary,
    String? text,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      contentJson: contentJson ?? this.contentJson,
      category: category ?? this.category,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      authorName: authorName ?? this.authorName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    contentJson,
    category,
    mediaUrls,
    thumbnailUrl,
    userId,
    userDisplayName,
    authorName,
    userPhotoUrl,
    createdAt,
    updatedAt,
    likeCount,
    commentCount,
    viewCount,
    isFeatured,
    status,
    summary,
    text,
  ];
}