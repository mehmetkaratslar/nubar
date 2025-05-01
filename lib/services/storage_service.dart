// Dosya: lib/services/storage_service.dart
// Amaç: Firebase Storage ile dosya yükleme/silme/indirme işlemlerini yönetir.
// Bağlantı: editor_viewmodel.dart, content_viewmodel.dart ve home_viewmodel.dart ile kullanılır.
// Not: ServiceException utils/service_exception.dart dosyasından import edildi.

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/extensions.dart'; // Dosya türü kontrolleri için
import '../utils/service_exception.dart'; // Özel hata sınıfı

// Storage işlemlerini yöneten servis sınıfı
class StorageService {
  // Firebase Storage örneği
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Genel dosya yükleme (içerik için)
  Future<String> uploadFile(String path, File file) async {
    try {
      // Dosya türünü kontrol et
      if (!file.isImageFile() && !file.isVideoFile()) {
        throw ServiceException('Sadece resim veya video dosyaları yüklenebilir');
      }
      // Dosya boyutunu kontrol et (maksimum 15MB)
      if (file.lengthSync() > 15 * 1024 * 1024) {
        throw ServiceException('Dosya boyutu 15MB\'dan büyük olamaz');
      }
      // Dosyayı Firebase Storage'a yükle
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      // Yüklenen dosyanın URL'sini al
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Dosya yüklenemedi: $e');
    }
  }

  // Hikaye dosyası yükleme (stories için özel metod)
  Future<String> uploadStoryFile(File file) async {
    try {
      // Dosya türünü kontrol et (hikayeler için sadece görsel veya kısa video)
      if (!file.isImageFile() && !file.isVideoFile()) {
        throw ServiceException('Sadece resim veya video dosyaları yüklenebilir');
      }
      // Dosya boyutunu kontrol et (maksimum 5MB, hikayeler için daha düşük sınır)
      if (file.lengthSync() > 5 * 1024 * 1024) {
        throw ServiceException('Hikaye dosyası boyutu 5MB\'dan büyük olamaz');
      }
      // Dosyayı Firebase Storage'a yükle (stories klasörüne)
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + file.path.split('/').last;
      Reference ref = _storage.ref().child('stories/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      // Yüklenen dosyanın URL'sini al
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Hikaye dosyası yüklenemedi: $e');
    }
  }

  // Dosyayı siler
  Future<void> deleteFile(String path) async {
    try {
      // Belirtilen yoldaki dosyayı sil
      await _storage.ref().child(path).delete();
    } catch (e) {
      throw ServiceException('Dosya silinemedi: $e');
    }
  }

  // URL'den dosyayı indirir
  Future<File> downloadFile(String url, String localPath) async {
    try {
      // URL'den dosya referansını al
      final httpsReference = _storage.refFromURL(url);
      // Yerel dosyayı oluştur
      final File file = File(localPath);
      // Dosyayı indir ve yerel dosyaya yaz
      await httpsReference.writeToFile(file);
      return file; // İndirilen dosyayı döndür
    } catch (e) {
      throw ServiceException('Dosya indirilemedi: $e');
    }
  }

  // Klasördeki tüm dosyaları siler
  Future<void> deleteFolder(String path) async {
    try {
      // Klasördeki dosyaları listele
      final ListResult result = await _storage.ref().child(path).listAll();
      // Tüm dosyaları sil
      await Future.wait(result.items.map((ref) => ref.delete()));
      // Alt klasörleri sil
      await Future.wait(result.prefixes.map((ref) => deleteFolder('$path/${ref.name}')));
    } catch (e) {
      throw ServiceException('Klasör silinemedi: $e');
    }
  }
}