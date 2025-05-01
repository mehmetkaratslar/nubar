// Dosya: lib/views/home/category_screen.dart
// Amaç: Belirli bir kategoriye ait içerikleri gösterir.
// Bağlantı: app.dart üzerinden çağrılır, ContentViewModel ile entegre çalışır.
// Not: getContentsByCategory ve contents kullanıldı.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../shared/content_card.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Kategoriye göre içerikleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentViewModel>(context, listen: false)
          .getContentsByCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentViewModel = Provider.of<ContentViewModel>(context);

    return Container(
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
      child: Column(
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Text(
              l10n.categoryName(widget.category),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryRed,
              ),
            ),
          ),
          // İçerik Listesi
          Expanded(
            child: contentViewModel.isLoading
                ? Center(child: CircularProgressIndicator(color: AppConstants.primaryRed))
                : contentViewModel.errorMessage != null
                ? Center(child: Text(contentViewModel.errorMessage!))
                : contentViewModel.contents.isEmpty
                ? Center(child: Text(l10n.noContentsFoundLabel))
                : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: contentViewModel.contents.length,
              itemExtent: 300,
              cacheExtent: 1000,
              itemBuilder: (context, index) {
                final content = contentViewModel.contents[index];
                return ContentCard(content: content);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Kategori adını çevirmek için yardımcı metod
extension AppLocalizationsExtension on AppLocalizations {
  String categoryName(String category) {
    switch (category) {
      case 'history':
        return history;
      case 'language':
        return language;
      case 'art':
        return art;
      case 'music':
        return music;
      case 'traditions':
        return traditions;
      default:
        return category;
    }
  }
}