// Dosya: lib/views/editor/editor_dashboard.dart
// Amaç: Editör kontrol panelini gösterir, içerik oluşturma ve düzenleme işlemlerini başlatır.
// Bağlantı: app.dart üzerinden çağrılır, EditorViewModel ile entegre çalışır.
// Not: summary ve text parametreleri eklendi.

import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../models/content_status.dart';
import '../../utils/app_constants.dart';

class EditorDashboard extends StatelessWidget {
  const EditorDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryRed,
              Colors.white,
              AppConstants.primaryGreen,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                const Text(
                  'Editör Paneli',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryRed,
                  ),
                ),
                const SizedBox(height: 16),
                // Yeni İçerik Oluştur Butonu
                ElevatedButton(
                  onPressed: () {
                    // Örnek içerik oluştur
                    final content = ContentModel(
                      id: '',
                      title: 'Yeni İçerik',
                      description: '',
                      contentJson: null,
                      category: 'history',
                      mediaUrls: [],
                      thumbnailUrl: null,
                      userId: 'user_id',
                      userDisplayName: 'User Name',
                      authorName: 'User Name',
                      userPhotoUrl: null,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      likeCount: 0,
                      commentCount: 0,
                      viewCount: 0,
                      isFeatured: false,
                      status: ContentStatus.draft,
                      summary: 'Yeni içerik özeti',
                      text: 'Yeni içerik metni',
                    );
                    // İçerik oluşturma ekranına yönlendir
                    Navigator.of(context).pushNamed('/content_editor', arguments: content);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Yeni İçerik Oluştur',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}