// lib/viewmodels/profile_viewmodel.dart

// Profil ViewModel sınıfı
// Kullanıcı profili işlemlerini yönetir ve UI için durumu tutar

import 'package:flutter/foundation.dart';
import 'dart:io';

// Models
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/comment_model.dart';

// Services
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart'; // AnalyticsService import edildi
import '../utils/analytics_events.dart'; // AnalyticsEventType import edildi

class ProfileViewModel extends ChangeNotifier {
  // Servisler
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AnalyticsService? _analyticsService;

  // Kullanıcı profil durumu
  UserModel? _profileUser;
  List<ContentModel> _userContents = [];
  List<ContentModel> _likedContents = [];
  List<ContentModel> _savedContents = [];
  List<CommentModel> _userComments = [];

  // Aktif tab indeksi
  int _activeTab = 0;

  // Yükleme ve hata durumları
  bool _isLoading = false;
  bool _isUpdatingProfile = false;
  bool _isLoadingContents = false;
  bool _isLoadingComments = false;
  String? _error;

  // Getters
  UserModel? get profileUser => _profileUser;
  List<ContentModel> get userContents => _userContents;
  List<ContentModel> get likedContents => _likedContents;
  List<ContentModel> get savedContents => _savedContents;
  List<CommentModel> get userComments => _userComments;
  int get activeTab => _activeTab;
  bool get isLoading => _isLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isLoadingContents => _isLoadingContents;
  bool get isLoadingComments => _isLoadingComments;
  String? get error => _error;

  // Constructor
  ProfileViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
    required StorageService storageService,
    AnalyticsService? analyticsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _storageService = storageService,
        _analyticsService = analyticsService;

  // Aktif tab değiştir
  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  // Kullanıcı profilini yükle
  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Kullanıcı bilgilerini getir
      final user = await _firestoreService.getUser(userId);

