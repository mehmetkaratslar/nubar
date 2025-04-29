import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/content_model.dart';
import '../../utils/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../shared/loading_indicator.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({
    Key? key,
    required this.contentId,
  }) : super(key: key);

  @override
  _ContentDetailScreenState createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // İçeriği yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    await contentViewModel.loadContent(
      widget.contentId,
      authViewModel.user?.id ?? '',
    );
  }

  Future<void> _toggleLike() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    if (authViewModel.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İçeriği beğenmek için giriş yapmalısınız'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await contentViewModel.toggleLike(
      widget.contentId,
      authViewModel.user!.id,
    );
  }

  Future<void> _addComment() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    if (authViewModel.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum yapmak için giriş yapmalısınız'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final success = await contentViewModel.addComment(
      widget.contentId,
      authViewModel.user!.id,
      _commentController.text.trim(),
    );

    if (success) {
      _commentController.clear();
    }
  }

  void _shareContent() {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    final content = contentViewModel.currentContent;

    if (content == null) return;

    // Dinamik derin bağlantı oluşturma
    // Not: Gerçek uygulamada burada Firebase Dynamic Links kullanılabilir
    final url = 'https://nubar-app.com/content/${content.id}';

    Share.share(
      'Nûbar\'da bu içeriği keşfedin: ${content.title}\n\n$url',
      subject: content.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Consumer<ContentViewModel>(
        builder: (context, contentViewModel, _) {
          final content = contentViewModel.currentContent;

          if (contentViewModel.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (content == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Constants.subtextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contentViewModel.errorMessage ?? 'İçerik bulunamadı',
                    style: Constants.bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                    ),
                    child: const Text('Geri Dön'),
                  ),
                ],
              ),
            );
          }

          // Kategori rengini belirleme
          Color categoryColor;

          switch (content.category) {
            case Constants.historyCategory:
              categoryColor = Constants.historyColor;
              break;
            case Constants.languageCategory:
              categoryColor = Constants.languageColor;
              break;
            case Constants.artCategory:
              categoryColor = Constants.artColor;
              break;
            case Constants.musicCategory:
              categoryColor = Constants.musicColor;
              break;
            case Constants.traditionCategory:
              categoryColor = Constants.traditionColor;
              break;
            default:
              categoryColor = Constants.primaryColor;
          }

          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: content.mediaUrls != null && content.mediaUrls!.isNotEmpty ? 250 : 0,
                pinned: true,
                backgroundColor: categoryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: content.mediaUrls != null && content.mediaUrls!.isNotEmpty
                      ? Image.network(
                    content.mediaUrls!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: categoryColor.withOpacity(0.8),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: categoryColor,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareContent,
                  ),
                ],
              ),

              // İçerik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori ve tarih
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(Constants.smallRadius),
                            ),
                            child: Text(
                              content.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            timeago.format(content.createdAt, locale: 'tr'),
                            style: const TextStyle(
                              color: Constants.subtextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Başlık
                      Text(
                        content.title,
                        style: Constants.headingStyle,
                      ),
                      const SizedBox(height: 8),

                      // Yazar bilgisi
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: content.userPhotoUrl != null
                                ? NetworkImage(content.userPhotoUrl!)
                                : const NetworkImage(Constants.defaultAvatarUrl),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            content.userDisplayName ?? 'Anonim',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // İçerik metni
                      Text(
                        content.content,
                        style: Constants.bodyStyle,
                      ),
                      const SizedBox(height: 24),

                      // Diğer görseller
                      if (content.mediaUrls != null && content.mediaUrls!.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Görseller',
                              style: Constants.subheadingStyle,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: content.mediaUrls!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(Constants.smallRadius),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Tam ekran görsel gösterimi
                                          // TODO: Implement full-screen image view
                                        },
                                        child: Image.network(
                                          content.mediaUrls![index],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 120,
                                              height: 120,
                                              color: Constants.lightGrey,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Constants.darkGrey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Etkileşim butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Beğeni butonu
                          TextButton.icon(
                            onPressed: contentViewModel.isSubmitting ? null : _toggleLike,
                            icon: Icon(
                              contentViewModel.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: contentViewModel.isLiked
                                  ? Constants.primaryColor
                                  : Constants.subtextColor,
                            ),
                            label: Text(
                              '${content.likeCount}',
                              style: TextStyle(
                                color: contentViewModel.isLiked
                                    ? Constants.primaryColor
                                    : Constants.subtextColor,
                              ),
                            ),
                          ),

                          // Yorum butonu
                          TextButton.icon(
                            onPressed: () {
                              // Yorum bölümüne hızlıca kaydır
                              final commentBox = _commentController.value.text.isEmpty
                                  ? _commentController
                                  : null;
                              if (commentBox != null) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  );
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.comment_outlined,
                              color: Constants.subtextColor,
                            ),
                            label: Text(
                              '${content.commentCount}',
                              style: const TextStyle(
                                color: Constants.subtextColor,
                              ),
                            ),
                          ),

                          // Paylaş butonu
                          TextButton.icon(
                            onPressed: _shareContent,
                            icon: const Icon(
                              Icons.share_outlined,
                              color: Constants.subtextColor,
                            ),
                            label: const Text(
                              'Paylaş',
                              style: TextStyle(
                                color: Constants.subtextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Yorumlar başlığı
                      Text(
                        'Yorumlar (${content.commentCount})',
                        style: Constants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),

                      // Yorum yazma alanı
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthViewModel>(
                            builder: (context, authViewModel, _) {
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: authViewModel.user?.photoUrl != null
                                    ? NetworkImage(authViewModel.user!.photoUrl!)
                                    : const NetworkImage(Constants.defaultAvatarUrl),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Bir yorum yazın...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(Constants.defaultRadius),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: contentViewModel.isSubmitting ? null : _addComment,
                            icon: contentViewModel.isSubmitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.send),
                            color: Constants.primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Yorum listesi
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final comment = contentViewModel.comments[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.defaultPadding,
                        vertical: Constants.smallPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: comment['userPhotoUrl'] != null
                                    ? NetworkImage(comment['userPhotoUrl'])
                                    : const NetworkImage(Constants.defaultAvatarUrl),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment['userDisplayName'] ?? 'Kullanıcı',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(comment['createdAt'], locale: 'tr'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Constants.subtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment['text'] ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                        ],
                      ),
                    );
                  },
                  childCount: contentViewModel.comments.length,
                ),
              ),

              // İlgili içerikler
              if (contentViewModel.relatedContents.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(Constants.defaultPadding),
                        child: Text(
                          'Benzer İçerikler',
                          style: Constants.subheadingStyle,
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                          itemCount: contentViewModel.relatedContents.length,
                          itemBuilder: (context, index) {
                            final relatedContent = contentViewModel.relatedContents[index];

                            return GestureDetector(
                              onTap: () {
                                // Yeni içeriğe git
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentDetailScreen(
                                      contentId: relatedContent.id,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 16, bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Constants.defaultRadius),
                                ),
                                elevation: 2,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  padding: const EdgeInsets.all(Constants.smallPadding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Görsel
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Constants.smallRadius),
                                          child: relatedContent.thumbnailUrl != null
                                              ? Image.network(
                                            relatedContent.thumbnailUrl!,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Constants.lightGrey,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Constants.darkGrey,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                              : Container(
                                            color: Constants.lightGrey,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Constants.darkGrey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Başlık
                                      Text(
                                        relatedContent.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}