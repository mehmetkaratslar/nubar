// Dosya: lib/views/shared/content_card.dart
// Amaç: İçerikleri kart formatında gösterir.
// Bağlantı: home_screen.dart, content_list_screen.dart’ta kullanılır.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/content_model.dart';

class ContentCard extends StatelessWidget {
  final ContentModel content;

  const ContentCard({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: content.userPhotoUrl != null
                      ? CachedNetworkImageProvider(content.userPhotoUrl!)
                      : null,
                  child: content.userPhotoUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.userDisplayName ?? 'Bilinmeyen',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      content.createdAt?.toString() ?? 'Tarih bilinmiyor',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (content.thumbnailUrl != null || (content.mediaUrls != null && content.mediaUrls!.isNotEmpty))
              CachedNetworkImage(
                imageUrl: content.thumbnailUrl ?? content.mediaUrls!.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              content.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              content.content ?? content.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border),
                    const SizedBox(width: 4),
                    Text('${content.likeCount} Beğeni'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment),
                    const SizedBox(width: 4),
                    Text('${content.commentCount} Yorum'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}