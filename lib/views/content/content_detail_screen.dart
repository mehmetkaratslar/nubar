// Dosya: lib/views/content/content_detail_screen.dart
// Amaç: İçerik detaylarını gösterir.
// Bağlantı: app.dart üzerinden çağrılır, ContentViewModel ile entegre çalışır.
// Not: BuildContext parametresi kaldırıldı, hata yönetimi UI katmanına taşındı.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/content_viewmodel.dart';

import '../../utils/app_constants.dart';
import '../../models/content_model.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({Key? key, required this.contentId}) : super(key: key);

  @override
  _ContentDetailScreenState createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // İçerik verilerini asenkron olarak yükle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
      await contentViewModel.loadContent(widget.contentId);
      if (contentViewModel.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(contentViewModel.errorMessage!)),
          );
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentViewModel = Provider.of<ContentViewModel>(context);

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
          child: contentViewModel.isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : contentViewModel.content == null
              ? Center(child: Text(l10n.contentLoadError))
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İçerik Görseli (varsa)
                if (contentViewModel.content!.thumbnailUrl != null)
                  Image.network(
                    contentViewModel.content!.thumbnailUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İçerik Başlığı
                      Text(
                        contentViewModel.content!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // İçerik Özeti
                      Text(
                        contentViewModel.content!.summary,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // İçerik Metni
                      Text(
                        contentViewModel.content!.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      // Beğeni ve Yorum Sayısı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await contentViewModel.likeContent();
                                  if (contentViewModel.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(contentViewModel.errorMessage!)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.favorite),
                                color: AppConstants.primaryRed,
                              ),
                              Text('${contentViewModel.content!.likeCount} ${l10n.likes}'),
                            ],
                          ),
                          Text('${contentViewModel.content!.commentCount} ${l10n.comments}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Yorum Ekleme Alanı
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: l10n.writeComment,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_commentController.text.isNotEmpty) {
                            await contentViewModel.addComment(_commentController.text);
                            if (contentViewModel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(contentViewModel.errorMessage!)),
                              );
                            } else {
                              _commentController.clear();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.addComment,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Silme Butonu
                      ElevatedButton(
                        onPressed: () async {
                          await contentViewModel.deleteContent();
                          if (contentViewModel.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(contentViewModel.errorMessage!)),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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