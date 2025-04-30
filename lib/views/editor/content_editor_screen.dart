// Dosya: lib/views/editor/content_editor_screen.dart
// Amaç: Editörlerin içerik eklediği veya düzenlediği ekran.
// Bağlantı: editor_dashboard.dart’tan çağrılır.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../models/content_model.dart';
import '../../utils/app_constants.dart';

class ContentEditorScreen extends StatefulWidget {
  final String? contentId;

  const ContentEditorScreen({Key? key, this.contentId}) : super(key: key);

  @override
  _ContentEditorScreenState createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppConstants.categories[1];
  String _selectedLanguage = 'tr';
  File? _selectedImage;
  bool _isFeatured = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.contentId != null) {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    final content = await contentViewModel.getContentById(widget.contentId!);
    if (content != null) {
      setState(() {
        _titleController.text = content.title;
        _descriptionController.text = content.description;
        _selectedCategory = content.category;
        _selectedLanguage = content.language;
        _isFeatured = content.isFeatured;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Resim seçilirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resim seçilirken bir hata oluştu.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

      if (authViewModel.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oturum açmanız gerekiyor.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      bool success;
      if (widget.contentId == null) {
        success = await editorViewModel.createDraft(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          language: _selectedLanguage,
          imageFile: _selectedImage,
          userId: authViewModel.user!.uid,
          authorName: authViewModel.userData?['displayName'] ?? 'Kullanıcı',
        );
      } else {
        success = await editorViewModel.updateDraft(
          draftId: widget.contentId!,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          language: _selectedLanguage,
          imageFile: _selectedImage,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Taslak kaydedildi')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Taslak kaydedilirken hata oluştu')),
        );
      }
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentId == null ? 'İçerik Ekle' : 'İçerik Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSubmitting ? null : _saveContent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                      : const Center(child: Text('Resim Seç')),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açıklama girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.categories
                    .where((category) => category != 'Tümü')
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: 'Dil',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'ku', child: Text('Kürtçe')),
                  DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                  DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Öne Çıkan İçerik'),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveContent,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}