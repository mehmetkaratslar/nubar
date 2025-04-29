// lib/viewmodels/editor_viewmodel.dart
// Editör ViewModel sınıfı
// Kürt kültür platformu için içerik yönetimi işlemlerini yönetir ve UI için durumu tutar

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

// Models
import '../models/content_model.dart';
import '../models/report_model.dart';

// Services
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class EditorViewModel extends ChangeNotifier {
  // Servisler
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AnalyticsService? _analyticsService;

  // İçerik durumu
  List<ContentModel> _editorContents = [];
  List<ContentModel> _draftContents = [];
  List<ContentModel> _publishedContents = [];
  List<ReportModel> _reportedContents = [];
  List<ReportModel> _reportedComments = [];

  // Form durumu
  Map<String, String> _contentTitle = {};
  Map<String, String> _contentText = {};
  Map<String, String> _contentSummary = {};
  ContentCategory _contentCategory = ContentCategory.history;
  ContentType _contentType = ContentType.text;
  List<String> _contentTags = [];

  // Medya dosyaları
  List<File> _selectedMediaFiles = [];
  File? _selectedThumbnail;
  List<String> _mediaUrlsToKeep = [];

  // Yükleme ve hata durumları
  bool _isLoading = false;
  bool _isLoadingDrafts = false;
  bool _isLoadingPublished = false;
  bool _isLoadingReports = false;
  bool _isSubmitting = false;
  String? _error;

  // Getters
  List<ContentModel> get editorContents => _editorContents;
  List<ContentModel> get draftContents => _draftContents;
  List<ContentModel> get publishedContents => _publishedContents;
  List<ReportModel> get reportedContents => _reportedContents;
  List<ReportModel> get reportedComments => _reportedComments;

  Map<String, String> get contentTitle => _contentTitle;
  Map<String, String> get contentText => _contentText;
  Map<String, String> get contentSummary => _contentSummary;
  ContentCategory get contentCategory => _contentCategory;
  ContentType get contentType => _contentType;
  List<String> get contentTags => _contentTags;

  List<File> get selectedMediaFiles => _selectedMediaFiles;
  File? get selectedThumbnail => _selectedThumbnail;
  List<String> get mediaUrlsToKeep => _mediaUrlsToKeep;

  bool get isLoading => _isLoading;
  bool get isLoadingDrafts => _isLoadingDrafts;
  bool get isLoadingPublished => _isLoadingPublished;
  bool get isLoadingReports => _isLoadingReports;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // Constructor
  EditorViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
    AnalyticsService? analyticsService,
  }) : _firestoreService = firestoreService,
        _storageService = storageService,
        _analyticsService = analyticsService;

  // ---------- CONTENT MANAGEMENT ----------

  // Editörün içeriklerini yükleme
  Future<void> loadEditorContents(String editorId) async {
    _setLoading(true);
    _clearError();

    try {
      _editorContents = await _firestoreService.getEditorContents(editorId);
      notifyListeners();
    } catch (e) {
      _setError('İçerikler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Taslak içerikleri yükleme
  Future<void> loadDraftContents(String editorId) async {
    _setLoadingDrafts(true);
    _clearError();

    try {
      _draftContents = await _firestoreService.getEditorContents(
        editorId,
        status: ContentStatus.draft,
      );
      notifyListeners();
    } catch (e) {
      _setError('Taslak içerikler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoadingDrafts(false);
    }
  }

  // Yayınlanmış içerikleri yükleme
  Future<void> loadPublishedContents(String editorId) async {
    _setLoadingPublished(true);
    _clearError();

    try {
      _publishedContents = await _firestoreService.getEditorContents(
        editorId,
        status: ContentStatus.published,
      );
      notifyListeners();
    } catch (e) {
      _setError('Yayınlanmış içerikler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoadingPublished(false);
    }
  }

  // Şikayet edilen içerikleri yükleme
  Future<void> loadReportedContents() async {
    _setLoadingReports(true);
    _clearError();

    try {
      // Bekleyen tüm şikayetleri getir
      final allReports = await _firestoreService.getPendingReports(limit: 50);

      // İçerik ve yorum şikayetlerini ayır
      _reportedContents = allReports.where((report) => report.targetType == 'content').toList();
      _reportedComments = allReports.where((report) => report.targetType == 'comment').toList();

      notifyListeners();
    } catch (e) {
      _setError('Şikayet edilen içerikler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoadingReports(false);
    }
  }

  // İçeriği oluşturma
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
    _setSubmitting(true);
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

      // Form durumunu temizle
      _resetFormState();

      return contentId;
    } catch (e) {
      _setError('İçerik oluşturulurken bir hata oluştu: $e');
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçeriği güncelleme
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
    _setSubmitting(true);
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

      // Form durumunu temizle
      _resetFormState();

      return true;
    } catch (e) {
      _setError('İçerik güncellenirken bir hata oluştu: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik yayınlama
  Future<bool> publishContent(String contentId) async {
    _setSubmitting(true);
    _clearError();

    try {
      await _firestoreService.updateContentStatus(contentId, ContentStatus.published);

      // İçerik bilgilerini al
      final content = await _firestoreService.getContent(contentId);

      // Analytics için içerik yayınlama olayını kaydet
      if (content != null) {
        _analyticsService?.logEvent(
          AnalyticsEventType.editorPublishContent,
          {
            'content_id': contentId,
            'content_type': content.contentType.toString().split('.').last,
            'content_category': content.category.toString().split('.').last,
            'languages_count': content.title.keys.length,
            'languages': content.title.keys.join(','),
          },
        );
      }

      return true;
    } catch (e) {
      _setError('İçerik yayınlanırken bir hata oluştu: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçeriği taslak olarak işaretleme
  Future<bool> unpublishContent(String contentId) async {
    _setSubmitting(true);
    _clearError();

    try {
      await _firestoreService.updateContentStatus(contentId, ContentStatus.draft);
      return true;
    } catch (e) {
      _setError('İçerik taslak olarak işaretlenirken bir hata oluştu: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçeriği arşivleme (silme)
  Future<bool> archiveContent(String contentId) async {
    _setSubmitting(true);
    _clearError();

    try {
      await _firestoreService.updateContentStatus(contentId, ContentStatus.archived);
      return true;
    } catch (e) {
      _setError('İçerik arşivlenirken bir hata oluştu: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // ---------- REPORT MANAGEMENT ----------

  // Şikayet durumunu güncelleme
  Future<bool> updateReportStatus(
      String reportId,
      ReportStatus status,
      String reviewedBy,
      String? notes
      ) async {
    _setSubmitting(true);
    _clearError();

    try {
      await _firestoreService.updateReportStatus(reportId, status, reviewedBy, notes);

      // Şikayet listelerini güncelle
      await loadReportedContents();

      return true;
    } catch (e) {
      _setError('Şikayet durumu güncellenirken bir hata oluştu: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // İçerik formunu hazırla (güncelleme için)
  void prepareContentForm(ContentModel content) {
    _contentTitle = Map.from(content.title);
    _contentText = Map.from(content.content);
    _contentSummary = Map.from(content.summary);
    _contentCategory = content.category;
    _contentType = content.contentType;
    _contentTags = List.from(content.tags);
    _mediaUrlsToKeep = List.from(content.mediaUrls);

    notifyListeners();
  }

  // ---------- FORM MANAGEMENT ----------

  // İçerik başlığını ayarla
  void setContentTitle(String language, String value) {
    _contentTitle[language] = value;
    notifyListeners();
  }

  // İçerik metnini ayarla
  void setContentText(String language, String value) {
    _contentText[language] = value;
    notifyListeners();
  }

  // İçerik özetini ayarla
  void setContentSummary(String language, String value) {
    _contentSummary[language] = value;
    notifyListeners();
  }

  // İçerik kategorisini ayarla
  void setContentCategory(ContentCategory category) {
    _contentCategory = category;
    notifyListeners();
  }

  // İçerik tipini ayarla
  void setContentType(ContentType type) {
    _contentType = type;
    notifyListeners();
  }

  // İçerik etiketlerini ayarla
  void setContentTags(List<String> tags) {
    _contentTags = List.from(tags);
    notifyListeners();
  }

  // Etiket ekle
  void addTag(String tag) {
    if (tag.isNotEmpty && !_contentTags.contains(tag)) {
      _contentTags.add(tag);
      notifyListeners();
    }
  }

  // Etiket kaldır
  void removeTag(String tag) {
    _contentTags.remove(tag);
    notifyListeners();
  }

  // Medya dosyası ekle
  void addMediaFile(File file) {
    _selectedMediaFiles.add(file);
    notifyListeners();
  }

  // Medya dosyasını kaldır
  void removeMediaFile(int index) {
    if (index >= 0 && index < _selectedMediaFiles.length) {
      _selectedMediaFiles.removeAt(index);
      notifyListeners();
    }
  }

  // Mevcut medya URL'sini kaldır
  void removeMediaUrl(String url) {
    _mediaUrlsToKeep.remove(url);
    notifyListeners();
  }

  // Thumbnail ayarla
  void setThumbnail(File? file) {
    _selectedThumbnail = file;
    notifyListeners();
  }

  // Form durumunu temizle
  void _resetFormState() {
    _contentTitle = {};
    _contentText = {};
    _contentSummary = {};
    _contentCategory = ContentCategory.history;
    _contentType = ContentType.text;
    _contentTags = [];
    _selectedMediaFiles = [];
    _selectedThumbnail = null;
    _mediaUrlsToKeep = [];
    notifyListeners();
  }

  // Form durumunu temizle (dışarıdan erişilebilir)
  void resetFormState() {
    _resetFormState();
  }

  // ---------- HELPER METHODS ----------

  // Yükleniyor durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Taslak yükleniyor durumunu ayarla
  void _setLoadingDrafts(bool loading) {
    _isLoadingDrafts = loading;
    notifyListeners();
  }

  // Yayınlanmış içerikler yükleniyor durumunu ayarla
  void _setLoadingPublished(bool loading) {
    _isLoadingPublished = loading;
    notifyListeners();
  }

  // Şikayetler yükleniyor durumunu ayarla
  void _setLoadingReports(bool loading) {
    _isLoadingReports = loading;
    notifyListeners();
  }

  // Gönderiliyor durumunu ayarla
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
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