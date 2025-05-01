// Dosya: lib/models/report_model.dart
// Amaç: Şikayet verilerini temsil eden model sınıfı.
// Bağlantı: editor_viewmodel.dart içinde kullanılır.
// Not: Status için enum eklendi, copyWith tamamlandı.

import 'package:cloud_firestore/cloud_firestore.dart';

// Şikayet durumunu temsil eden enum
enum ReportStatus {
  pending, // Beklemede
  resolved, // Çözüldü
  dismissed, // Reddedildi
}

// Şikayet verilerini temsil eden sınıf
class ReportModel {
  // Şikayetin benzersiz kimliği
  final String id;
  // Şikayet edilen içeriğin kimliği
  final String contentId;
  // Şikayet edilen içeriğin başlığı
  final String contentTitle;
  // Şikayeti yapan kullanıcının kimliği
  final String reporterId;
  // Şikayeti yapan kullanıcının adı
  final String reporterName;
  // Şikayet nedeni
  final String reason;
  // Şikayet açıklaması
  final String description;
  // Şikayet durumu
  final ReportStatus status;
  // Şikayetin oluşturulma tarihi
  final Timestamp createdAt;
  // Şikayetin çözülme tarihi
  final Timestamp? resolvedAt;

  // Constructor: Tüm alanları zorunlu veya opsiyonel olarak alır
  ReportModel({
    required this.id,
    required this.contentId,
    required this.contentTitle,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  // Firestore'dan veri çekmek için factory constructor
  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    final statusString = map['status'] as String? ?? 'pending';
    final statusEnum = _stringToReportStatus(statusString);

    return ReportModel(
      id: id,
      contentId: map['contentId'] ?? '',
      contentTitle: map['contentTitle'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      status: statusEnum,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      resolvedAt: map['resolvedAt'],
    );
  }

  // Firestore'a veri kaydetmek için map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentTitle': contentTitle,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason,
      'description': description,
      'status': _reportStatusToString(status),
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
    };
  }

  // Nesneyi kopyalayarak yeni bir nesne oluşturur (immutability için)
  ReportModel copyWith({
    String? id,
    String? contentId,
    String? contentTitle,
    String? reporterId,
    String? reporterName,
    String? reason,
    String? description,
    ReportStatus? status,
    Timestamp? createdAt,
    Timestamp? resolvedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentTitle: contentTitle ?? this.contentTitle,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  // Nesneyi string olarak temsil eder (hata ayıklama için)
  @override
  String toString() {
    return 'ReportModel(id: $id, contentId: $contentId, status: ${_reportStatusToString(status)})';
  }

  // Status string'ini enum'a dönüştür (güvenli)
  static ReportStatus _stringToReportStatus(String status) {
    switch (status) {
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      case 'pending':
      default:
        return ReportStatus.pending;
    }
  }

  // Enum'u string'e dönüştür
  static String _reportStatusToString(ReportStatus status) {
    switch (status) {
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.dismissed:
        return 'dismissed';
      case ReportStatus.pending:
        return 'pending';
    }
  }
}
