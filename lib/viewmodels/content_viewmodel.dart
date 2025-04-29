// lib/viewmodels/content_viewmodel.dart
<<<<<<< HEAD
=======

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
// İçerik ViewModel sınıfı
// İçerik işlemlerini yönetir ve UI için durumu tutar

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
<<<<<<< HEAD
=======
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için eklenen import
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

// Models
import '../models/content_model.dart';
import '../models/comment_model.dart';
import '../models/report_model.dart';

// Services
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class ContentViewModel extends ChangeNotifier {
  // Servisler
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AnalyticsService? _analyticsService;

  // İçerik durumu
  List<ContentModel> _contents = [];
  ContentModel? _selectedContent;
  List<CommentModel> _comments = [];

  // Filtreleme durumu
  ContentCategory? _selectedCategory;
  String _searchQuery = '';

  // Sayfalama durumu
  bool _hasMoreContents = true;

  // Yükleme ve hata durumları
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingComments = false;
  String? _error;

  // Getters
  List<ContentModel> get contents => _contents;
  ContentModel? get selectedContent => _selectedContent;
  List<CommentModel> get comments => _comments;
  ContentCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingComments => _isLoadingComments;
  bool get hasMoreContents => _hasMoreContents;
  String? get error => _error;

  // Constructor
  ContentViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
    AnalyticsService? analyticsService,
  }) : _firestoreService = firestoreService,
        _storageService = storageService,
        _analyticsService = analyticsService;

  // İçerikleri yükle (kategori ve dil filtresiyle)
  Future<void> loadContents({
    ContentCategory? category,
    String? language,
    bool refresh = false,
  }) async {
    if (refresh) {
      _setLoading(true);
      _contents = [];
      _hasMoreContents = true;
    } else if (_isLoadingMore || !_hasMoreContents) {
      return;
    } else {
      _setLoadingMore(true);
    }
<<<<<<< HEAD

    _clearError();

    try {
      final startAfter = refresh || _contents.isEmpty
          ? null
          : await _firestoreService.getContent(_contents.last.id);
=======
    _clearError();

    try {
      // Sayfalama için son içeriğin DocumentSnapshot'ını al
      final DocumentSnapshot? startAfterDoc = refresh || _contents.isEmpty
          ? null
          : await _firestoreService.getContentSnapshot(_contents.last.id); // Hata düzeltildi
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

      // Kategorileri güncelle
      _selectedCategory = category;

      // İçerikleri getir
      final newContents = await _firestoreService.getContents(
        category: category,
        language: language,
<<<<<<< HEAD
        startAfter: startAfter,
      );

      // Daha fazla içerik var mı kontrol et
      _hasMoreContents = newContents.length >= 20;
=======
        startAfter: startAfterDoc, // DocumentSnapshot'ı kullan
      );

      // Daha fazla içerik var mı kontrol et
      _hasMoreContents = newContents.length >= 20; // Varsayılan sayfa boyutu 20
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

      if (refresh) {
        _contents = newContents;
      } else {
        _contents.addAll(newContents);
      }

      // Analytics için kategori filtreleme olayını kaydet
      if (category != null) {
        _analyticsService?.logEvent(
          AnalyticsEventType.filterByCategory,
          {
            'category': category.toString().split('.').last,
            'language': language ?? 'all',
          },
        );
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
    }
  }

  // İçerik ara
  Future<void> searchContents(String query, String language) async {
    _setLoading(true);
    _clearError();
    _searchQuery = query;

    try {
      if (query.isEmpty) {
        // Arama temizlendiğinde normal içerikleri yükle
        await loadContents(
          category: _selectedCategory,
          language: language,
          refresh: true,
        );
      } else {
        // Arama sonuçlarını getir
        _contents = await _firestoreService.searchContents(
          query,
          language,
        );
      }

      // Analytics için arama olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.searchContent,
        {
          'search_term': query,
          'language': language,
          'results_count': _contents.length,
        },
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // İçerik detaylarını yükle
  Future<void> loadContentDetails(String contentId) async {
    _setLoading(true);
    _clearError();

    try {
      // İçeriği getir
      final content = await _firestoreService.getContent(contentId);
<<<<<<< HEAD
=======

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      if (content != null) {
        _selectedContent = content;

        // Görüntülenme sayısını arttır
        await _firestoreService.incrementContentViews(contentId);

        // Analytics için içerik görüntüleme olayını kaydet
        _analyticsService?.logEvent(
          AnalyticsEventType.viewContent,
          {
            'content_id': contentId,
            'content_type': content.contentType.toString().split('.').last,
            'content_category': content.category.toString().split('.').last,
          },
        );
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // İçerik yorumlarını yükle
  Future<void> loadComments(String contentId, {String? parentId}) async {
    _setLoadingComments(true);
    _clearError();

    try {
      _comments = await _firestoreService.getContentComments(
        contentId,
        parentId: parentId,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingComments(false);
    }
  }

  // Yorum ekle
  Future<void> addComment({
    required String contentId,
    required String userId,
    required String username,
    String? userPhotoUrl,
    required String text,
    String? parentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Yeni yorum oluştur
      final comment = CommentModel(
        id: '', // Firestore tarafından otomatik oluşturulur
        contentId: contentId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        text: text,
        status: CommentStatus.active,
        likesCount: 0,
        repliesCount: 0,
        parentId: parentId,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      // Yorumu kaydet
      await _firestoreService.createComment(comment);

      // Yorumları yeniden yükle
      await loadComments(contentId, parentId: parentId);

      // Analytics için yorum oluşturma olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.createComment,
        {
          'content_id': contentId,
          'is_reply': parentId != null,
          'parent_id': parentId ?? '',
        },
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Yorumu beğen/beğenme
  Future<void> toggleLikeComment(String userId, String commentId) async {
    try {
      await _firestoreService.toggleLikeComment(userId, commentId);

      // Yorumu güncelle
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex >= 0) {
        final updatedComment = await _firestoreService.getComment(commentId);
        if (updatedComment != null) {
          _comments[commentIndex] = updatedComment;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // İçeriği beğen/beğenme
  Future<void> toggleLikeContent(String userId, String contentId) async {
    try {
      await _firestoreService.toggleLikeContent(userId, contentId);

      // İçeriği güncelle
      if (_selectedContent?.id == contentId) {
        final updatedContent = await _firestoreService.getContent(contentId);
        if (updatedContent != null) {
          _selectedContent = updatedContent;
          notifyListeners();
        }
      }

      // Listede de güncelle
      final contentIndex = _contents.indexWhere((c) => c.id == contentId);
      if (contentIndex >= 0) {
        final updatedContent = await _firestoreService.getContent(contentId);
        if (updatedContent != null) {
          _contents[contentIndex] = updatedContent;
          notifyListeners();
        }
      }

      // Analytics için içerik beğenme olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.likeContent,
        {'content_id': contentId},
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  // İçeriği kaydet/kaydetme
  Future<void> toggleSaveContent(String userId, String contentId) async {
    try {
      await _firestoreService.toggleSaveContent(userId, contentId);

      // Analytics için içerik kaydetme olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.saveContent,
        {'content_id': contentId},
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  // İçeriği paylaş
  Future<void> shareContent(String contentId, String method) async {
    try {
      // Analytics için içerik paylaşma olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.shareContent,
        {
          'content_id': contentId,
          'method': method,
        },
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  // İçeriği şikayet et
  Future<void> reportContent({
    required String contentId,
    required String userId,
    required String username,
    required ReportType type,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Yeni şikayet oluştur
      final report = ReportModel(
        id: '', // Firestore tarafından otomatik oluşturulur
        targetType: 'content',
        targetId: contentId,
        reportedBy: userId,
        reporterUsername: username,
        type: type,
        description: description,
        status: ReportStatus.pending,
        reviewedBy: null,
        notes: null,
        createdAt: DateTime.now(),
        reviewedAt: null,
        resolvedAt: null,
      );

      // Şikayeti kaydet
      await _firestoreService.createReport(report);

      // Analytics için içerik şikayet olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.reportContent,
        {
          'content_id': contentId,
          'report_type': type.toString().split('.').last,
        },
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Yorumu şikayet et
  Future<void> reportComment({
    required String commentId,
    required String userId,
    required String username,
    required ReportType type,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Yeni şikayet oluştur
      final report = ReportModel(
        id: '', // Firestore tarafından otomatik oluşturulur
        targetType: 'comment',
        targetId: commentId,
        reportedBy: userId,
        reporterUsername: username,
        type: type,
        description: description,
        status: ReportStatus.pending,
        reviewedBy: null,
        notes: null,
        createdAt: DateTime.now(),
        reviewedAt: null,
        resolvedAt: null,
      );

      // Şikayeti kaydet
      await _firestoreService.createReport(report);

      // Analytics için yorum şikayet olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.reportComment,
        {
          'comment_id': commentId,
          'report_type': type.toString().split('.').last,
        },
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik oluştur (editör modu)
  Future<String?> createContent({
    required Map<String, String> title,
    required Map<String, String> content,
    required Map<String, String> summary,
    required ContentCategory category,
    required ContentType contentType,
    required String createdBy,
    required List<File> mediaFiles,
    File? thumbnailFile,
    required List<String> tags,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Media dosyalarını yükle
      List<String> mediaUrls = [];
      for (final file in mediaFiles) {
        final url = await _storageService.uploadContentMedia(
          file,
          contentType.toString().split('.').last,
        );
        mediaUrls.add(url);
      }

      // Thumbnail yükle (varsa)
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        thumbnailUrl = await _storageService.uploadThumbnail(thumbnailFile);
      }

      // Yeni içerik oluştur
      final newContent = ContentModel(
        id: '', // Firestore tarafından otomatik oluşturulur
        title: title,
        content: content,
        summary: summary,
        category: category,
        contentType: contentType,
        status: ContentStatus.draft, // Başlangıçta taslak olarak kaydet
        createdBy: createdBy,
        lastEditedBy: null,
        mediaUrls: mediaUrls,
        thumbnailUrl: thumbnailUrl,
        tags: tags,
        likesCount: 0,
        commentsCount: 0,
        viewsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
        publishedAt: null,
      );

      // İçeriği kaydet
      final contentId = await _firestoreService.createContent(newContent);

      // Analytics için içerik oluşturma olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.editorCreateContent,
        {
          'content_id': contentId,
          'content_type': contentType.toString().split('.').last,
          'content_category': category.toString().split('.').last,
        },
      );

      return contentId;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // İçeriği güncelle (editör modu)
  Future<bool> updateContent({
    required String contentId,
    required Map<String, String> title,
    required Map<String, String> content,
    required Map<String, String> summary,
    required ContentCategory category,
    required ContentType contentType,
    required String lastEditedBy,
    List<File>? newMediaFiles,
    List<String>? mediaUrlsToKeep,
    File? newThumbnailFile,
    bool removeThumbnail = false,
    required List<String> tags,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Mevcut içeriği al
      final existingContent = await _firestoreService.getContent(contentId);
      if (existingContent == null) {
        _setError('İçerik bulunamadı');
        return false;
      }

      // Silinecek medya URL'lerini belirle
      final mediaUrlsToDelete = existingContent.mediaUrls
          .where((url) => mediaUrlsToKeep == null || !mediaUrlsToKeep.contains(url))
          .toList();

      // Korunacak medya URL'leri
      final List<String> newMediaUrls = mediaUrlsToKeep ?? [];

      // Yeni medya dosyalarını yükle
      if (newMediaFiles != null && newMediaFiles.isNotEmpty) {
        for (final file in newMediaFiles) {
          final url = await _storageService.uploadContentMedia(
            file,
            contentType.toString().split('.').last,
          );
          newMediaUrls.add(url);
        }
      }

      // Thumbnail işle
      String? thumbnailUrl = existingContent.thumbnailUrl;
      if (newThumbnailFile != null) {
        // Eski thumbnail'ı sil (varsa)
        if (thumbnailUrl != null) {
          await _storageService.deleteFile(thumbnailUrl);
        }
        // Yeni thumbnail'ı yükle
        thumbnailUrl = await _storageService.uploadThumbnail(newThumbnailFile);
      } else if (removeThumbnail && thumbnailUrl != null) {
        // Thumbnail'ı kaldır
        await _storageService.deleteFile(thumbnailUrl);
        thumbnailUrl = null;
      }

      // İçeriği güncelle
      final updatedContent = existingContent.copyWith(
        title: title,
        content: content,
        summary: summary,
        category: category,
        contentType: contentType,
        lastEditedBy: lastEditedBy,
        mediaUrls: newMediaUrls,
        thumbnailUrl: thumbnailUrl,
        tags: tags,
        updatedAt: DateTime.now(),
      );

      // İçeriği kaydet
      await _firestoreService.updateContent(updatedContent);

      // Kullanılmayan medya dosyalarını sil
      for (final url in mediaUrlsToDelete) {
        await _storageService.deleteFile(url);
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik durumunu güncelle (taslak, yayınlandı, arşivlendi)
  Future<bool> updateContentStatus(String contentId, ContentStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateContentStatus(contentId, status);

      // Seçili içeriği güncelle
      if (_selectedContent?.id == contentId) {
        final updatedContent = await _firestoreService.getContent(contentId);
        if (updatedContent != null) {
          _selectedContent = updatedContent;
        }
      }

      // Analytics için içerik yayınlama olayını kaydet (sadece yayınlanma durumunda)
      if (status == ContentStatus.published) {
        _analyticsService?.logEvent(
          AnalyticsEventType.editorPublishContent,
          {'content_id': contentId},
        );
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

<<<<<<< HEAD
  // İçeriği sil (editör modu)
=======
  // İçeriği sil (editör modu) - Aslında arşivlendi olarak işaretler
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<bool> deleteContent(String contentId) async {
    _setLoading(true);
    _clearError();

    try {
      // Mevcut içeriği al
      final existingContent = await _firestoreService.getContent(contentId);
      if (existingContent == null) {
        _setError('İçerik bulunamadı');
        return false;
      }

<<<<<<< HEAD
      // Tüm medya dosyalarını sil
      for (final url in existingContent.mediaUrls) {
        await _storageService.deleteFile(url);
      }

      // Thumbnail'ı sil (varsa)
      if (existingContent.thumbnailUrl != null) {
        await _storageService.deleteFile(existingContent.thumbnailUrl!);
      }

      // İçerik durumunu arşivlendi olarak güncelle
      // Not: Gerçek silme işlemi yerine arşivleme tercih edilebilir
=======
      // Tüm medya dosyalarını sil (isteğe bağlı olarak: arşivleme durumunda silmeyebiliriz)
      // for (final url in existingContent.mediaUrls) {
      //   await _storageService.deleteFile(url);
      // }

      // Thumbnail'ı sil (varsa)
      // if (existingContent.thumbnailUrl != null) {
      //   await _storageService.deleteFile(existingContent.thumbnailUrl!);
      // }

      // İçerik durumunu arşivlendi olarak güncelle
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      await _firestoreService.updateContentStatus(contentId, ContentStatus.archived);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Editörün içeriklerini getir
  Future<void> loadEditorContents(String editorId, {ContentStatus? status}) async {
    _setLoading(true);
    _clearError();

    try {
      _contents = await _firestoreService.getEditorContents(
        editorId,
        status: status,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper metotlar

  // Yükleniyor durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Daha fazla yükleniyor durumunu ayarla
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  // Yorum yükleniyor durumunu ayarla
  void _setLoadingComments(bool loading) {
    _isLoadingComments = loading;
    notifyListeners();
  }

  // Hata durumunu ayarla
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Hata durumunu temizle
  void _clearError() {
    _error = null;
  }
}