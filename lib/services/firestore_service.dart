// Dosya: lib/services/firestore_service.dart
// Amaç: Firestore veritabanı ile veri okuma/yazma işlemlerini yönetir.
// Bağlantı: search_viewmodel.dart, home_screen.dart, content_detail_screen.dart, notifications_screen.dart gibi ekranlarda ve ViewModel'lerde kullanılır.
// Not: ServiceException utils/service_exception.dart dosyasından import edildi.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import '../utils/service_exception.dart'; // Özel hata sınıfı

// Firestore işlemlerini yöneten servis sınıfı
class FirestoreService {
  // Firestore örneği
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı verilerini alır
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw ServiceException('Kullanıcı verisi bulunamadı');
      }
      return doc.data(); // Kullanıcı verilerini döndür
    } catch (e) {
      throw ServiceException('Veri alma hatası: $e');
    }
  }

  // Tüm içerikleri çeker
  Future<List<Map<String, dynamic>>> getContents() async {
    try {
      final snapshot = await _db.collection('contents').get();
      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList(); // İçerik listesini döndür
    } catch (e) {
      throw ServiceException('İçerik çekme hatası: $e');
    }
  }

  // İçerikler için sorgu döndürür
  Query<Map<String, dynamic>> getContentsQuery() {
    return _db.collection('contents').orderBy('createdAt', descending: true);
  }

  // Belirli bir içeriği ID ile alır
  Future<Map<String, dynamic>?> getContentById(String id) async {
    try {
      final doc = await _db.collection('contents').doc(id).get();
      if (!doc.exists) {
        return null; // İçerik yoksa null döner
      }
      return {'id': doc.id, ...doc.data()!}; // İçeriği döndür
    } catch (e) {
      throw ServiceException('İçerik alma hatası: $e');
    }
  }

  // Yeni içerik ekler
  Future<void> createContent(ContentModel content) async {
    try {
      await _db.collection('contents').add(content.toMap());
    } catch (e) {
      throw ServiceException('İçerik ekleme hatası: $e');
    }
  }

  // İçeriği günceller
  Future<void> updateContent(ContentModel content) async {
    try {
      await _db.collection('contents').doc(content.id).update(content.toMap());
    } catch (e) {
      throw ServiceException('İçerik güncelleme hatası: $e');
    }
  }

  // İçeriği siler
  Future<void> deleteContent(String contentId) async {
    try {
      await _db.collection('contents').doc(contentId).delete();
    } catch (e) {
      throw ServiceException('İçerik silme hatası: $e');
    }
  }

  // Tüm hikayeleri çeker
  Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final snapshot = await _db.collection('stories').get();
      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList(); // Hikaye listesini döndür
    } catch (e) {
      throw ServiceException('Hikaye çekme hatası: $e');
    }
  }

  // Hikayeler için sorgu döndürür
  Query<Map<String, dynamic>> getStoriesQuery() {
    return _db.collection('stories').orderBy('createdAt', descending: true).limit(10);
  }

  // Tüm bildirimleri çeker
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList(); // Bildirim listesini döndür
    } catch (e) {
      throw ServiceException('Bildirim çekme hatası: $e');
    }
  }

  // İçerik arar
  Future<List<Map<String, dynamic>>> searchContents(String query) async {
    try {
      final snapshot = await _db
          .collection('contents')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList(); // Arama sonuçlarını döndür
    } catch (e) {
      throw ServiceException('Arama hatası: $e');
    }
  }

  // Kullanıcı profilini günceller
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      throw ServiceException('Profil güncelleme hatası: $e');
    }
  }
}