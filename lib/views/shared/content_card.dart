import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/content_model.dart';
import '../../utils/constants.dart';

class ContentCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback onTap;

  const ContentCard({
    Key? key,
    required this.content,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kategori rengini belirleme
    Color categoryColor;
    Icon categoryIcon;

    switch (content.category) {
      case Constants.historyCategory:
        categoryColor = Constants.historyColor;
        categoryIcon = const Icon(Constants.historyIcon, size: 16, color: Colors.white);
        break;
      case Constants.languageCategory:
        categoryColor = Constants.languageColor;
        categoryIcon = const Icon(Constants.languageIcon, size: 16, color: Colors.white);
        break;
      case Constants.artCategory:
        categoryColor = Constants.artColor;
        categoryIcon = const Icon(Constants.artIcon, size: 16, color: Colors.white);
        break;
      case Constants.musicCategory:
        categoryColor = Constants.musicColor;
        categoryIcon = const Icon(Constants.musicIcon, size: 16, color: Colors.white);
        break;
      case Constants.traditionCategory:
        categoryColor = Constants.traditionColor;
        categoryIcon = const Icon(Constants.traditionIcon, size: 16, color: Colors.white);
        break;
      default:
        categoryColor = Constants.primaryColor;
        categoryIcon = const Icon(Icons.article, size: 16, color: Colors.white);
    }

    // Tarih formatını belirle
    String formattedDate = timeago.format(content.createdAt, locale: 'tr');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İçeriğin medyası varsa göster
            if (content.thumbnailUrl != null ||
                (content.mediaUrls != null && content.mediaUrls!.isNotEmpty))
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Constants.defaultRadius),
                  topRight: Radius.circular(Constants.defaultRadius),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    content.thumbnailUrl ?? content.mediaUrls!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Constants.lightGrey,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Constants.darkGrey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Constants.lightGrey,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // İçerik bilgileri
            Padding(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Kategori etiketi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(Constants.smallRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            categoryIcon,
                            const SizedBox(width: 4),
                            Text(
                              content.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Tarih ve beğeni sayısı
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Constants.subtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Başlık
                  Text(
                    content.title,
                    style: Constants.titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // İçerik kısa metni
                  Text(
                    content.content,
                    style: const TextStyle(
                      color: Constants.textColor,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Etkileşim bilgileri
                  Row(
                    children: [
                      // Yazar bilgisi
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: content.userPhotoUrl != null
                            ? NetworkImage(content.userPhotoUrl!)
                            : const NetworkImage(Constants.defaultAvatarUrl),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content.userDisplayName ?? 'Anonim',
                          style: const TextStyle(
                            color: Constants.textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Beğeni sayısı
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: content.likeCount > 0
                            ? Constants.primaryColor
                            : Constants.subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.likeCount.toString(),
                        style: TextStyle(
                          color: content.likeCount > 0
                              ? Constants.primaryColor
                              : Constants.subtextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Yorum sayısı
                      const Icon(
                        Icons.comment,
                        size: 16,
                        color: Constants.subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.commentCount.toString(),
                        style: const TextStyle(
                          color: Constants.subtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}