      if (user != null) {
        _profileUser = user;
        // Analytics için profil görüntüleme olayını kaydet
        _analyticsService?.logScreenView(screenName: 'profile_${userId}');
      } else {
        _setError('Kullanıcı bulunamadı');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcının içeriklerini yükle
  Future<void> loadUserContents(String userId) async {
    _setLoadingContents(true);
    _clearError();

    try {
      // Kullanıcı editör ise, oluşturduğu içerikleri getir
      if (_profileUser?.role == UserRole.editor) {
        _userContents = await _firestoreService.getEditorContents(
          userId,
          status: ContentStatus.published,
        );
      } else {
        // Normal kullanıcılar için boş liste döndür (yetki yok)
        _userContents = [];
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingContents(false);
    }
  }

  // Kullanıcının beğendiği içerikleri yükle
  Future<void> loadLikedContents(String userId) async {
    _setLoadingContents(true);
    _clearError();

    try {
      if (_profileUser == null) {
        await loadProfile(userId);
      }

      if (_profileUser != null && _profileUser!.likedContents.isNotEmpty) {
        _likedContents = [];
        // Her beğenilen içeriği getir
        for (final contentId in _profileUser!.likedContents) {
          final content = await _firestoreService.getContent(contentId);
          if (content != null && content.status == ContentStatus.published) {
            _likedContents.add(content);
          }
        }
      } else {
        _likedContents = [];
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingContents(false);
    }
  }

  // Kullanıcının kaydettiği içerikleri yükle
  Future<void> loadSavedContents(String userId) async {
    _setLoadingContents(true);
    _clearError();

    try {
      if (_profileUser == null) {
        await loadProfile(userId);
      }

      if (_profileUser != null && _profileUser!.savedContents.isNotEmpty) {
        _savedContents = [];
        // Her kaydedilen içeriği getir
        for (final contentId in _profileUser!.savedContents) {
          final content = await _firestoreService.getContent(contentId);
          if (content != null && content.status == ContentStatus.published) {
            _savedContents.add(content);
          }
        }
      } else {
        _savedContents = [];
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingContents(false);
    }
  }

  // Kullanıcının yorumlarını yükle
  Future<void> loadUserComments(String userId) async {
    _setLoadingComments(true);
    _clearError();

    try {
      _userComments = await _firestoreService.getUserComments(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingComments(false);
    }
  }

  // İçeriği beğeni listesinden kaldır
  Future<void> unlikeContent(String contentId) async {
    try {
      if (_profileUser == null || !_profileUser!.likedContents.contains(contentId)) {
        return;
      }

      // Firebase'de beğeniyi kaldır
      await _firestoreService.toggleLikeContent(_profileUser!.uid, contentId);

      // Yerel listeyi güncelle
      _likedContents.removeWhere((content) => content.id == contentId);

      // Kullanıcı modelini güncelle
      final updatedLikedContents = List<String>.from(_profileUser!.likedContents);
      updatedLikedContents.remove(contentId);
      _profileUser = _profileUser!.copyWith(
        likedContents: updatedLikedContents,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // İçeriği kaydet listesinden kaldır
  Future<void> unsaveContent(String contentId) async {
    try {
      if (_profileUser == null || !_profileUser!.savedContents.contains(contentId)) {
        return;
      }

      // Firebase'de kaydı kaldır
      await _firestoreService.toggleSaveContent(_profileUser!.uid, contentId);

      // Yerel listeyi güncelle
      _savedContents.removeWhere((content) => content.id == contentId);

      // Kullanıcı modelini güncelle
      final updatedSavedContents = List<String>.from(_profileUser!.savedContents);
      updatedSavedContents.remove(contentId);
      _profileUser = _profileUser!.copyWith(
        savedContents: updatedSavedContents,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Profil fotoğrafını güncelle
  Future<void> updateProfilePhoto(File imageFile) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Eski fotoğrafı kontrol et ve sil (varsa)
      final currentPhotoUrl = _profileUser!.photoUrl;
      if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
        try {
          await _storageService.deleteFile(currentPhotoUrl);
        } catch (e) {
          // Eski fotoğraf silinirken hata olursa yoksay ve devam et
          print('Eski profil fotoğrafı silinirken hata: $e');
        }
      }

      // Yeni fotoğrafı yükle
      final photoUrl = await _storageService.uploadProfileImage(imageFile);

      // Kullanıcı bilgilerini güncelle
      await _authService.updateProfile(photoURL: photoUrl);

      // Firestore'da kullanıcı bilgilerini güncelle
      final updatedUser = _profileUser!.copyWith(photoUrl: photoUrl);
      await _firestoreService.updateUser(updatedUser);

      // Yerel kullanıcı modelini güncelle
      _profileUser = updatedUser;

      // Analytics için profil güncelleme olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.profileUpdate, // Hata düzeltildi [cite: 6]
        {'updated_field': 'profile_photo'},
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // Kullanıcı profil bilgilerini güncelle
  Future<void> updateProfileInfo({
    String? username,
    String? bio,
  }) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Kullanıcı adını güncelle (Firebase Auth)
      if (username != null && username != _profileUser!.username) {
        await _authService.updateProfile(displayName: username);
      }

      // Kullanıcı bilgilerini güncelle (Firestore)
      final updatedUser = _profileUser!.copyWith(
        username: username ?? _profileUser!.username,
        bio: bio ?? _profileUser!.bio,
      );
      await _firestoreService.updateUser(updatedUser);

      // Yerel kullanıcı modelini güncelle
      _profileUser = updatedUser;

      // Analytics için profil güncelleme olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.profileUpdate, // Hata düzeltildi [cite: 7]
        {'updated_field': 'profile_info'},
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // Kullanıcı dil tercihini güncelle
  Future<void> updatePreferredLanguage(String languageCode) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Kullanıcı bilgilerini güncelle
      final updatedUser = _profileUser!.copyWith(
        preferredLanguage: languageCode,
      );

      // Firestore'da güncelle
      await _firestoreService.updateUserLanguage(_profileUser!.uid, languageCode);

      // Yerel kullanıcı modelini güncelle
      _profileUser = updatedUser;

      // Analytics için dil değiştirme olayını kaydet
      _analyticsService?.logEvent(
        AnalyticsEventType.changeLanguage,
        {
          'previous_language': _profileUser!.preferredLanguage,
          'new_language': languageCode,
        },
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // Şifre değiştir
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Önce mevcut şifreyle kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _profileUser!.email,
        currentPassword,
      );

      // Şifreyi güncelle
      await _authService.updatePassword(newPassword);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // E-posta adresini güncelle
  Future<void> updateEmail(String newEmail, String password) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Önce mevcut şifreyle kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _profileUser!.email,
        password,
      );

      // E-posta adresini güncelle
      await _authService.updateEmail(newEmail);

      // Kullanıcı bilgilerini güncelle
      final updatedUser = _profileUser!.copyWith(
        email: newEmail,
      );

      // Firestore'da güncelle
      await _firestoreService.updateUser(updatedUser);

      // Yerel kullanıcı modelini güncelle
      _profileUser = updatedUser;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // Hesap sil
  Future<void> deleteAccount(String password) async {
    _setUpdatingProfile(true);
    _clearError();

    try {
      // Kullanıcının UID'sini kontrol et
      if (_profileUser == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Önce mevcut şifreyle kullanıcıyı doğrula
      await _authService.signInWithEmailAndPassword(
        _profileUser!.email,
        password,
      );

      // Kullanıcı profil fotoğrafını sil (varsa)
      if (_profileUser!.photoUrl != null && _profileUser!.photoUrl!.isNotEmpty) {
        try {
          await _storageService.deleteFile(_profileUser!.photoUrl!);
        } catch (e) {
          // Fotoğraf silinirken hata olursa yoksay ve devam et
          print('Profil fotoğrafı silinirken hata: $e');
        }
      }

      // Kullanıcının Firebase Auth hesabını sil
      await _authService.deleteAccount();

      // Kullanıcının Firestore verilerini sil (veya arşivle)
      // Burada, kullanıcı verilerini tamamen silmek yerine arşivleme yaklaşımı da tercih edilebilir

      // Analytics için hesap silme olayını kaydet
      _analyticsService?.setUserId(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // Yorum sil
  Future<void> deleteComment(String commentId) async {
    try {
      // Yorumu arşivle (tamamen silmek yerine)
      await _firestoreService.updateCommentStatus(
        commentId,
        CommentStatus.deleted,
      );

      // Yerel listeyi güncelle
      _userComments.removeWhere((comment) => comment.id == commentId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper metotlar

  // Yükleniyor durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Profil güncelleniyor durumunu ayarla
  void _setUpdatingProfile(bool updating) {
    _isUpdatingProfile = updating;
    notifyListeners();
  }

  // İçerikler yükleniyor durumunu ayarla
  void _setLoadingContents(bool loading) {
    _isLoadingContents = loading;
    notifyListeners();
  }

  // Yorumlar yükleniyor durumunu ayarla
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