import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı İşlemleri

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(Constants.usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Kullanıcı alınırken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(Constants.usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      print('Kullanıcı oluşturulurken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(Constants.usersCollection).doc(userId).update(updates);
    } catch (e) {
      print('Kullanıcı güncellenirken hata oluştu: $e');
      rethrow;
    }
  }

  // İçerik İşlemleri

  Future<List<ContentModel>> getFeaturedContents({String? language, int limit = 10}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(Constants.contentsCollection)
          .where('isPublished', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return ContentModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Öne çıkan içerikler alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<List<ContentModel>> getContentsByCategory(String category, {String? language, int limit = 20}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(Constants.contentsCollection)
          .where('category', isEqualTo: category)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return ContentModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Kategori içerikleri alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<ContentModel?> getContentById(String contentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(Constants.contentsCollection).doc(contentId).get();
      if (doc.exists) {
        return ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('İçerik alınırken hata oluştu: $e');
      return null;
    }
  }

  Future<String> createContent(ContentModel content) async {
    try {
      DocumentReference docRef = await _firestore.collection(Constants.contentsCollection).add(content.toMap());
      return docRef.id;
    } catch (e) {
      print('İçerik oluşturulurken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> updateContent(String contentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(Constants.contentsCollection).doc(contentId).update(updates);
    } catch (e) {
      print('İçerik güncellenirken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      await _firestore.collection(Constants.contentsCollection).doc(contentId).delete();
    } catch (e) {
      print('İçerik silinirken hata oluştu: $e');
      rethrow;
    }
  }

  // Beğeni İşlemleri

  Future<bool> isContentLikedByUser(String contentId, String userId) async {
    try {
      DocumentSnapshot likeDoc = await _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId)
          .collection(Constants.likesCollection)
          .doc(userId)
          .get();

      return likeDoc.exists;
    } catch (e) {
      print('Beğeni durumu kontrol edilirken hata oluştu: $e');
      return false;
    }
  }

  Future<void> toggleLikeContent(String contentId, String userId) async {
    try {
      DocumentReference likeDocRef = _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId)
          .collection(Constants.likesCollection)
          .doc(userId);

      DocumentReference contentDocRef = _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId);

      DocumentSnapshot likeDoc = await likeDocRef.get();

      await _firestore.runTransaction((transaction) async {
        if (likeDoc.exists) {
          // Beğeniyi kaldır
          transaction.delete(likeDocRef);
          transaction.update(contentDocRef, {
            'likeCount': FieldValue.increment(-1)
          });
        } else {
          // Beğeni ekle
          transaction.set(likeDocRef, {
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(contentDocRef, {
            'likeCount': FieldValue.increment(1)
          });
        }
      });
    } catch (e) {
      print('Beğeni işlemi sırasında hata oluştu: $e');
      rethrow;
    }
  }

  // Yorum İşlemleri

  Future<List<Map<String, dynamic>>> getCommentsForContent(String contentId, {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId)
          .collection(Constants.commentsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> comments = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Yorum sahibinin bilgilerini getir
        String userId = data['userId'] ?? '';
        DocumentSnapshot userDoc = await _firestore
            .collection(Constants.usersCollection)
            .doc(userId)
            .get();

        Map<String, dynamic> comment = {
          'id': doc.id,
          'text': data['text'] ?? '',
          'userId': userId,
          'userDisplayName': userDoc.exists
              ? (userDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Kullanıcı'
              : 'Kullanıcı',
          'userPhotoUrl': userDoc.exists
              ? (userDoc.data() as Map<String, dynamic>)['photoUrl'] ?? Constants.defaultAvatarUrl
              : Constants.defaultAvatarUrl,
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };

        comments.add(comment);
      }

      return comments;
    } catch (e) {
      print('Yorumlar alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<String> addComment(String contentId, String userId, String text) async {
    try {
      // İçeriğin yorum sayısını artır
      DocumentReference contentDocRef = _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId);

      // Yeni yorum ekle
      DocumentReference commentDocRef = contentDocRef
          .collection(Constants.commentsCollection)
          .doc();

      await _firestore.runTransaction((transaction) async {
        transaction.update(contentDocRef, {
          'commentCount': FieldValue.increment(1)
        });

        transaction.set(commentDocRef, {
          'userId': userId,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return commentDocRef.id;
    } catch (e) {
      print('Yorum eklenirken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String contentId, String commentId) async {
    try {
      DocumentReference contentDocRef = _firestore
          .collection(Constants.contentsCollection)
          .doc(contentId);

      DocumentReference commentDocRef = contentDocRef
          .collection(Constants.commentsCollection)
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        transaction.delete(commentDocRef);
        transaction.update(contentDocRef, {
          'commentCount': FieldValue.increment(-1)
        });
      });
    } catch (e) {
      print('Yorum silinirken hata oluştu: $e');
      rethrow;
    }
  }

  // Arama İşlemleri

  Future<List<ContentModel>> searchContents(String query, {String? language, int limit = 20}) async {
    try {
      // Başlık araması (basit çözüm - ideal olarak tam metin araması için Cloud Functions veya Algolia kullanılabilir)
      Query<Map<String, dynamic>> titleQuery = _firestore
          .collection(Constants.contentsCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .limit(limit);

      if (language != null) {
        titleQuery = titleQuery.where('language', isEqualTo: language);
      }

      QuerySnapshot<Map<String, dynamic>> titleSnapshot = await titleQuery.get();

      List<ContentModel> results = titleSnapshot.docs.map((doc) {
        return ContentModel.fromMap(doc.data(), doc.id);
      }).toList();

      return results;
    } catch (e) {
      print('İçerik araması sırasında hata oluştu: $e');
      return [];
    }
  }
}