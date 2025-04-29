// lib/views/content/content_detail_screen.dart
// İçerik detay sayfası
// Seçilen içeriğin tüm detaylarını, medya içeriklerini ve yorumları gösterir

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/content_viewmodel.dart';

// Models
import '../../models/content_model.dart';
import '../../models/comment_model.dart';
import '../../models/report_model.dart';

// Utils
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

// Çoklu dil desteği
import '../../generated/l10n.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({
    Key? key,
    required this.contentId,
  }) : super(key: key);

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  // Yorum yazma kontrolü
  final TextEditingController _commentController = TextEditingController();

  // Seçilen dil (içerik gösterimi için)
  String _selectedLanguage = 'ku'; // Varsayılan dil: Kürtçe

  // Yorum gönderme yükleniyor durumu
  bool _isSendingComment = false;

  // Scrollable için controller (yorumlara kaydırma için)
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // İçerik detaylarını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // İçerik detaylarını yükle
  Future<void> _loadContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı oturum açmışsa, tercih ettiği dili kullan
    if (authViewModel.isLoggedIn && authViewModel.userModel != null) {
      setState(() {
        _selectedLanguage = authViewModel.userModel!.preferredLanguage;
      });
    }

    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    // İçerik detaylarını yükle
    await contentViewModel.loadContentDetails(widget.contentId);

    // İçerik yorumlarını yükle
    await contentViewModel.loadComments(widget.contentId);
  }

  // Dil değiştir
  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Kullanıcı tercihli dili güncelle (eğer giriş yapmışsa)
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.isLoggedIn) {
      authViewModel.updatePreferredLanguage(languageCode);
    }

    // Başarılı bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).languageChanged.replaceAll(
          '{language}',
          SupportedLanguages.languages[languageCode] ?? languageCode,
        )),
      ),
    );
  }

  // İçeriği beğen/beğenmeme
  Future<void> _toggleLike() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı giriş yapmamışsa, giriş sayfasına yönlendir
    if (!authViewModel.isLoggedIn) {
      // Giriş sayfasına yönlendir
      Navigator.pushNamed(context, '/login');
      return;
    }

    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    // İçeriği beğen/beğenmeme
    await contentViewModel.toggleLikeContent(
      authViewModel.userId,
      widget.contentId,
    );

    // AuthViewModel'deki beğeni listesini güncelle
    await authViewModel.toggleLikeContent(widget.contentId);
  }

  // İçeriği kaydet/kaldır
  Future<void> _toggleSave() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı giriş yapmamışsa, giriş sayfasına yönlendir
    if (!authViewModel.isLoggedIn) {
      // Giriş sayfasına yönlendir
      Navigator.pushNamed(context, '/login');
      return;
    }

    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

    // İçeriği kaydet/kaldır
    await contentViewModel.toggleSaveContent(
      authViewModel.userId,
      widget.contentId,
    );

    // AuthViewModel'deki kayıt listesini güncelle
    await authViewModel.toggleSaveContent(widget.contentId);

    // Bildirim göster
    final userModel = authViewModel.userModel;
    final isSaved = userModel?.savedContents.contains(widget.contentId) ?? false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? S.of(context).contentSaved
              : S.of(context).contentUnsaved,
        ),
      ),
    );
  }

  // İçeriği paylaş
  Future<void> _shareContent() async {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    final content = contentViewModel.selectedContent;

    if (content == null) return;

    // İçerik başlığını al
    final title = content.title[_selectedLanguage] ?? content.title.values.first;

    // Paylaşım metni oluştur
    final text = '${S.of(context).checkOutThisContent}: $title\n\nhttps://nubar.app/content/${content.id}';

    // İçeriği paylaş
    await Share.share(text);

    // Analytics'e bildir
    await contentViewModel.shareContent(content.id, 'share_button');
  }

  // İçeriği şikayet et
  Future<void> _reportContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı giriş yapmamışsa, giriş sayfasına yönlendir
    if (!authViewModel.isLoggedIn) {
      // Giriş sayfasına yönlendir
      Navigator.pushNamed(context, '/login');
      return;
    }

    // Şikayet nedeni seçme dialogu göster
    final reportType = await _showReportReasonDialog();
    if (reportType == null) return;

    // Şikayet açıklaması iste
    final description = await _showReportDescriptionDialog();
    if (description == null || description.isEmpty) return;

    // Şikayeti gönder
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    await contentViewModel.reportContent(
      contentId: widget.contentId,
      userId: authViewModel.userId,
      username: authViewModel.userModel?.username ?? '',
      type: reportType,
      description: description,
    );

    // Başarılı bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).thanksForReporting),
      ),
    );
  }

  // Yorum gönder
  Future<void> _sendComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı giriş yapmamışsa, giriş sayfasına yönlendir
    if (!authViewModel.isLoggedIn) {
      // Giriş sayfasına yönlendir
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      // Yorumu gönder
      await contentViewModel.addComment(
        contentId: widget.contentId,
        userId: authViewModel.userId,
        username: authViewModel.userModel?.username ?? '',
        userPhotoUrl: authViewModel.userModel?.photoUrl,
        text: comment,
      );

      // Yorum alanını temizle
      _commentController.clear();

      // Klavyeyi kapat
      context.hideKeyboard();

      // Yorumlara kaydır
      _scrollToComments();
    } catch (e) {
      // Hata durumunda bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).commentError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  // Yorumlara kaydır
  void _scrollToComments() {
    if (_scrollController.hasClients) {
      // Ekranın yarısına kadar kaydır
      final offset = _scrollController.position.maxScrollExtent / 2;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Şikayet nedeni seçme dialogu
  Future<ReportType?> _showReportReasonDialog() async {
    return showDialog<ReportType>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).reportReason),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReportReasonTile(
                  title: S.of(context).inappropriate,
                  reportType: ReportType.inappropriate,
                ),
                _buildReportReasonTile(
                  title: S.of(context).spam,
                  reportType: ReportType.spam,
                ),
                _buildReportReasonTile(
                  title: S.of(context).offensive,
                  reportType: ReportType.offensive,
                ),
                _buildReportReasonTile(
                  title: S.of(context).violence,
                  reportType: ReportType.violence,
                ),
                _buildReportReasonTile(
                  title: S.of(context).copyright,
                  reportType: ReportType.copyright,
                ),
                _buildReportReasonTile(
                  title: S.of(context).other,
                  reportType: ReportType.other,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  // Şikayet nedeni öğesi
  Widget _buildReportReasonTile({
    required String title,
    required ReportType reportType,
  }) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context, reportType);
      },
    );
  }

  // Şikayet açıklaması dialogu
  Future<String?> _showReportDescriptionDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).reportDescription),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: S.of(context).reportDescriptionHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(S.of(context).submit),
            ),
          ],
        );
      },
    );
  }

  // Dil seçimi dialogu
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).selectLanguage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: SupportedLanguages.languages.entries.map((entry) {
                final isSelected = entry.key == _selectedLanguage;

                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(entry.key);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentViewModel>(
      builder: (context, contentViewModel, child) {
        // İçerik yüklenirken
        if (contentViewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).loading),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // İçerik bulunamadı veya hata
        if (contentViewModel.selectedContent == null || contentViewModel.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).error),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contentViewModel.error ?? S.of(context).contentNotFound,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.medium),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).back),
                  ),
                ],
              ),
            ),
          );
        }

        // İçerik bulundu
        final content = contentViewModel.selectedContent!;

        // Şu anki kullanıcı
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        final userModel = authViewModel.userModel;

        // İçerik beğenilmiş mi
        final isLiked = userModel?.likedContents.contains(content.id) ?? false;

        // İçerik kaydedilmiş mi
        final isSaved = userModel?.savedContents.contains(content.id) ?? false;

        // İçerik başlığı ve metni için dil seçimi
        // Seçilen dilde içerik yoksa, mevcut ilk dili kullan
        final title = content.title[_selectedLanguage] ?? content.title.values.first;
        final contentText = content.content[_selectedLanguage] ?? content.content.values.first;

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).contentDetails),
            actions: [
              // Dil seçimi butonu
              if (content.title.length > 1)
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: _showLanguageSelector,
                ),
              // Daha fazla seçenek menüsü
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'save':
                      await _toggleSave();
                      break;
                    case 'share':
                      await _shareContent();
                      break;
                    case 'report':
                      await _reportContent();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isSaved ? AppColors.primary : null,
                        ),
                        const SizedBox(width: AppSizes.small),
                        Text(
                          isSaved
                              ? S.of(context).unsave
                              : S.of(context).save,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        const Icon(Icons.share),
                        const SizedBox(width: AppSizes.small),
                        Text(S.of(context).share),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        const Icon(Icons.flag),
                        const SizedBox(width: AppSizes.small),
                        Text(S.of(context).report),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadContent,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header bölümü: Kapak görseli, başlık, yazar bilgisi
                  _buildContentHeader(content, title),

                  // Ana içerik bölümü
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İçerik metni
                        Html(
                          data: contentText,
                          style: {
                            'body': Style(
                              fontSize: FontSize(16),
                              lineHeight: LineHeight(1.6),
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 16),
                            ),
                            'h1': Style(
                              fontSize: FontSize(24),
                              fontWeight: FontWeight.bold,
                            ),
                            'h2': Style(
                              fontSize: FontSize(22),
                              fontWeight: FontWeight.bold,
                            ),
                            'h3': Style(
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.bold,
                            ),
                            'h4': Style(
                              fontSize: FontSize(18),
                              fontWeight: FontWeight.bold,
                            ),
                            'a': Style(
                              color: AppColors.primary,
                              textDecoration: TextDecoration.underline,
                            ),
                          },
                        ),
                        const SizedBox(height: AppSizes.large),

                        // Etiketler
                        if (content.tags.isNotEmpty)
                          Wrap(
                            spacing: AppSizes.small,
                            runSpacing: AppSizes.small,
                            children: content.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: AppColors.backgroundLight,
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: AppSizes.large),

                        // Alt bilgiler: Görüntülenme, tarih, kategori
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${content.viewsCount} ${S.of(context).views}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: AppSizes.medium),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeago.format(content.publishedAt ?? content.createdAt),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.small),
                        Text(
                          '${S.of(context).category}: ${ContentCategories.categories[content.category.toString().split('.').last] ?? ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSizes.medium),

                        // Beğeni ve yorum butonları
                        Row(
                          children: [
                            // Beğeni butonu
                            ElevatedButton.icon(
                              onPressed: _toggleLike,
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.white : AppColors.primary,
                              ),
                              label: Text('${content.likesCount}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLiked ? AppColors.primary : Colors.white,
                                foregroundColor: isLiked ? Colors.white : AppColors.primary,
                                elevation: 0,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.medium),

                            // Yorum butonu
                            OutlinedButton.icon(
                              onPressed: _scrollToComments,
                              icon: const Icon(Icons.comment),
                              label: Text('${content.commentsCount}'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            const Spacer(),

                            // Paylaş butonu
                            IconButton(
                              onPressed: _shareContent,
                              icon: const Icon(Icons.share),
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Yorumlar bölümü
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Yorumlar başlığı
                        Text(
                          S.of(context).comments,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSizes.medium),

                        // Yorum yazma alanı
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                maxLines: 3,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: S.of(context).writeComment,
                                  filled: true,
                                  fillColor: AppColors.backgroundLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.medium,
                                    vertical: AppSizes.small,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.small),
                            // Gönder butonu
                            IconButton(
                              onPressed: _isSendingComment ? null : _sendComment,
                              icon: _isSendingComment
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.send),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.medium),

                        // Yorumlar listesi
                        _buildCommentsList(contentViewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // İçerik üst kısmı (kapak görseli, başlık)
  Widget _buildContentHeader(ContentModel content, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kapak görseli
        if (content.thumbnailUrl != null || content.mediaUrls.isNotEmpty)
          CachedNetworkImage(
            imageUrl: content.thumbnailUrl ?? content.mediaUrls.first,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: 200,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.backgroundLight,
              width: double.infinity,
              height: 200,
              child: const Icon(
                Icons.broken_image,
                size: 48,
                color: AppColors.textLight,
              ),
            ),
          ),

        // Başlık ve alt bilgiler
        Padding(
          padding: const EdgeInsets.all(AppSizes.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.small),

              // Oluşturan kullanıcı ve tarih
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    S.of(context).createdBy.replaceAll(
                      '{username}',
                      'Editor', // Gerçek uygulamada editor adını getir
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.extraSmall),

              // Yayınlanma tarihi
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    S.of(context).publishedOn.replaceAll(
                      '{date}',
                      content.publishedAt != null
                          ? content.publishedAt!.toFullDate()
                          : content.createdAt.toFullDate(),
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Yorumlar listesi
  Widget _buildCommentsList(ContentViewModel contentViewModel) {
    if (contentViewModel.isLoadingComments) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (contentViewModel.comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.large),
          child: Text(S.of(context).noComments),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentViewModel.comments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final comment = contentViewModel.comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  // Yorum öğesi
  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı avatarı
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.backgroundLight,
            backgroundImage: comment.userPhotoUrl != null
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null
                ? Text(
              comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
                : null,
          ),
          const SizedBox(width: AppSizes.medium),

          // Yorum içeriği
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı adı ve tarih
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSizes.small),
                    Text(
                      timeago.format(comment.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.extraSmall),

                // Yorum metni
                Text(comment.text),
                const SizedBox(height: AppSizes.small),

                // Beğeni ve yanıt butonları
                Row(
                  children: [
                    // Beğeni butonu
                    GestureDetector(
                      onTap: () {
                        // Yorum beğenme işlevselliği
                        final authViewModel = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );

                        if (!authViewModel.isLoggedIn) {
                          Navigator.pushNamed(context, '/login');
                          return;
                        }

                        final contentViewModel = Provider.of<ContentViewModel>(
                          context,
                          listen: false,
                        );

                        contentViewModel.toggleLikeComment(
                          authViewModel.userId,
                          comment.id,
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.thumb_up,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likesCount.toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.medium),

                    // Yanıtla butonu
                    GestureDetector(
                      onTap: () {
                        // Yoruma yanıt verme işlevselliği
                        // (İleri aşamalarda eklenebilir)
                      },
                      child: const Text(
                        'Yanıtla',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Şikayet butonu
                    GestureDetector(
                      onTap: () async {
                        // Yorum şikayet etme işlevselliği
                        final authViewModel = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );

                        if (!authViewModel.isLoggedIn) {
                          Navigator.pushNamed(context, '/login');
                          return;
                        }

                        // Şikayet nedeni seçme dialogu göster
                        final reportType = await _showReportReasonDialog();
                        if (reportType == null) return;

                        // Şikayet açıklaması iste
                        final description = await _showReportDescriptionDialog();
                        if (description == null || description.isEmpty) return;

                        // Şikayeti gönder
                        final contentViewModel = Provider.of<ContentViewModel>(
                          context,
                          listen: false,
                        );

                        await contentViewModel.reportComment(
                          commentId: comment.id,
                          userId: authViewModel.userId,
                          username: authViewModel.userModel?.username ?? '',
                          type: reportType,
                          description: description,
                        );

                        // Başarılı bildirim göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).thanksForReporting),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.flag,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Yanıtlar (sonraki aşamalarda eklenebilir)
                if (comment.repliesCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.small),
                    child: GestureDetector(
                      onTap: () {
                        // Yanıtları göster
                        // (İleri aşamalarda eklenebilir)
                      },
                      child: Text(
                        '${comment.repliesCount} ${S.of(context).replies}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}