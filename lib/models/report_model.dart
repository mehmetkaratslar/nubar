// lib/models/report_model.dart
// Şikayet veri modeli
// Firestore'da saklanan kullanıcı şikayetlerini temsil eder

import 'package:cloud_firestore/cloud_firestore.dart';

// Şikayet türü enum
enum ReportType {
  inappropriate,    // Uygunsuz içerik
  spam,             // Spam
  offensive,        // Hakaret/Saldırgan
  violence,         // Şiddet
  copyright,        // Telif hakkı ihlali
  other,            // Diğer
}

// Şikayet durumu enum
enum ReportStatus {
  pending,      // Beklemede - henüz incelenmedi
  reviewed,     // İncelendi - henüz karar verilmedi
  resolved,     // Çözüldü - gerekli işlem yapıldı
  rejected,     // Reddedildi - şikayet geçersiz
}

// ReportModel sınıfı - Kullanıcı şikayetlerini tutar
class ReportModel {
  // Şikayet kimliği
  final String id;

  // Şikayet edilen içerik türü (content, comment)
  final String targetType;

  // Şikayet edilen içerik ID'si
  final String targetId;

  // Şikayeti yapan kullanıcı ID'si
  final String reportedBy;

  // Şikayeti yapan kullanıcı adı (hızlı erişim için)
  final String reporterUsername;

  // Şikayet türü
  final ReportType type;

  // Şikayet açıklaması
  final String description;

  // Şikayet durumu
  final ReportStatus status;

  // Şikayeti inceleyen editör ID'si
  final String? reviewedBy;

  // Şikayet hakkında notlar (editörler için)
  final String? notes;

  // Şikayet oluşturulma tarihi
  final DateTime createdAt;

  // Şikayet incelenme tarihi
  final DateTime? reviewedAt;

  // Şikayet çözülme tarihi
  final DateTime? resolvedAt;

  // Constructor
  ReportModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reportedBy,
    required this.reporterUsername,
    required this.type,
    required this.description,
    required this.status,
    this.reviewedBy,
    this.notes,
    required this.createdAt,
    this.reviewedAt,
    this.resolvedAt,
  });

  // Firestore belgesi verilerinden ReportModel nesnesi oluştur
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Şikayet türü dönüşümü
    ReportType getReportType(String? typeStr) {
      switch (typeStr) {
        case 'inappropriate': return ReportType.inappropriate;
        case 'spam': return ReportType.spam;
        case 'offensive': return ReportType.offensive;
        case 'violence': return ReportType.violence;
        case 'copyright': return ReportType.copyright;
        case 'other': return ReportType.other;
        default: return ReportType.other;
      }
    }

    // Şikayet durumu dönüşümü
    ReportStatus getReportStatus(String? statusStr) {
      switch (statusStr) {
        case 'pending': return ReportStatus.pending;
        case 'reviewed': return ReportStatus.reviewed;
        case 'resolved': return ReportStatus.resolved;
        case 'rejected': return ReportStatus.rejected;
        default: return ReportStatus.pending;
      }
    }

    return ReportModel(
      id: doc.id,
      targetType: data['targetType'] ?? '',
      targetId: data['targetId'] ?? '',
      reportedBy: data['reportedBy'] ?? '',
      reporterUsername: data['reporterUsername'] ?? '',
      type: getReportType(data['type']),
      description: data['description'] ?? '',
      status: getReportStatus(data['status']),
      reviewedBy: data['reviewedBy'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ReportModel nesnesinden Firestore belgesi verisi oluştur
  Map<String, dynamic> toMap() {
    // Şikayet türü dönüşümü
    String getReportTypeString(ReportType type) {
      switch (type) {
        case ReportType.inappropriate: return 'inappropriate';
        case ReportType.spam: return 'spam';
        case ReportType.offensive: return 'offensive';
        case ReportType.violence: return 'violence';
        case ReportType.copyright: return 'copyright';
        case ReportType.other: return 'other';
      }
    }

    // Şikayet durumu dönüşümü
    String getReportStatusString(ReportStatus status) {
      switch (status) {
        case ReportStatus.pending: return 'pending';
        case ReportStatus.reviewed: return 'reviewed';
        case ReportStatus.resolved: return 'resolved';
        case ReportStatus.rejected: return 'rejected';
      }
    }

    return {
      'targetType': targetType,
      'targetId': targetId,
      'reportedBy': reportedBy,
      'reporterUsername': reporterUsername,
      'type': getReportTypeString(type),
      'description': description,
      'status': getReportStatusString(status),
      'reviewedBy': reviewedBy,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  // Güncellenmiş özelliklerle yeni bir kopya oluştur
  ReportModel copyWith({
    ReportStatus? status,
    String? reviewedBy,
    String? notes,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
  }) {
    return ReportModel(
      id: this.id,
      targetType: this.targetType,
      targetId: this.targetId,
      reportedBy: this.reportedBy,
      reporterUsername: this.reporterUsername,
      type: this.type,
      description: this.description,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}