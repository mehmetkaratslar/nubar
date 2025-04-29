// lib/services/firestore_service.dart
// Firestore veritabanı servisi
// Firestore ile etkileşimi sağlar ve veri işlemlerini yönetir

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Models
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/comment_model.dart';
import '../models/report_model.dart';

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansları
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _contentsCollection => _firestore.collection('contents');
  CollectionReference get _commentsCollection => _firestore.collection('comments');
  CollectionReference get _reportsCollection => _firestore.collection('reports');

  // ---------- USER OPERATIONS ----------

  // Kullanıcıyı oluştur
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Kullanıcı oluşturulurken bir hata oluştu: $e');
    }
  }

  // Kullanıcıyı getir
  Future<UserModel?> getUser(String uid) async {
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı bilgileri alınırken bir hata oluştu: $e');
    }
  }

  // Kullanıcıyı güncelle
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Kullanıcı güncellenirken bir hata oluştu: $e');
    }
  }

  // Kullanıcı rolünü güncelle
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersCollection.doc(uid).update({
        'role': role == UserRole.editor ? 'editor' : 'user',
      });
    } catch (e) {
      throw Exception('Kullanıcı rolü güncellenirken bir hata oluştu: $e');
    }
  }

  // Kullanıcı dil tercihini güncelle
  Future<void> updateUserLanguage(String uid, String languageCode) async {
    try {
      await _usersCollection.doc(uid).update({
        'preferredLanguage': languageCode,
      });
    } catch (e) {
      throw Exception('Kullanıcı dili güncellenirken bir hata oluştu: $e');
    }
  }

  // Kullanıcı için içerik beğenme/beğenmeme işlemi
  Future<void> toggleLikeContent(String uid, String contentId) async {
    try {
      // Transaction kullanarak veri tutarlılığını sağla
      await _firestore.runTransaction((transaction) async {
        // Kullanıcı belgesini al
        DocumentSnapshot userDoc = await transaction.get(_usersCollection.doc(uid));
        // İçerik belgesini al
        DocumentSnapshot contentDoc = await transaction.get(_contentsCollection.doc(contentId));

        // Kullanıcının beğendiği içerikler listesini al
        List<String> likedContents = List<String>.from(userDoc.get('likedContents') ?? []);

        // İçeriğin mevcut beğeni sayısını al
        int likesCount = contentDoc.get('likesCount') ?? 0;

        // Kullanıcı içeriği zaten beğenmişse, beğeniyi kaldır
        if (likedContents.contains(contentId)) {
          likedContents.remove(contentId);
          likesCount = likesCount > 0 ? likesCount - 1 : 0;
        }
        // Kullanıcı içeriği beğenmemişse, beğeni ekle
        else {
          likedContents.add(contentId);
          likesCount += 1;
        }

        // Kullanıcı belgesini güncelle
        transaction.update(_usersCollection.doc(uid), {
          'likedContents': likedContents,
        });

        // İçerik belgesini güncelle
        transaction.update(_contentsCollection.doc(contentId), {
          'likesCount': likesCount,
        });
      });
    } catch (e) {
      throw Exception('İçerik beğenme işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Kullanıcı için içerik kaydetme/kaydetmeme işlemi
  Future<void> toggleSaveContent(String uid, String contentId) async {
    try {
      // Transaction kullanarak veri tutarlılığını sağla
      await _firestore.runTransaction((transaction) async {
        // Kullanıcı belgesini al
        DocumentSnapshot userDoc = await transaction.get(_usersCollection.doc(uid));

        // Kullanıcının kaydettiği içerikler listesini al
        List<String> savedContents = List<String>.from(userDoc.get('savedContents') ?? []);

        // Kullanıcı içeriği zaten kaydetmişse, kaydı kaldır
        if (savedContents.contains(contentId)) {
          savedContents.remove(contentId);
        }
        // Kullanıcı içeriği kaydetmemişse, kaydet
        else {
          savedContents.add(contentId);
        }

        // Kullanıcı belgesini güncelle
        transaction.update(_usersCollection.doc(uid), {
          'savedContents': savedContents,
        });
      });
    } catch (e) {
      throw Exception('İçerik kaydetme işlemi sırasında bir hata oluştu: $e');
    }
  }

  // ---------- CONTENT OPERATIONS ----------

  // İçerik oluştur
  Future<String> createContent(ContentModel content) async {
    try {
      // ID olmadan yeni belge oluştur
      DocumentReference docRef = await _contentsCollection.add(content.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('İçerik oluşturulurken bir hata oluştu: $e');
    }
  }

  // İçeriği getir
  Future<ContentModel?> getContent(String contentId) async {
    try {
      final DocumentSnapshot doc = await _contentsCollection.doc(contentId).get();
      if (doc.exists) {
        return ContentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('İçerik alınırken bir hata oluştu: $e');
    }
  }

  // İçeriği güncelle
  Future<void> updateContent(ContentModel content) async {
    try {
      await _contentsCollection.doc(content.id).update(content.toMap());
    } catch (e) {
      throw Exception('İçerik güncellenirken bir hata oluştu: $e');
    }
  }

  // İçerik durumunu güncelle (taslak, yayınlandı, arşivlendi)
  Future<void> updateContentStatus(String contentId, ContentStatus status) async {
    try {
      await _contentsCollection.doc(contentId).update({
        'status': status == ContentStatus.draft ? 'draft' :
        status == ContentStatus.published ? 'published' : 'archived',
        'publishedAt': status == ContentStatus.published ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      throw Exception('İçerik durumu güncellenirken bir hata oluştu: $e');
    }
  }

  // İçerik görüntülenme sayısını arttır
  Future<void> incrementContentViews(String contentId) async {
    try {
      await _contentsCollection.doc(contentId).update({
        'viewsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('İçerik görüntülenme sayısı güncellenirken bir hata oluştu: $e');
    }
  }

  // İçerikleri getir (kategori ve dil filtreleriyle)
  Future<List<ContentModel>> getContents({
    ContentCategory? category,
    String? language,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _contentsCollection
          .where('status', isEqualTo: 'published') // Sadece yayınlanmış içerikler
          .orderBy('publishedAt', descending: true);

      // Kategori filtresi ekle
      if (category != null) {
        String categoryStr;
        switch (category) {
          case ContentCategory.history: categoryStr = 'history'; break;
          case ContentCategory.language: categoryStr = 'language'; break;
          case ContentCategory.art: categoryStr = 'art'; break;
          case ContentCategory.music: categoryStr = 'music'; break;
          case ContentCategory.traditions: categoryStr = 'traditions'; break;
        }
        query = query.where('category', isEqualTo: categoryStr);
      }

      // Pagination için startAfter ekle
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Limit ekle
      query = query.limit(limit);

      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await query.get();

      // İçerikleri oluştur
      List<ContentModel> contents = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      // Dil filtresi uygula (if spesifik bir dil isteniyorsa)
      if (language != null && language.isNotEmpty) {
        contents = contents.where((content) =>
        content.title.containsKey(language) &&
            content.content.containsKey(language)
        ).toList();
      }

      return contents;
    } catch (e) {
      throw Exception('İçerikler alınırken bir hata oluştu: $e');
    }
  }

  // İçerikleri arama
  Future<List<ContentModel>> searchContents(
      String query,
      String language,
      {int limit = 20}
      ) async {
    try {
      // Not: Firestore tam metin araması desteklemez, bu yüzden basit bir çözüm kullanıyoruz
      // Gerçek bir uygulamada Algolia veya Firebase Cloud Functions ile bir arama çözümü kullanılmalıdır

      // İçerikleri al (sınırlı sayıda)
      final QuerySnapshot snapshot = await _contentsCollection
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(100) // Sınırlı sayıda al, sonra bellekte filtreleme yapacağız
          .get();

      // İçerikleri oluştur
      List<ContentModel> contents = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      // Arama sorgusu ve dil filtresi uygula
      String queryLower = query.toLowerCase();
      contents = contents.where((content) {
        // Belirtilen dilde içerik var mı kontrol et
        if (!content.title.containsKey(language) || !content.content.containsKey(language)) {
          return false;
        }

        // Başlık ve içerikte arama yap
        final title = content.title[language]?.toLowerCase() ?? '';
        final contentText = content.content[language]?.toLowerCase() ?? '';
        final summary = content.summary[language]?.toLowerCase() ?? '';

        // Etiketlerde arama yap
        final tagsMatch = content.tags.any((tag) => tag.toLowerCase().contains(queryLower));

        return title.contains(queryLower) ||
            contentText.contains(queryLower) ||
            summary.contains(queryLower) ||
            tagsMatch;
      }).toList();

      // Sonuçları limitle ve dön
      return contents.take(limit).toList();
    } catch (e) {
      throw Exception('İçerik araması sırasında bir hata oluştu: $e');
    }
  }

  // Editörün oluşturduğu içerikleri getir
  Future<List<ContentModel>> getEditorContents(
      String editorId,
      {ContentStatus? status, int limit = 20}
      ) async {
    try {
      Query query = _contentsCollection
          .where('createdBy', isEqualTo: editorId)
          .orderBy('createdAt', descending: true);

      // Durum filtresi ekle
      if (status != null) {
        String statusStr;
        switch (status) {
          case ContentStatus.draft: statusStr = 'draft'; break;
          case ContentStatus.published: statusStr = 'published'; break;
          case ContentStatus.archived: statusStr = 'archived'; break;
        }
        query = query.where('status', isEqualTo: statusStr);
      }

      // Limit ekle
      query = query.limit(limit);

      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await query.get();

      // İçerikleri oluştur ve dön
      return snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Editör içerikleri alınırken bir hata oluştu: $e');
    }
  }

  // ---------- COMMENT OPERATIONS ----------

  // Yorum oluştur
  Future<String> createComment(CommentModel comment) async {
    try {
      // Transaction kullanarak veri tutarlılığını sağla
      String commentId = '';
      await _firestore.runTransaction((transaction) async {
        // Yeni yorum belgesini oluştur
        DocumentReference commentRef = _commentsCollection.doc();
        commentId = commentRef.id;

        // İçerik belgesini al
        DocumentSnapshot contentDoc = await transaction.get(_contentsCollection.doc(comment.contentId));

        // İçeriğin mevcut yorum sayısını al
        int commentsCount = contentDoc.get('commentsCount') ?? 0;

        // Eğer bu bir yanıtsa, üst yorumun yanıt sayısını güncelle
        if (comment.parentId != null) {
          DocumentSnapshot parentComment = await transaction.get(_commentsCollection.doc(comment.parentId));
          int repliesCount = parentComment.get('repliesCount') ?? 0;

          // Üst yorumun yanıt sayısını arttır
          transaction.update(_commentsCollection.doc(comment.parentId), {
            'repliesCount': repliesCount + 1,
          });
        }

        // Yorumu ekle
        transaction.set(commentRef, comment.toMap());

        // İçeriğin yorum sayısını güncelle
        transaction.update(_contentsCollection.doc(comment.contentId), {
          'commentsCount': commentsCount + 1,
        });
      });

      return commentId;
    } catch (e) {
      throw Exception('Yorum oluşturulurken bir hata oluştu: $e');
    }
  }

  // Yorumu getir
  Future<CommentModel?> getComment(String commentId) async {
    try {
      final DocumentSnapshot doc = await _commentsCollection.doc(commentId).get();
      if (doc.exists) {
        return CommentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Yorum alınırken bir hata oluştu: $e');
    }
  }

  // Yorumu güncelle
  Future<void> updateComment(CommentModel comment) async {
    try {
      await _commentsCollection.doc(comment.id).update(comment.toMap());
    } catch (e) {
      throw Exception('Yorum güncellenirken bir hata oluştu: $e');
    }
  }

  // Yorum durumunu güncelle (aktif, gizli, silindi)
  Future<void> updateCommentStatus(String commentId, CommentStatus status) async {
    try {
      await _commentsCollection.doc(commentId).update({
        'status': status == CommentStatus.active ? 'active' :
        status == CommentStatus.hidden ? 'hidden' : 'deleted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Yorum durumu güncellenirken bir hata oluştu: $e');
    }
  }

  // İçeriğe ait yorumları getir
  Future<List<CommentModel>> getContentComments(
      String contentId,
      {String? parentId, int limit = 20}
      ) async {
    try {
      Query query = _commentsCollection
          .where('contentId', isEqualTo: contentId)
          .where('status', isEqualTo: 'active');

      // Ana yorumları veya belirli bir yorumun yanıtlarını getir
      if (parentId == null) {
        // Ana yorumları getir (parentId olmayan)
        query = query.where('parentId', isNull: true);
      } else {
        // Belirli bir yorumun yanıtlarını getir
        query = query.where('parentId', isEqualTo: parentId);
      }

      // Tarihe göre sırala ve limit ekle
      query = query.orderBy('createdAt', descending: true).limit(limit);

      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await query.get();

      // Yorumları oluştur ve dön
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('İçerik yorumları alınırken bir hata oluştu: $e');
    }
  }

  // Kullanıcının yorumlarını getir
  Future<List<CommentModel>> getUserComments(String userId, {int limit = 20}) async {
    try {
      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await _commentsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Yorumları oluştur ve dön
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Kullanıcı yorumları alınırken bir hata oluştu: $e');
    }
  }

  // Yorum için beğeni işlemi
  Future<void> toggleLikeComment(String userId, String commentId) async {
    try {
      // Transaction kullanarak veri tutarlılığını sağla
      await _firestore.runTransaction((transaction) async {
        // Yorum belgesini al
        DocumentSnapshot commentDoc = await transaction.get(_commentsCollection.doc(commentId));

        // Yorumun beğeni sayacını al
        int likesCount = commentDoc.get('likesCount') ?? 0;

        // Kullanıcının yorumu beğenip beğenmediğini kontrol et
        // (Bunu yapmak için ayrı bir likes koleksiyonu kullanmak daha iyi olabilir)
        DocumentSnapshot likeDoc = await transaction.get(
            _firestore.collection('commentLikes').doc('$userId-$commentId')
        );

        if (likeDoc.exists) {
          // Kullanıcı yorumu zaten beğenmiş, beğeniyi kaldır
          transaction.delete(_firestore.collection('commentLikes').doc('$userId-$commentId'));
          transaction.update(_commentsCollection.doc(commentId), {
            'likesCount': likesCount > 0 ? likesCount - 1 : 0,
          });
        } else {
          // Kullanıcı yorumu beğenmemiş, beğeni ekle
          transaction.set(_firestore.collection('commentLikes').doc('$userId-$commentId'), {
            'userId': userId,
            'commentId': commentId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(_commentsCollection.doc(commentId), {
            'likesCount': likesCount + 1,
          });
        }
      });
    } catch (e) {
      throw Exception('Yorum beğenme işlemi sırasında bir hata oluştu: $e');
    }
  }

  // ---------- REPORT OPERATIONS ----------

  // Şikayet oluştur
  Future<String> createReport(ReportModel report) async {
    try {
      // ID olmadan yeni belge oluştur
      DocumentReference docRef = await _reportsCollection.add(report.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Şikayet oluşturulurken bir hata oluştu: $e');
    }
  }

  // Şikayeti getir
  Future<ReportModel?> getReport(String reportId) async {
    try {
      final DocumentSnapshot doc = await _reportsCollection.doc(reportId).get();
      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Şikayet alınırken bir hata oluştu: $e');
    }
  }

  // Şikayeti güncelle
  Future<void> updateReport(ReportModel report) async {
    try {
      await _reportsCollection.doc(report.id).update(report.toMap());
    } catch (e) {
      throw Exception('Şikayet güncellenirken bir hata oluştu: $e');
    }
  }

  // Şikayet durumunu güncelle
  Future<void> updateReportStatus(
      String reportId,
      ReportStatus status,
      String reviewedBy,
      String? notes
      ) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status == ReportStatus.pending ? 'pending' :
        status == ReportStatus.reviewed ? 'reviewed' :
        status == ReportStatus.resolved ? 'resolved' : 'rejected',
        'reviewedBy': reviewedBy,
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      // Notlar varsa ekle
      if (notes != null) {
        updateData['notes'] = notes;
      }

      // Çözüldü durumunda, çözülme tarihini de ekle
      if (status == ReportStatus.resolved) {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      await _reportsCollection.doc(reportId).update(updateData);
    } catch (e) {
      throw Exception('Şikayet durumu güncellenirken bir hata oluştu: $e');
    }
  }

  // Bekleyen şikayetleri getir
  Future<List<ReportModel>> getPendingReports({int limit = 20}) async {
    try {
      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await _reportsCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Şikayetleri oluştur ve dön
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Bekleyen şikayetler alınırken bir hata oluştu: $e');
    }
  }

  // Belirli bir hedefin şikayetlerini getir
  Future<List<ReportModel>> getTargetReports(
      String targetType,
      String targetId,
      {int limit = 20}
      ) async {
    try {
      // Sorguyu çalıştır
      final QuerySnapshot snapshot = await _reportsCollection
          .where('targetType', isEqualTo: targetType)
          .where('targetId', isEqualTo: targetId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Şikayetleri oluştur ve dön
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Hedef şikayetleri alınırken bir hata oluştu: $e');
    }
  }

  // Stream'ler (Realtime Updates)

  // Kullanıcı stream'i
  Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // İçerik stream'i
  Stream<ContentModel?> contentStream(String contentId) {
    return _contentsCollection.doc(contentId).snapshots()
        .map((doc) => doc.exists ? ContentModel.fromFirestore(doc) : null);
  }

  // Yorum stream'i
  Stream<List<CommentModel>> contentCommentsStream(String contentId, {String? parentId}) {
    Query query = _commentsCollection
        .where('contentId', isEqualTo: contentId)
        .where('status', isEqualTo: 'active');

    if (parentId == null) {
      query = query.where('parentId', isNull: true);
    } else {
      query = query.where('parentId', isEqualTo: parentId);
    }

    return query.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc))
        .toList());
  }

  // Bekleyen şikayet sayısı stream'i (editörler için bildirim)
  Stream<int> pendingReportsCountStream() {
    return _reportsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // FirestoreService sınıfına eklenmesi gereken custom query metodu

  // Özel sorgu oluşturma (esnek filtreleme ve sıralama için)
  Query customQuery({
    required String collection,
    List<Map<String, dynamic>>? where,
    Map<String, String>? orderBy,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    // Where koşullarını ekle
    if (where != null && where.isNotEmpty) {
      for (final condition in where) {
        condition.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }
    }

    // OrderBy ekle
    if (orderBy != null && orderBy.isNotEmpty) {
      orderBy.forEach((field, direction) {
        query = query.orderBy(
          field,
          descending: direction.toLowerCase() == 'desc',
        );
      });
    }

    // Limit ekle
    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }
}