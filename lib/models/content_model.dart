// lib/models/content_model.dart
// İçerik veri modeli
// Firestore'da saklanan kültürel içerik verilerini temsil eder

import 'package:cloud_firestore/cloud_firestore.dart';

// İçerik kategorileri enum
enum ContentCategory {
  history,    // Tarih
  language,   // Dil
  art,        // Sanat
  music,      // Müzik
  traditions, // Gelenekler
}

// İçerik tipi enum
enum ContentType {
  text,       // Sadece metin
  image,      // Görsel içerik
  video,      // Video içerik
  audio,      // Ses içerik
}

// İçerik durumu enum
enum ContentStatus {
  draft,      // Taslak - henüz yayınlanmadı
  published,  // Yayınlandı - kullanıcılar görebilir
  archived,   // Arşivlendi - artık aktif değil
}

// ContentModel sınıfı - Kültürel içerik verilerini tutar
class ContentModel {
  // İçerik kimliği
  final String id;

  // İçerik başlığı - Çoklu dil desteği için Map yapısı
  // Örnek: {'ku': 'Sernavê Kurdî', 'tr': 'Türkçe Başlık', 'en': 'English Title'}
  final Map<String, String> title;

  // İçerik metni - Çoklu dil desteği için Map yapısı
  final Map<String, String> content;

  // İçerik özeti - Çoklu dil desteği için Map yapısı
  final Map<String, String> summary;

  // İçerik kategorisi
  final ContentCategory category;

  // İçerik tipi
  final ContentType contentType;

  // İçerik durumu
  final ContentStatus status;

  // İçeriği oluşturan kullanıcı ID'si (editör)
  final String createdBy;

  // İçeriği son düzenleyen kullanıcı ID'si
  final String? lastEditedBy;

  // Medya URL'leri (görsel, video, ses dosyaları)
  final List<String> mediaUrls;

  // Thumbnail (önizleme) URL'si
  final String? thumbnailUrl;

  // Etiketler - İçeriği kategorize etmek için
  final List<String> tags;

  // İçeriği beğenen kullanıcı sayısı
  final int likesCount;

  // İçerik yorum sayısı
  final int commentsCount;

  // İçerik görüntülenme sayısı
  final int viewsCount;

  // İçerik oluşturulma tarihi
  final DateTime createdAt;

  // İçerik son düzenlenme tarihi
  final DateTime? updatedAt;

  // İçerik yayınlanma tarihi
  final DateTime? publishedAt;

  // Constructor
  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.category,
    required this.contentType,
    required this.status,
    required this.createdBy,
    this.lastEditedBy,
    required this.mediaUrls,
    this.thumbnailUrl,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  // Firestore belgesi verilerinden ContentModel nesnesi oluştur
  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Kategori dönüşümü
    ContentCategory getCategory(String? categoryStr) {
      switch (categoryStr) {
        case 'history': return ContentCategory.history;
        case 'language': return ContentCategory.language;
        case 'art': return ContentCategory.art;
        case 'music': return ContentCategory.music;
        case 'traditions': return ContentCategory.traditions;
        default: return ContentCategory.history;
      }
    }

    // İçerik tipi dönüşümü
    ContentType getContentType(String? typeStr) {
      switch (typeStr) {
        case 'text': return ContentType.text;
        case 'image': return ContentType.image;
        case 'video': return ContentType.video;
        case 'audio': return ContentType.audio;
        default: return ContentType.text;
      }
    }

    // İçerik durumu dönüşümü
    ContentStatus getStatus(String? statusStr) {
      switch (statusStr) {
        case 'draft': return ContentStatus.draft;
        case 'published': return ContentStatus.published;
        case 'archived': return ContentStatus.archived;
        default: return ContentStatus.draft;
      }
    }

    return ContentModel(
      id: doc.id,
      title: Map<String, String>.from(data['title'] ?? {}),
      content: Map<String, String>.from(data['content'] ?? {}),
      summary: Map<String, String>.from(data['summary'] ?? {}),
      category: getCategory(data['category']),
      contentType: getContentType(data['contentType']),
      status: getStatus(data['status']),
      createdBy: data['createdBy'] ?? '',
      lastEditedBy: data['lastEditedBy'],
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      thumbnailUrl: data['thumbnailUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ContentModel nesnesinden Firestore belgesi verisi oluştur
  Map<String, dynamic> toMap() {
    // Kategori dönüşümü
    String getCategoryString(ContentCategory category) {
      switch (category) {
        case ContentCategory.history: return 'history';
        case ContentCategory.language: return 'language';
        case ContentCategory.art: return 'art';
        case ContentCategory.music: return 'music';
        case ContentCategory.traditions: return 'traditions';
      }
    }

    // İçerik tipi dönüşümü
    String getContentTypeString(ContentType type) {
      switch (type) {
        case ContentType.text: return 'text';
        case ContentType.image: return 'image';
        case ContentType.video: return 'video';
        case ContentType.audio: return 'audio';
      }
    }

    // İçerik durumu dönüşümü
    String getStatusString(ContentStatus status) {
      switch (status) {
        case ContentStatus.draft: return 'draft';
        case ContentStatus.published: return 'published';
        case ContentStatus.archived: return 'archived';
      }
    }

    return {
      'title': title,
      'content': content,
      'summary': summary,
      'category': getCategoryString(category),
      'contentType': getContentTypeString(contentType),
      'status': getStatusString(status),
      'createdBy': createdBy,
      'lastEditedBy': lastEditedBy,
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
    };
  }

  // Güncellenmiş özelliklerle yeni bir kopya oluştur
  ContentModel copyWith({
    Map<String, String>? title,
    Map<String, String>? content,
    Map<String, String>? summary,
    ContentCategory? category,
    ContentType? contentType,
    ContentStatus? status,
    String? lastEditedBy,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return ContentModel(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      createdBy: this.createdBy,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}