// Dosya: lib/views/home/category_screen.dart
// Amaç: Kategorileri listeleyen ekran, kullanıcıların içerik kategorilerine göz atmasını sağlar.
// Bağlantı: home_screen.dart’tan çağrılır, content_detail_screen.dart’a yönlendirme yapabilir.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../models/content_model.dart';
import '../../utils/app_constants.dart';
import '../content/content_detail_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
      contentViewModel.getContentsByCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentViewModel = Provider.of<ContentViewModel>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: AppConstants.primaryRed,
      ),
      body: contentViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: contentViewModel.contents.length,
        itemBuilder: (context, index) {
          final content = contentViewModel.contents[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
            child: ListTile(
              leading: Icon(AppConstants.categoryIcons[content.category] ?? Icons.category),
              title: Text(
                content.title,
                style: const TextStyle(fontSize: AppConstants.textLarge),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/content_detail',
                  arguments: content.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}