import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/content_model.dart';
import '../../utils/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../shared/loading_indicator.dart';

class ContentEditorScreen extends StatefulWidget {
  final String? contentId; // Düzenleme durumunda içerik ID'si

  const ContentEditorScreen({
    Key? key,
    this.contentId,
  }) : super(key: key);

  @override
  _ContentEditorScreenState createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = Constants.historyCategory;
  String _selectedLanguage = Constants.languageTurkish;

  List<File> _selectedImages = [];
  List<String> _existingMediaUrls = [];
  List<String> _mediaUrlsToRemove = [];
  String? _thumbnailUrl;

  bool _isPublished = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.contentId != null) {
      // Mevcut içeriği yükle
      _loadExistingContent();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      // İçeriği getir
      final content = await contentViewModel.getContentById(widget.contentId!);

      if (content != null) {
        // Form alanlarını doldur
        _titleController.text = content.title;
        _contentController.text = content.content;
        _selectedCategory = content.category;
        _selectedLanguage = content.language;
        _isPublished = content.isPublished;

        // Medya URL'lerini al
        if (content.mediaUrls != null) {
          _existingMediaUrls = List<String>.from(content.mediaUrls!);
        }

        // Thumbnail
        _thumbnailUrl = content.thumbnailUrl;
      }

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      print('İçerik yüklenirken hata oluştu: ${e.toString()}');

      // Kullanıcıya hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İçerik yüklenirken hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();

    try {
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1200,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final pickedFile in pickedFiles) {
            _selectedImages.add(File(pickedFile.path));
          }
        });
      }
    } catch (e) {
      print('Resim seçilirken hata oluştu: ${e.toString()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim seçilirken hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      String urlToRemove = _existingMediaUrls[index];
      _mediaUrlsToRemove.add(urlToRemove);
      _existingMediaUrls.removeAt(index);

      // Thumbnail olarak kullanılan görsel kaldırıldıysa, thumbnail'i güncelle
      if (_thumbnailUrl == urlToRemove) {
        _thumbnailUrl = _existingMediaUrls.isNotEmpty ? _existingMediaUrls.first : null;
      }
    });
  }

  void _setAsThumbnail(String url) {
    setState(() {
      _thumbnailUrl = url;
    });
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      if (widget.contentId == null) {
        // Yeni içerik oluştur
        final contentId = await contentViewModel.createContent(
          title: _titleController.text,
          content: _contentController.text,
          userId: authViewModel.user!.id,
          userDisplayName: authViewModel.user!.displayName,
          userPhotoUrl: authViewModel.user!.photoUrl,
          category: _selectedCategory,
          language: _selectedLanguage,
          mediaFiles: _selectedImages,
        );

        if (contentId != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İçerik başarıyla oluşturuldu'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop(true); // Başarı ile tamamlandığını bildir
        }
      } else {
        // Mevcut içeriği güncelle
        final success = await contentViewModel.updateContent(
          contentId: widget.contentId!,
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          language: _selectedLanguage,
          newMediaFiles: _selectedImages,
          removeMediaUrls: _mediaUrlsToRemove,
          thumbnailUrl: _thumbnailUrl,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İçerik başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop(true); // Başarı ile tamamlandığını bildir
        }
      }
    } catch (e) {
      print('İçerik kaydedilirken hata oluştu: ${e.toString()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İçerik kaydedilirken hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        title: Text(widget.contentId == null ? 'Yeni İçerik' : 'İçerik Düzenle'),
        backgroundColor: Constants.primaryColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveContent,
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : !_isInitialized
          ? const Center(child: Text('İçerik yüklenemedi'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'İçerik başlığını girin',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori seçimi
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: Constants.historyCategory,
                    child: Row(
                      children: [
                        Icon(Constants.historyIcon, color: Constants.historyColor),
                        const SizedBox(width: 8),
                        Text(Constants.historyCategory),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Constants.languageCategory,
                    child: Row(
                      children: [
                        Icon(Constants.languageIcon, color: Constants.languageColor),
                        const SizedBox(width: 8),
                        Text(Constants.languageCategory),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Constants.artCategory,
                    child: Row(
                      children: [
                        Icon(Constants.artIcon, color: Constants.artColor),
                        const SizedBox(width: 8),
                        Text(Constants.artCategory),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Constants.musicCategory,
                    child: Row(
                      children: [
                        Icon(Constants.musicIcon, color: Constants.musicColor),
                        const SizedBox(width: 8),
                        Text(Constants.musicCategory),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Constants.traditionCategory,
                    child: Row(
                      children: [
                        Icon(Constants.traditionIcon, color: Constants.traditionColor),
                        const SizedBox(width: 8),
                        Text(Constants.traditionCategory),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Dil seçimi
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Dil',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Constants.languageTurkish,
                    child: Text('Türkçe'),
                  ),
                  DropdownMenuItem(
                    value: Constants.languageKurdishKur,
                    child: Text('Kürtçe (Kurmanci)'),
                  ),
                  DropdownMenuItem(
                    value: Constants.languageKurdishSor,
                    child: Text('Kürtçe (Sorani)'),
                  ),
                  DropdownMenuItem(
                    value: Constants.languageEnglish,
                    child: Text('İngilizce'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // İçerik
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                  hintText: 'İçerik metnini girin',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen içerik metnini girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Medya ekleme
              Row(
                children: [
                  const Text(
                    'Görseller',
                    style: Constants.subheadingStyle,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Görsel Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Mevcut görseller
              if (_existingMediaUrls.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mevcut Görseller',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
                      itemCount: _existingMediaUrls.length,
                      itemBuilder: (context, index) {
                        final url = _existingMediaUrls[index];
                        final isThumbnail = url == _thumbnailUrl;

                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isThumbnail
                                      ? Constants.primaryColor
                                      : Colors.grey,
                                  width: isThumbnail ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(Constants.smallRadius),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Constants.smallRadius),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
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
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (!isThumbnail)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: GestureDetector(
                                  onTap: () => _setAsThumbnail(url),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Constants.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Yeni seçilen görseller
              if (_selectedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni Seçilen Görseller',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(Constants.smallRadius),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Constants.smallRadius),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeSelectedImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

              if (_existingMediaUrls.isEmpty && _selectedImages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Constants.lightGrey,
                    borderRadius: BorderRadius.circular(Constants.defaultRadius),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.image,
                        size: 48,
                        color: Constants.subtextColor,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Henüz görsel eklenmedi',
                        style: Constants.bodyStyle,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Görsel Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // İçerik yayınlanma durumu
              if (widget.contentId != null)
                SwitchListTile(
                  title: const Text('İçeriği Yayınla'),
                  subtitle: const Text('Kapalı: Taslak olarak kaydet, Açık: Yayınla'),
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() {
                      _isPublished = value;
                    });
                  },
                  activeColor: Constants.primaryColor,
                ),

              const SizedBox(height: 24),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.defaultRadius),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    widget.contentId == null ? 'İçerik Oluştur' : 'İçeriği Güncelle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}