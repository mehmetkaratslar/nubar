// Dosya: lib/views/content/content_list_screen.dart
// Amaç: Belirli bir kategoriye ait içerikleri listeler.
// Bağlantı: category_screen.dart’tan yönlendirilir, content_detail_screen.dart’a gider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../models/content_model.dart';
import '../content/content_detail_screen.dart';

class ContentListScreen extends StatefulWidget {
  final String category;

  const ContentListScreen({Key? key, required this.category}) : super(key: key);

  @override
  _ContentListScreenState createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
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
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: contentViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contentViewModel.contents.length,
        itemBuilder: (context, index) {
          final content = contentViewModel.contents[index];
          return ListTile(
            title: Text(content.title),
            subtitle: Text('Oluşturulma: ${content.createdAt?.toString() ?? 'Bilinmiyor'}'),
            onTap: () {
              contentViewModel.getContentsByCategory(widget.category);
              Navigator.pushNamed(
                context,
                '/content_detail',
                arguments: content.id,
              );
            },
          );
        },
      ),
    );
  }
}