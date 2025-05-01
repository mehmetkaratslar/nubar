// Dosya: lib/views/editor/content_editor_screen.dart
// Amaç: İçerik oluşturma ve düzenleme ekranını gösterir.
// Bağlantı: app.dart üzerinden çağrılır, FirestoreService ile entegre çalışır.
// Not: Tasarım iyileştirildi, başlık ve özet alanları eklendi.

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../l10n/generated/app_localizations.dart';
import '../../utils/app_constants.dart';

class ContentEditorScreen extends StatefulWidget {
  const ContentEditorScreen({Key? key}) : super(key: key);

  @override
  _ContentEditorScreenState createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  late quill.QuillController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = true;

  final List<String> _categories = [
    'Tarih',
    'Dil',
    'Sanat',
    'Müzik',
    'Gelenekler',
  ];

  @override
  void initState() {
    super.initState();
    // Quill editörünü asenkron olarak başlat
    _initializeEditor();
  }

  Future<void> _initializeEditor() async {
    _controller = quill.QuillController.basic();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    l10n.createContent,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryRed,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // İçerik Başlığı
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.contentTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // İçerik Özeti
                  TextField(
                    controller: _summaryController,
                    decoration: InputDecoration(
                      labelText: l10n.contentSummary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Kategori Seçimi
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l10n.contentCategory,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Quill Editör Toolbar
                  quill.QuillToolbar.simple(
                    configurations: quill.QuillSimpleToolbarConfigurations(
                      controller: _controller,
                      multiRowsDisplay: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quill Editör
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: quill.QuillEditor(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _controller,
                        scrollable: true,
                        padding: const EdgeInsets.all(8),
                        autoFocus: false,
                        expands: true,
                      ),
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kaydet ve Yayınla Butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Taslak olarak kaydetme işlemi
                          // FirestoreService ile entegre edilebilir
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.savedAsDraft,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Yayınlama işlemi
                          // FirestoreService ile entegre edilebilir
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.publish,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}