// Dosya: lib/views/shared/content_card.dart
// Amaç: İçerikleri Instagram tarzı bir kart formatında gösterir.
// Bağlantı: home_screen.dart, category_screen.dart gibi ekranlarda kullanılır.
// Not: Instagram tarzı tasarım eklendi.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/content_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/extensions.dart';

// İçerik kartı bileşeni
class ContentCard extends StatelessWidget {
  final ContentModel content; // Gösterilecek içerik
  const ContentCard({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı bilgileri
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: content.userPhotoUrl != null
                      ? CachedNetworkImageProvider(content.userPhotoUrl!)
                      : null,
                  child: content.userPhotoUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.userDisplayName ?? l10n.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        content.createdAt?.formatDate() ?? l10n.back,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // İçerik görseli
          if (content.thumbnailUrl != null || (content.mediaUrls != null && content.mediaUrls!.isNotEmpty))
            CachedNetworkImage(
              imageUrl: content.thumbnailUrl ?? content.mediaUrls!.first,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppConstants.lightGray,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppConstants.lightGray,
                child: Icon(Icons.error, color: theme.colorScheme.onSurface),
              ),
            ),
          // İçerik başlığı ve özeti
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title.isNotEmpty ? content.title : l10n.contentTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content.contentJson != null
                      ? _extractTextFromJson(content.contentJson).substring(0, 100)
                      : content.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Etkileşim butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 20),
                  onPressed: () {
                    // Beğeni işlevi eklenebilir
                  },
                ),
                Text(
                  '${content.likeCount} ${l10n.likes}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment, size: 20),
                  onPressed: () {
                    Navigator.pushNamed(context, '/content_detail', arguments: content.id);
                  },
                ),
                Text(
                  '${content.commentCount} ${l10n.comments}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // contentJson'dan metni çıkarır
  String _extractTextFromJson(dynamic json) {
    if (json == null) return '';
    try {
      final ops = json['ops'] as List<dynamic>? ?? [];
      String text = '';
      for (var op in ops) {
        if (op['insert'] is String) {
          text += op['insert'] as String;
        }
      }
      return text.length > 100 ? '${text.substring(0, 100)}...' : text;
    } catch (e) {
      return '';
    }
  }
}