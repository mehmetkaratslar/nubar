import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirestoreService _firestoreService;

  UserModel? _user;
  List<ContentModel> _userContents = [];
  List<ContentModel> _likedContents = [];
  List<ContentModel> _savedContents = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isMyProfile = true;

  // Constructor ile FirestoreService'i inject edelim
  ProfileViewModel({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  UserModel? get user => _user;
  List<ContentModel> get userContents => _userContents;
  List<ContentModel> get likedContents => _likedContents;
  List<ContentModel> get savedContents => _savedContents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isMyProfile => _isMyProfile;

  // Profil fotoğrafını güncelle
  Future<bool> updateProfilePhoto(String userId, File photoFile) async {
    try {
      _setLoading(true);

      // Resmi Storage'a yükle
      String fileName = 'profile_photos/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      await ref.putFile(photoFile);
      String photoUrl = await ref.getDownloadURL();

      // Firestore'da kullanıcı verisini güncelle
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
      });

      // Yerel kullanıcı nesnesini güncelle
      if (_user != null) {
        _user = _user!.copyWith(photoUrl: photoUrl);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profil fotoğrafı güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Profil bilgilerini güncelle
  Future<bool> updateProfile(String userId, {
    required String displayName,
    String? bio,
  }) async {
    try {
      _setLoading(true);

      // Güncellenecek alanlar
      final updates = <String, dynamic>{
        'displayName': displayName,
      };

      if (bio != null) {
        updates['bio'] = bio;
      }

      // Firestore'da güncelle
      await _firestore.collection('users').doc(userId).update(updates);

      // Yerel kullanıcı nesnesini güncelle
      if (_user != null) {
        _user = _user!.copyWith(
          displayName: displayName,
          bio: bio ?? _user!.bio,
        );
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profil bilgileri güncellenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı profilini yükle
  Future<void> loadUserProfile(String userId, {bool isMyProfile = true}) async {
    try {
      _setLoading(true);
      _isMyProfile = isMyProfile;

      // Kullanıcı bilgilerini getir
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        _user = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
          userId,
        );

        // Kullanıcının içeriklerini, beğenilerini ve kaydedilenlerini getir
        await Future.wait([
          fetchUserContents(userId),
          fetchLikedContents(userId),
          fetchSavedContents(userId),
        ]);

        _errorMessage = null;
      } else {
        _errorMessage = 'Kullanıcı bulunamadı.';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Profil yüklenirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcının içeriklerini getir
  Future<void> fetchUserContents(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('contents')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userContents = snapshot.docs.map((doc) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Kullanıcı içerikleri yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Kullanıcının beğendiği içerikleri getir
  Future<void> fetchLikedContents(String userId) async {
    try {
      // Kullanıcının beğeni koleksiyonlarını al
      QuerySnapshot likeSnapshot = await _firestore
          .collectionGroup('likes')
          .where('userId', isEqualTo: userId)
          .get();

      // Beğenilen içerik ID'lerini topla
      List<String> likedContentIds = likeSnapshot.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toList();

      if (likedContentIds.isEmpty) {
        _likedContents = [];
        return;
      }

      // İçerik sayısı fazlaysa gruplar halinde getir
      List<ContentModel> allLikedContents = [];
      List<List<String>> idBatches = _batchList(likedContentIds, 10);

      for (var batch in idBatches) {
        QuerySnapshot contentSnapshot = await _firestore
            .collection('contents')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        List<ContentModel> batchContents = contentSnapshot.docs.map((doc) {
          return ContentModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        allLikedContents.addAll(batchContents);
      }

      _likedContents = allLikedContents;
    } catch (e) {
      print('Beğenilen içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Kullanıcının kaydettiği içerikleri getir
  Future<void> fetchSavedContents(String userId) async {
    try {
      // Kullanıcının kaydedilmiş içeriklerini al
      DocumentSnapshot userSavedDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved')
          .doc('saved_contents')
          .get();

      if (!userSavedDoc.exists) {
        _savedContents = [];
        return;
      }

      List<String> savedContentIds = List<String>.from(
          (userSavedDoc.data() as Map<String, dynamic>)['contentIds'] ?? []
      );

      if (savedContentIds.isEmpty) {
        _savedContents = [];
        return;
      }

      // İçerik sayısı fazlaysa gruplar halinde getir
      List<ContentModel> allSavedContents = [];
      List<List<String>> idBatches = _batchList(savedContentIds, 10);

      for (var batch in idBatches) {
        QuerySnapshot contentSnapshot = await _firestore
            .collection('contents')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        List<ContentModel> batchContents = contentSnapshot.docs.map((doc) {
          return ContentModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        allSavedContents.addAll(batchContents);
      }

      _savedContents = allSavedContents;
    } catch (e) {
      print('Kaydedilmiş içerikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // İçerik kaydet/kaydı kaldır
  Future<bool> toggleSaveContent(String userId, String contentId) async {
    try {
      _setLoading(true);

      // Kaydedilmiş içerikler dokümanı
      DocumentReference savedDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved')
          .doc('saved_contents');

      // Mevcut kaydedilmiş içerikler listesini al
      DocumentSnapshot savedDoc = await savedDocRef.get();
      List<String> savedContentIds = [];

      if (savedDoc.exists) {
        savedContentIds = List<String>.from(
            (savedDoc.data() as Map<String, dynamic>)['contentIds'] ?? []
        );
      }

      bool isSaved = savedContentIds.contains(contentId);

      // Liste güncellenir
      if (isSaved) {
        savedContentIds.remove(contentId);
      } else {
        savedContentIds.add(contentId);
      }

      // Firestore'da güncellenir
      await savedDocRef.set({
        'contentIds': savedContentIds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Eğer zaten yüklenmişse, yerel listeyi güncelle
      if (_user != null) {
        await fetchSavedContents(userId);
      }

      notifyListeners();
      return !isSaved; // Yeni durumu döndür (true ise kaydedildi, false ise kaldırıldı)
    } catch (e) {
      _errorMessage = 'İçerik kaydedilirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik beğen/beğeniyi kaldır
  Future<bool> toggleLikeContent(String userId, String contentId) async {
    try {
      _setLoading(true);

      // İçerikteki beğeni koleksiyonu
      DocumentReference likeDocRef = _firestore
          .collection('contents')
          .doc(contentId)
          .collection('likes')
          .doc(userId);

      // Beğeni belgesini kontrol et
      DocumentSnapshot likeDoc = await likeDocRef.get();
      bool isLiked = likeDoc.exists;

      if (isLiked) {
        // Beğeniyi kaldır
        await likeDocRef.delete();

        // İçeriğin beğeni sayısını güncelle
        await _firestore.collection('contents').doc(contentId).update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Beğeni ekle
        await likeDocRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // İçeriğin beğeni sayısını güncelle
        await _firestore.collection('contents').doc(contentId).update({
          'likeCount': FieldValue.increment(1),
        });
      }

      // Eğer zaten yüklenmişse, yerel listeyi güncelle
      if (_user != null) {
        await fetchLikedContents(userId);
      }

      notifyListeners();
      return !isLiked; // Yeni durumu döndür (true ise beğenildi, false ise kaldırıldı)
    } catch (e) {
      _errorMessage = 'İçerik beğenilirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İçerik sil
  Future<bool> deleteContent(String contentId) async {
    try {
      _setLoading(true);

      // Firestore'dan içeriği sil
      await _firestore.collection('contents').doc(contentId).delete();

      // İçeriğin bağlı olduğu storage dosyalarını sil
      ContentModel? content = _userContents.firstWhere(
              (content) => content.id == contentId,
          orElse: () => null as ContentModel
      );

      if (content != null && content.mediaUrls != null) {
        for (String mediaUrl in content.mediaUrls!) {
          try {
            // URL'den Storage referansı alınır ve silinir
            Reference ref = _storage.refFromURL(mediaUrl);
            await ref.delete();
          } catch (e) {
            print('Medya dosyası silinirken hata oluştu: ${e.toString()}');
            // İçerik silme işlemi devam etsin, dosya silme hatası göz ardı edilebilir
          }
        }
      }

      // Yerel listeden içeriği kaldır
      _userContents.removeWhere((content) => content.id == contentId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İçerik silinirken hata oluştu: ${e.toString()}';
      print(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Büyük listeleri batch'lere bölen yardımcı metod
  List<List<T>> _batchList<T>(List<T> list, int batchSize) {
    List<List<T>> batches = [];
    for (var i = 0; i < list.length; i += batchSize) {
      int end = (i + batchSize < list.length) ? i + batchSize : list.length;
      batches.add(list.sublist(i, end));
    }
    return batches;
  }

  // Loading state kontrolü
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}