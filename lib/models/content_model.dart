import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final String category;
  final String language;
  final List<String>? mediaUrls;  // Görsel, video URL'leri
  final String? thumbnailUrl;  // Küçük önizleme resmi
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isFeatured;
  final bool isPublished;
  final Map<String, dynamic>? translatedTitles;  // Farklı dillerde başlıklar
  final Map<String, dynamic>? translatedContents;  // Farklı dillerde içerikler
  final Map<String, dynamic>? customAttributes;  // Ek özellikler

  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.userDisplayName,
    this.userPhotoUrl,
    required this.category,
    required this.language,
    this.mediaUrls,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    required this.isFeatured,
    required this.isPublished,
    this.translatedTitles,
    this.translatedContents,
    this.customAttributes,
  });

  // Map'ten ContentModel oluştur
  factory ContentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ContentModel(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      userDisplayName: map['userDisplayName'],
      userPhotoUrl: map['userPhotoUrl'],
      category: map['category'] ?? '',
      language: map['language'] ?? '',
      mediaUrls: map['mediaUrls'] != null
          ? List<String>.from(map['mediaUrls'])
          : null,
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isPublished: map['isPublished'] ?? true,
      translatedTitles: map['translatedTitles'],
      translatedContents: map['translatedContents'],
      customAttributes: map['customAttributes'],
    );
  }

  // ContentModel'i Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'category': category,
      'language': language,
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'translatedTitles': translatedTitles,
      'translatedContents': translatedContents,
      'customAttributes': customAttributes,
    };
  }

  // Deep copy ile yeni bir nesne oluştur
  ContentModel copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    String? userDisplayName,
    String? userPhotoUrl,
    String? category,
    String? language,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    bool? isFeatured,
    bool? isPublished,
    Map<String, dynamic>? translatedTitles,
    Map<String, dynamic>? translatedContents,
    Map<String, dynamic>? customAttributes,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      category: category ?? this.category,
      language: language ?? this.language,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      translatedTitles: translatedTitles ?? this.translatedTitles,
      translatedContents: translatedContents ?? this.translatedContents,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}