// lib/services/storage_service.dart
// Firebase Storage servisi
// Medya dosyalarını (görsel, video, ses) yükleme ve yönetme işlemlerini yönetir

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UUID generator
  final Uuid _uuid = const Uuid();

  // ---------- UPLOAD OPERATIONS ----------

  // Dosya yükleme (File nesnesiyle)
  Future<String> uploadFile(File file, String folder) async {
    try {
      // Dosya uzantısını al
      final fileExtension = path.extension(file.path);

      // Benzersiz dosya adı oluştur
      final fileName = '${_uuid.v4()}$fileExtension';

      // Dosya yolu oluştur
      final filePath = '$folder/$fileName';

      // Referans oluştur
      final ref = _storage.ref().child(filePath);

      // Dosyayı yükle
      final uploadTask = ref.putFile(file);

      // Yükleme tamamlanana kadar bekle
      await uploadTask;

      // Dosya URL'sini al ve döndür
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Dosya yüklenirken bir hata oluştu: $e');
    }
  }

  // Dosya yükleme (Byte verisiyle)
  Future<String> uploadBytes(Uint8List bytes, String fileName, String folder) async {
    try {
      // Dosya uzantısını al
      final fileExtension = path.extension(fileName);

      // Benzersiz dosya adı oluştur
      final newFileName = '${_uuid.v4()}$fileExtension';

      // Dosya yolu oluştur
      final filePath = '$folder/$newFileName';

      // Referans oluştur
      final ref = _storage.ref().child(filePath);

      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
      );

      // Dosyayı yükle
      final uploadTask = ref.putData(bytes, metadata);

      // Yükleme tamamlanana kadar bekle
      await uploadTask;

      // Dosya URL'sini al ve döndür
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Dosya yüklenirken bir hata oluştu: $e');
    }
  }

  // URL'den dosya yükleme
  Future<String> uploadFromUrl(String url, String folder) async {
    try {
      // URL'den dosyayı indir
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Dosya indirilemedi. Durum kodu: ${response.statusCode}');
      }

      // Dosya adı için URL'den bilgi al
      final uri = Uri.parse(url);
      final fileName = path.basename(uri.path);

      // Dosya uzantısını al
      final fileExtension = path.extension(fileName);

      // Benzersiz dosya adı oluştur
      final newFileName = '${_uuid.v4()}$fileExtension';

      // Dosya yolu oluştur
      final filePath = '$folder/$newFileName';

      // Referans oluştur
      final ref = _storage.ref().child(filePath);

      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
      );

      // Dosyayı yükle
      final uploadTask = ref.putData(response.bodyBytes, metadata);

      // Yükleme tamamlanana kadar bekle
      await uploadTask;

      // Dosya URL'sini al ve döndür
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('URL\'den dosya yüklenirken bir hata oluştu: $e');
    }
  }

  // Profil resmi yükleme (özel ölçeklendirme)
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // TODO: Burada görüntü işleme ile resim boyutunu küçültme işlemi yapılabilir
      // Şimdilik direkt dosyayı yüklüyoruz
      return await uploadFile(imageFile, 'profile_images');
    } catch (e) {
      throw Exception('Profil resmi yüklenirken bir hata oluştu: $e');
    }
  }

  // İçerik medyası yükleme (görsel, video, ses)
  Future<String> uploadContentMedia(File mediaFile, String contentType) async {
    try {
      // İçerik tipine göre klasör belirle
      String folder;
      switch (contentType) {
        case 'image':
          folder = 'content_images';
          break;
        case 'video':
          folder = 'content_videos';
          break;
        case 'audio':
          folder = 'content_audio';
          break;
        default:
          folder = 'content_other';
          break;
      }

      return await uploadFile(mediaFile, folder);
    } catch (e) {
      throw Exception('İçerik medyası yüklenirken bir hata oluştu: $e');
    }
  }

  // Thumbnail oluşturma ve yükleme
  Future<String> uploadThumbnail(File imageFile) async {
    try {
      // TODO: Burada görüntü işleme ile thumbnail oluşturma yapılabilir
      // Şimdilik direkt dosyayı yüklüyoruz
      return await uploadFile(imageFile, 'thumbnails');
    } catch (e) {
      throw Exception('Thumbnail yüklenirken bir hata oluştu: $e');
    }
  }

  // ---------- DELETE OPERATIONS ----------

  // URL'den dosya silme
  Future<void> deleteFile(String fileUrl) async {
    try {
      // URL'den referans oluştur
      final ref = _storage.refFromURL(fileUrl);

      // Dosyayı sil
      await ref.delete();
    } catch (e) {
      throw Exception('Dosya silinirken bir hata oluştu: $e');
    }
  }

  // Birden fazla dosyayı silme
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      // Her bir URL için silme işlemi yap
      for (final url in fileUrls) {
        await deleteFile(url);
      }
    } catch (e) {
      throw Exception('Dosyalar silinirken bir hata oluştu: $e');
    }
  }

  // İçerik için tüm medyaları silme
  Future<void> deleteContentMedia(List<String> mediaUrls, String? thumbnailUrl) async {
    try {
      // Tüm medya dosyalarını sil
      if (mediaUrls.isNotEmpty) {
        await deleteFiles(mediaUrls);
      }

      // Thumbnail varsa sil
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        await deleteFile(thumbnailUrl);
      }
    } catch (e) {
      throw Exception('İçerik medyaları silinirken bir hata oluştu: $e');
    }
  }

  // ---------- DOWNLOAD OPERATIONS ----------

  // URL'den dosyayı indirme
  Future<File> downloadFile(String fileUrl) async {
    try {
      // URL'den dosyayı indir
      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode != 200) {
        throw Exception('Dosya indirilemedi. Durum kodu: ${response.statusCode}');
      }

      // Dosya adı için URL'den bilgi al
      final uri = Uri.parse(fileUrl);
      final fileName = path.basename(uri.path);

      // Geçici dosya yolu oluştur
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      // Dosyayı kaydet
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      throw Exception('Dosya indirilirken bir hata oluştu: $e');
    }
  }

  // ---------- HELPER METHODS ----------

  // Dosya uzantısına göre MIME tipini belirle
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
    // Görsel formatları
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.webp':
        return 'image/webp';

    // Video formatları
      case '.mp4':
        return 'video/mp4';
      case '.webm':
        return 'video/webm';
      case '.avi':
        return 'video/x-msvideo';
      case '.mov':
        return 'video/quicktime';

    // Ses formatları
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
        return 'audio/mp4';

    // Diğer formatlar
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.txt':
        return 'text/plain';

    // Bilinmeyen formatlar
      default:
        return 'application/octet-stream';
    }
  }
}