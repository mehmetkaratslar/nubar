<<<<<<< HEAD
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
=======
// lib/views/editor/content_editor_screen.dart

// İçerik düzenleme ekranı
// Editörün içerik oluşturması ve düzenlemesi için arayüz sağlar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';

// Models
import '../../models/content_model.dart';

// Services
import '../../services/firestore_service.dart'; // FirestoreService import edildi [cite: 9]

// Utils
import '../../utils/constants.dart';
import '../../utils/validators.dart';
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
import '../../utils/extensions.dart';

// Çoklu dil desteği
import '../../generated/l10n.dart';

<<<<<<< HEAD
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
=======
class ContentEditorScreen extends StatefulWidget {
  // İçerik ID'si (düzenleme için), yeni içerik için null
  final String? contentId;

  const ContentEditorScreen({
    Key? key,
    this.contentId,
  }) : super(key: key);

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  // Form anahtarı - Form doğrulama için
  final _formKey = GlobalKey<FormState>();

  // Aktif dil kodu
  String _activeLanguage = 'ku'; // Varsayılan olarak Kürtçe

  // Başlık controller'ları (dillere göre)
  final Map<String, TextEditingController> _titleControllers = {};

  // İçerik metni controller'ları (dillere göre)
  final Map<String, TextEditingController> _contentControllers = {};

  // Özet controller'ları (dillere göre)
  final Map<String, TextEditingController> _summaryControllers = {};

  // Etiket controller'ı
  final TextEditingController _tagController = TextEditingController();

  // Resim seçici
  final ImagePicker _imagePicker = ImagePicker();

  // İçerik düzenleme modu mu
  bool get _isEditMode => widget.contentId != null;

  // Mevcut içerik (düzenleme modunda)
  ContentModel? _existingContent;
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

  @override
  void initState() {
    super.initState();

<<<<<<< HEAD
    // İçerik detaylarını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
=======
    // Dil controller'larını oluştur
    for (final language in SupportedLanguages.languages.keys) {
      _titleControllers[language] = TextEditingController();
      _contentControllers[language] = TextEditingController();
      _summaryControllers[language] = TextEditingController();
    }

    // Mevcut içeriği yükle (düzenleme modunda)
    if (_isEditMode) {
      _loadExistingContent();
    }
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  }

  @override
  void dispose() {
<<<<<<< HEAD
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
=======
    // Controller'ları temizle
    for (final controller in _titleControllers.values) {
      controller.dispose();
    }
    for (final controller in _contentControllers.values) {
      controller.dispose();
    }
    for (final controller in _summaryControllers.values) {
      controller.dispose();
    }
    _tagController.dispose();
    super.dispose();
  }

  // Mevcut içeriği yükleme (düzenleme modu)
  Future<void> _loadExistingContent() async {
    try {
      // Context'e erişilemiyorsa erken çık
      if (!mounted) return;

      // Firestore servisini al
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

      // İçeriği Firestore'dan yükle
      final firestoreService = Provider.of<FirestoreService>(context, listen: false); // Hata düzeltildi [cite: 9]
      final content = await firestoreService.getContent(widget.contentId!);

      if (content != null) {
        // İçeriği depola
        setState(() {
          _existingContent = content;
        });

        // Form verilerini doldur
        editorViewModel.prepareContentForm(content);

        // Controller'lara değerleri aktar
        for (final language in content.title.keys) {
          _titleControllers[language]?.text = content.title[language] ?? '';
          _contentControllers[language]?.text = content.content[language] ?? '';
          _summaryControllers[language]?.text = content.summary[language] ?? '';
        }
      }
    } catch (e) {
      // Hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçerik yüklenirken hata oluştu: $e')),
        );
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      }
    }
  }

