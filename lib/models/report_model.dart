import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String contentId;
  final String contentTitle;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String description;
  final String status; // 'pending', 'resolved', 'rejected'
  final Timestamp createdAt;
  final Timestamp? resolvedAt;

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

  // Firestore'dan veri oluştur
  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      contentId: map['contentId'] ?? '',
      contentTitle: map['contentTitle'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      resolvedAt: map['resolvedAt'],
    );
  }

  // Firestore'a kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentTitle': contentTitle,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
    };
  }

  // Kopyasını oluştur
  ReportModel copyWith({
    String? contentId,
    String? contentTitle,
    String? reporterId,
    String? reporterName,
    String? reason,
    String? description,
    String? status,
    Timestamp? createdAt,
    Timestamp? resolvedAt,
  }) {
    return ReportModel(
      id: this.id,
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

  @override
  String toString() {
    return 'ReportModel(id: $id, contentId: $contentId, status: $status)';
  }
}