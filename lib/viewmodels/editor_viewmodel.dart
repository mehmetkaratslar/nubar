import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class EditorViewModel with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<ContentModel> _editorContents = [];
  List<ContentModel> _draftContents = [];
  List<dynamic> _reportedContents = [];
  List<dynamic> _reportedComments = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  EditorViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<ContentModel> get editorContents => _editorContents;
  List<ContentModel> get draftContents => _draftContents;
  List<dynamic> get reportedContents => _reportedContents;
  List<dynamic> get reportedComments => _reportedComments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Editör paneli için içerikleri yükle
  Future<void> loadEditorContents(String editorId) async {
    try {
      _setLoading(true);

      await Future.wait([
        _loadPublishedContents(editorId),
        _loadDraftContents(editorId),
        _loadReportedContents(),
        _loadReportedComments(),
      ]);

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İçerikler yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Yayınlanmış içerikleri yükle
  Future<void> _loadPublishedContents(String editorId) async {
    try {
      // Editör tarafından oluşturulan ve yayınlanmış içerikleri getir
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(Constants.contentsCollection)
          .where('userId', isEqualTo: editorId)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _editorContents = snapshot.docs.map((doc) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Yayınlanmış içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Taslak içerikleri yükle
  Future<void> _loadDraftContents(String editorId) async {
    try {
      // Editör tarafından oluşturulan ve taslak olan içerikleri getir
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(Constants.contentsCollection)
          .where('userId', isEqualTo: editorId)
          .where('isPublished', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .get();

      _draftContents = snapshot.docs.map((doc) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Taslak içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Bildirilen içerikleri yükle
  Future<void> _loadReportedContents() async {
    try {
      // Bildirilen içerikleri getir (raporlar koleksiyonundan)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('type', isEqualTo: 'content')
          .orderBy('createdAt', descending: true)
          .get();

      List<dynamic> reportedItems = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String contentId = data['contentId'] ?? '';

        // İçerik bilgilerini getir
        DocumentSnapshot contentDoc = await FirebaseFirestore.instance
            .collection(Constants.contentsCollection)
            .doc(contentId)
            .get();

        if (contentDoc.exists) {
          // Kullanıcı bilgilerini getir (raporu oluşturan)
          DocumentSnapshot reporterDoc = await FirebaseFirestore.instance
              .collection(Constants.usersCollection)
              .doc(data['reporterId'])
              .get();

          Map<String, dynamic> reportItem = {
            'reportId': doc.id,
            'content': ContentModel.fromMap(
              contentDoc.data() as Map<String, dynamic>,
              contentDoc.id,
            ),
            'reason': data['reason'] ?? 'Belirtilmemiş',
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
            'reporterName': reporterDoc.exists
                ? (reporterDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Kullanıcı'
                : 'Kullanıcı',
            'status': data['status'] ?? 'pending',
          };

          reportedItems.add(reportItem);
        }
      }

      _reportedContents = reportedItems;
    } catch (e) {
      print('Bildirilen içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Bildirilen yorumları yükle
  Future<void> _loadReportedComments() async {
    try {
      // Bildirilen yorumları getir (raporlar koleksiyonundan)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('type', isEqualTo: 'comment')
          .orderBy('createdAt', descending: true)
          .get();

      List<dynamic> reportedItems = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String contentId = data['contentId'] ?? '';
        String commentId = data['commentId'] ?? '';

        // İçerik bilgilerini getir
        DocumentSnapshot contentDoc = await FirebaseFirestore.instance
            .collection(Constants.contentsCollection)
            .doc(contentId)
            .get();

        // Yorum bilgilerini getir
        DocumentSnapshot commentDoc = await FirebaseFirestore.instance
            .collection(Constants.contentsCollection)
            .doc(contentId)
            .collection(Constants.commentsCollection)
            .doc(commentId)
            .get();

        if (contentDoc.exists && commentDoc.exists) {
          // Kullanıcı bilgilerini getir (raporu oluşturan)
          DocumentSnapshot reporterDoc = await FirebaseFirestore.instance
              .collection(Constants.usersCollection)
              .doc(data['reporterId'])
              .get();

          // Yorum sahibinin bilgilerini getir
          DocumentSnapshot commentOwnerDoc = await FirebaseFirestore.instance
              .collection(Constants.usersCollection)
              .doc((commentDoc.data() as Map<String, dynamic>)['userId'])
              .get();

          Map<String, dynamic> reportItem = {
            'reportId': doc.id,
            'content': ContentModel.fromMap(
              contentDoc.data() as Map<String, dynamic>,
              contentDoc.id,
            ),
            'comment': {
              'id': commentId,
              'text': (commentDoc.data() as Map<String, dynamic>)['text'] ?? '',
              'createdAt': ((commentDoc.data() as Map<String, dynamic>)['createdAt'] as Timestamp).toDate(),
              'userId': (commentDoc.data() as Map<String, dynamic>)['userId'] ?? '',
              'userDisplayName': commentOwnerDoc.exists
                  ? (commentOwnerDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Kullanıcı'
                  : 'Kullanıcı',
              'userPhotoUrl': commentOwnerDoc.exists
                  ? (commentOwnerDoc.data() as Map<String, dynamic>)['photoUrl'] ?? Constants.defaultAvatarUrl
                  : Constants.defaultAvatarUrl,
            },
            'reason': data['reason'] ?? 'Belirtilmemiş',
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
            'reporterName': reporterDoc.exists
                ? (reporterDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Kullanıcı'
                : 'Kullanıcı',
            'status': data['status'] ?? 'pending',
          };

          reportedItems.add(reportItem);
        }
      }

      _reportedComments = reportedItems;
    } catch (e) {
      print('Bildirilen yorumlar yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // İçerik durumunu güncelle (yayınla/taslak yap)
  Future<bool> updateContentPublishStatus(String contentId, bool isPublished) async {
    try {
      _setSubmitting(true);

      await _firestoreService.updateContent(contentId, {
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // İçerik listelerini güncelle
      await Future.wait([
        _loadPublishedContents(_getCurrentEditorId()),
        _loadDraftContents(_getCurrentEditorId()),
      ]);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik durumu güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçeriği öne çıkar/kaldır
  Future<bool> updateContentFeaturedStatus(String contentId, bool isFeatured) async {
    try {
      _setSubmitting(true);

      await _firestoreService.updateContent(contentId, {
        'isFeatured': isFeatured,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // İçerik listelerini güncelle
      await _loadPublishedContents(_getCurrentEditorId());

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik öne çıkarma durumu güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Bildirilen içeriğin durumunu güncelle
  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      _setSubmitting(true);

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .update({
        'status': status,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': _getCurrentEditorId(),
      });

      // Bildirimleri yeniden yükle
      await Future.wait([
        _loadReportedContents(),
        _loadReportedComments(),
      ]);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Bildirim durumu güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Bildirilen içeriği veya yorumu kaldır
  Future<bool> removeReportedItem(Map<String, dynamic> reportedItem, bool isComment) async {
    try {
      _setSubmitting(true);

      if (isComment) {
        // Yorumu sil
        String contentId = reportedItem['content'].id;
        String commentId = reportedItem['comment']['id'];

        await _firestoreService.deleteComment(contentId, commentId);
      } else {
        // İçeriği sil
        String contentId = reportedItem['content'].id;

        // İçerik modeli
        ContentModel content = reportedItem['content'];

        // İçeriğin tüm medya dosyalarını sil
        if (content.mediaUrls != null && content.mediaUrls!.isNotEmpty) {
          for (String url in content.mediaUrls!) {
            try {
              // Storage referansını al ve sil
              Reference ref = FirebaseStorage.instance.refFromURL(url);
              await ref.delete();
            } catch (e) {
              print('Medya dosyası silinirken hata oluştu: ${e.toString()}');
              // İşlem devam etsin
            }
          }
        }

        // İçeriği Firestore'dan sil
        await _firestoreService.deleteContent(contentId);
      }

      // Rapor durumunu "resolved" olarak güncelle
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportedItem['reportId'])
          .update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': _getCurrentEditorId(),
        'action': 'removed',
      });

      // Bildirimleri yeniden yükle
      await Future.wait([
        _loadReportedContents(),
        _loadReportedComments(),
      ]);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Bildirim kaldırılırken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik istatistiklerini al (beğeni ve yorum sayıları)
  Future<Map<String, dynamic>> getContentStats(String contentId) async {
    try {
      // İçerik bilgilerini getir
      ContentModel? content = await _firestoreService.getContentById(contentId);

      if (content != null) {
        return {
          'likeCount': content.likeCount,
          'commentCount': content.commentCount,
        };
      }

      return {
        'likeCount': 0,
        'commentCount': 0,
      };
    } catch (e) {
      print('İçerik istatistikleri alınırken hata oluştu: ${e.toString()}');
      return {
        'likeCount': 0,
        'commentCount': 0,
      };
    }
  }

  // Kullanıcı istatistiklerini al (içerik sayısı, toplam beğeni ve yorum sayısı)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Kullanıcının tüm içeriklerini getir
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(Constants.contentsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      int contentCount = snapshot.docs.length;
      int totalLikes = 0;
      int totalComments = 0;

      // Beğeni ve yorum sayılarını topla
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalLikes += data['likeCount'] ?? 0;
        totalComments += data['commentCount'] ?? 0;
      }

      return {
        'contentCount': contentCount,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
      };
    } catch (e) {
      print('Kullanıcı istatistikleri alınırken hata oluştu: ${e.toString()}');
      return {
        'contentCount': 0,
        'totalLikes': 0,
        'totalComments': 0,
      };
    }
  }

  // Mevcut editör ID'sini al (yardımcı metod)
  String _getCurrentEditorId() {
    // Bu metodu gerçek uygulamada, mevcut giriş yapmış editörün ID'sini döndürecek şekilde güncelleyin
    // Örnek olarak boş string döndürüyoruz
    return '';
  }

  // Loading durumunu ayarla
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Submitting durumunu ayarla
  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}