<<<<<<< HEAD
  // Yorumlara kaydır
  void _scrollToComments() {
    if (_scrollController.hasClients) {
      // Ekranın yarısına kadar kaydır
      final offset = _scrollController.position.maxScrollExtent / 2;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
=======
  // İçeriği kaydetme veya güncelleme
  Future<void> _saveContent() async {
    // Form doğrulama
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Zorunlu dil kontrolü
    if (_titleControllers['ku']!.text.isEmpty ||
        _contentControllers['ku']!.text.isEmpty ||
        _summaryControllers['ku']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kürtçe (Kurmancî) içerik zorunludur')),
      );
      return;
    }

    try {
      // ViewModels
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

      // Controller değerlerinden içerik verilerini oluştur
      final Map<String, String> title = {};
      final Map<String, String> content = {};
      final Map<String, String> summary = {};

      for (final language in _titleControllers.keys) {
        final titleText = _titleControllers[language]!.text.trim();
        final contentText = _contentControllers[language]!.text.trim();
        final summaryText = _summaryControllers[language]!.text.trim();

        // Boş olmayan içerikleri ekle
        if (titleText.isNotEmpty && contentText.isNotEmpty && summaryText.isNotEmpty) {
          title[language] = titleText;
          content[language] = contentText;
          summary[language] = summaryText;
        }
      }

      // Düzenleme veya oluşturma
      if (_isEditMode) {
        final success = await editorViewModel.updateContent(
          contentId: widget.contentId!,
          title: title,
          content: content,
          summary: summary,
          category: editorViewModel.contentCategory,
          contentType: editorViewModel.contentType,
          lastEditedBy: authViewModel.userId,
          newMediaFiles: editorViewModel.selectedMediaFiles,
          mediaUrlsToKeep: editorViewModel.mediaUrlsToKeep,
          newThumbnailFile: editorViewModel.selectedThumbnail,
          tags: editorViewModel.contentTags,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('İçerik başarıyla güncellendi')),
          );
          Navigator.pop(context);
        }
      } else {
        final contentId = await editorViewModel.createContent(
          title: title,
          content: content,
          summary: summary,
          category: editorViewModel.contentCategory,
          contentType: editorViewModel.contentType,
          createdBy: authViewModel.userId,
          mediaFiles: editorViewModel.selectedMediaFiles,
          thumbnailFile: editorViewModel.selectedThumbnail,
          tags: editorViewModel.contentTags,
        );

        if (!mounted) return;

        if (contentId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('İçerik başarıyla oluşturuldu')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik kaydedilirken hata oluştu: $e')),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      );
    }
  }

<<<<<<< HEAD
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
=======
  // İçeriği yayınlama
  Future<void> _publishContent() async {
    try {
      if (!_isEditMode) return;
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);
      final success = await editorViewModel.publishContent(widget.contentId!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçerik başarıyla yayınlandı')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik yayınlanırken hata oluştu: $e')),
      );
    }
  }

  // İçeriği taslak olarak işaretleme
  Future<void> _unpublishContent() async {
    try {
      if (!_isEditMode) return;
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);
      final success = await editorViewModel.unpublishContent(widget.contentId!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçerik taslak olarak işaretlendi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik durumu değiştirilirken hata oluştu: $e')),
      );
    }
  }

  // İçeriği arşivleme (silme)
  Future<void> _archiveContent() async {
    try {
      if (!_isEditMode) return;

      // Onay dialogu göster
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('İçeriği Arşivle'),
          content: const Text('Bu içeriği arşivlemek istediğinizden emin misiniz? Arşivlenen içerikler kullanıcılar tarafından görüntülenemez.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Arşivle'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirmed) return;

      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);
      final success = await editorViewModel.archiveContent(widget.contentId!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçerik arşivlendi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik arşivlenirken hata oluştu: $e')),
      );
    }
  }


  // Medya seçme
  Future<void> _pickMedia() async {
    final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context);
                final result = await _imagePicker.pickImage(source: ImageSource.gallery);
                if (result != null) {
                  editorViewModel.addMediaFile(File(result.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () async {
                Navigator.pop(context);
                final result = await _imagePicker.pickImage(source: ImageSource.camera);
                if (result != null) {
                  editorViewModel.addMediaFile(File(result.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Thumbnail seçme
  Future<void> _pickThumbnail() async {
    final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context);
                final result = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 450,
                  imageQuality: 85,
                );
                if (result != null) {
                  editorViewModel.setThumbnail(File(result.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () async {
                Navigator.pop(context);
                final result = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 450,
                  imageQuality: 85,
                );
                if (result != null) {
                  editorViewModel.setThumbnail(File(result.path));
                }
              },
            ),
            if (_existingContent?.thumbnailUrl != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Mevcut Görseli Kaldır'),
                onTap: () {
                  Navigator.pop(context);
                  editorViewModel.setThumbnail(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Etiket ekleme
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);
      editorViewModel.addTag(tag);
      _tagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? S.of(context).editContent : S.of(context).createContent),
        actions: [
          // İçeriği Kaydet
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveContent,
          ),
          // Düzenleme modunda ekstra seçenekler
          if (_isEditMode && _existingContent != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'publish':
                    await _publishContent();
                    break;
                  case 'unpublish':
                    await _unpublishContent();
                    break;
                  case 'archive':
                    await _archiveContent();
                    break;
                }
              },
              itemBuilder: (context) => [
                // İçerik durumuna bağlı seçenekler
                if (_existingContent?.status == ContentStatus.draft)
                  PopupMenuItem<String>(
                    value: 'publish',
                    child: Row(
                      children: [
                        Icon(Icons.publish, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(S.of(context).publish),
                      ],
                    ),
                  ),
                if (_existingContent?.status == ContentStatus.published)
                  PopupMenuItem<String>(
                    value: 'unpublish',
                    child: Row(
                      children: [
                        Icon(Icons.unpublished, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(S.of(context).unpublish),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: Theme.of(context).colorScheme.error), // Hata düzeltildi [cite: 12]
                      const SizedBox(width: 8),
                      Text(S.of(context).archived),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Consumer<EditorViewModel>(
        builder: (context, editorViewModel, child) {
          if (editorViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dil seçimi
                  _buildLanguageSelector(),
                  const SizedBox(height: 16),
                  // Başlık alanı
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  // Özet alanı
                  _buildSummaryField(),
                  const SizedBox(height: 16),
                  // İçerik alanı
                  _buildContentField(),
                  const SizedBox(height: 24),
                  // Kategori ve tür seçimi
                  _buildCategoryAndTypeSection(editorViewModel),
                  const SizedBox(height: 24),
                  // Etiketler
                  _buildTagsSection(editorViewModel),
                  const SizedBox(height: 24),
                  // Medya alanı
                  _buildMediaSection(editorViewModel),
                  const SizedBox(height: 24),
                  // Kapak görseli alanı
                  _buildThumbnailSection(editorViewModel),
                  const SizedBox(height: 32),
                  // Kaydet butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: editorViewModel.isSubmitting ? null : _saveContent,
                      icon: editorViewModel.isSubmitting
                          ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Icon(Icons.save),
                      label: Text(_isEditMode ? 'Güncelle' : 'Oluştur'),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                    ),
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
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
=======
          );
        },
      ),
    );
  }

  // Dil seçimi
  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İçerik Dili',
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Hata düzeltildi [cite: 13]
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SupportedLanguages.languages.entries.map((entry) {
              final isActive = _activeLanguage == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _activeLanguage = entry.key;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        if (_activeLanguage != 'ku')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Not: Kürtçe (Kurmancî) içerik zorunludur.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error, // Hata düzeltildi [cite: 10]
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // Başlık alanı
  Widget _buildTitleField() {
    final controller = _titleControllers[_activeLanguage]!;
    final isKurdish = _activeLanguage == 'ku';
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '${S.of(context).contentTitle} (${SupportedLanguages.languages[_activeLanguage]})',
        hintText: 'İçerik başlığını girin',
        border: const OutlineInputBorder(),
        suffixIcon: isKurdish ? const Icon(Icons.star, color: Colors.amber) : null,
      ),
      validator: isKurdish ? (value) => validateContentTitle(value) : null,
      maxLength: 100,
    );
  }

  // Özet alanı
  Widget _buildSummaryField() {
    final controller = _summaryControllers[_activeLanguage]!;
    final isKurdish = _activeLanguage == 'ku';
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '${S.of(context).contentSummary} (${SupportedLanguages.languages[_activeLanguage]})',
        hintText: 'İçerik özeti girin',
        border: const OutlineInputBorder(),
        suffixIcon: isKurdish ? const Icon(Icons.star, color: Colors.amber) : null,
      ),
      validator: isKurdish ? (value) => validateRequired(value) : null,
      maxLength: 200,
      maxLines: 3,
    );
  }

  // İçerik alanı
  Widget _buildContentField() {
    final controller = _contentControllers[_activeLanguage]!;
    final isKurdish = _activeLanguage == 'ku';
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '${S.of(context).contentText} (${SupportedLanguages.languages[_activeLanguage]})',
        hintText: 'İçerik metnini girin',
        border: const OutlineInputBorder(),
        suffixIcon: isKurdish ? const Icon(Icons.star, color: Colors.amber) : null,
      ),
      validator: isKurdish ? (value) => validateContentText(value) : null,
      maxLines: 10,
    );
  }

  // Kategori ve tür seçimi
  Widget _buildCategoryAndTypeSection(EditorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori ve İçerik Türü',
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Hata düzeltildi [cite: 14]
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Kategori seçimi
        Row(
          children: [
            const Text('Kategori: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<ContentCategory>(
                value: viewModel.contentCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ContentCategory.values.map((category) {
                  String label = '';
                  IconData icon = Icons.category;
                  switch (category) {
                    case ContentCategory.history:
                      label = S.of(context).history;
                      icon = Icons.history;
                      break;
                    case ContentCategory.language:
                      label = S.of(context).language;
                      icon = Icons.language;
                      break;
                    case ContentCategory.art:
                      label = S.of(context).art;
                      icon = Icons.palette;
                      break;
                    case ContentCategory.music:
                      label = S.of(context).music;
                      icon = Icons.music_note;
                      break;
                    case ContentCategory.traditions:
                      label = S.of(context).traditions;
                      icon = Icons.celebration;
                      break;
                  }
                  return DropdownMenuItem<ContentCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 8),
                        Text(label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setContentCategory(value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // İçerik türü seçimi
        Row(
          children: [
            const Text('İçerik Türü: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<ContentType>(
                value: viewModel.contentType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ContentType.values.map((type) {
                  String label = '';
                  IconData icon = Icons.article;
                  switch (type) {
                    case ContentType.text:
                      label = 'Metin';
                      icon = Icons.article;
                      break;
                    case ContentType.image:
                      label = 'Görsel';
                      icon = Icons.image;
                      break;
                    case ContentType.video:
                      label = 'Video';
                      icon = Icons.video_library;
                      break;
                    case ContentType.audio:
                      label = 'Ses';
                      icon = Icons.audiotrack;
                      break;
                  }
                  return DropdownMenuItem<ContentType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 8),
                        Text(label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setContentType(value);
                  }
                },
              ),
            ),
          ],
        ),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      ],
    );
  }

<<<<<<< HEAD
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
=======
  // Etiketler alanı
  Widget _buildTagsSection(EditorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiketler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Hata düzeltildi [cite: 15]
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Etiket ekleme alanı
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Yeni etiket girin',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addTag,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Etiket listesi
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.contentTags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => viewModel.removeTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Medya alanı
  Widget _buildMediaSection(EditorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medya Dosyaları',
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Hata düzeltildi [cite: 16]
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Medya ekleme butonu
        OutlinedButton.icon(
          onPressed: _pickMedia,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Medya Ekle'),
        ),
        const SizedBox(height: 12),
        // Seçili medya dosyaları
        if (viewModel.selectedMediaFiles.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: viewModel.selectedMediaFiles.length,
            itemBuilder: (context, index) {
              final file = viewModel.selectedMediaFiles[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    file,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => viewModel.removeMediaFile(index),
                    ),
                  ),
                ],
              );
            },
          ),
        // Mevcut medya URL'leri (düzenleme modunda)
        if (_isEditMode && viewModel.mediaUrlsToKeep.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Mevcut Medya Dosyaları',
                style: Theme.of(context).textTheme.titleSmall, // Hata düzeltildi [cite: 18]
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: viewModel.mediaUrlsToKeep.length,
                itemBuilder: (context, index) {
                  final url = viewModel.mediaUrlsToKeep[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon( // Hata düzeltildi [cite: 11]
                          Icons.error,
                          color: Theme.of(context).colorScheme.error, // Hata düzeltildi [cite: 11]
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => viewModel.removeMediaUrl(url),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  // Kapak görseli alanı
  Widget _buildThumbnailSection(EditorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kapak Görseli',
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Hata düzeltildi [cite: 17]
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Kapak görseli ekleme butonu
        OutlinedButton.icon(
          onPressed: _pickThumbnail,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Kapak Görseli Ekle'),
        ),
        const SizedBox(height: 12),
        // Seçili kapak görseli
        if (viewModel.selectedThumbnail != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    viewModel.selectedThumbnail!,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 24,
                    ),
                    onPressed: () => viewModel.setThumbnail(null),
                  ),
                ),
              ],
            ),
          )
        // Mevcut kapak görseli (düzenleme modunda)
        else if (_isEditMode && _existingContent?.thumbnailUrl != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _existingContent!.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 24,
                    ),
                    onPressed: () => viewModel.setThumbnail(null),
                  ),
                ),
              ],
            ),
          ),
      ],
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    );
  }
}