// Dosya: lib/services/firestore_service.dart
// Amaç: Firestore veritabanı işlemlerini yönetir (içerik, yorum, kullanıcı verileri).
// Bağlantı: search_viewmodel.dart, home_screen.dart, content_detail_screen.dart gibi ekranlarda kullanılır.
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı verilerini alır
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Veri alma hatası: $e');
      return null;
    }
  }

  // İçerik listesini çeker
  Future<List<Map<String, dynamic>>> getContents() async {
    try {
      final snapshot = await _db.collection('contents').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('İçerik çekme hatası: $e');
      return [];
    }
  }

  // ID’ye göre içerik alır
  Future<Map<String, dynamic>?> getContentById(String id) async {
    try {
      final doc = await _db.collection('contents').doc(id).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('İçerik alma hatası: $e');
      return null;
    }
  }

  // İçerik ekler
  Future<void> addContent(Map<String, dynamic> content) async {
    try {
      await _db.collection('contents').add(content);
    } catch (e) {
      print('İçerik ekleme hatası: $e');
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
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Arama hatası: $e');
      return [];
    }
  }

  // Kullanıcı profilini günceller (edit_profile_screen.dart için)
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      rethrow;
    }
  }
}