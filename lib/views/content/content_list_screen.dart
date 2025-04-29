import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/content_model.dart';
import '../../utils/constants.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../shared/content_card.dart';
import '../shared/loading_indicator.dart';
import 'content_detail_screen.dart';

class ContentListScreen extends StatefulWidget {
  final String category;
  final String? language;

  const ContentListScreen({
    Key? key,
    required this.category,
    this.language,
  }) : super(key: key);

  @override
  _ContentListScreenState createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ContentModel> _contents = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreContent = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadContents();

    // Kaydırma olayını dinle (sonsuz kaydırma)
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreContent) {
        _loadMoreContents();
      }
    }
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      List<ContentModel> contents = await contentViewModel.getContentsByCategory(
        widget.category,
        language: widget.language,
        limit: 10,
      );

      setState(() {
        _contents = contents;
        _hasMoreContent = contents.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'İçerikler yüklenirken hata oluştu: ${e.toString()}';
        _isLoading = false;
      });
      print(_errorMessage);
    }
  }

  Future<void> _loadMoreContents() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      final lastContent = _contents.isNotEmpty ? _contents.last : null;
      final lastCreatedAt = lastContent?.createdAt;

      // Firestore'da cursor pagination yapabilmek için son içeriğin tarihinden daha eski içerikleri al
      List<ContentModel> moreContents = await contentViewModel.getContentsByCategory(
        widget.category,
        language: widget.language,
        limit: 10,
        // Gerçek bir uygulamada burada cursor pagination kullanılmalı
      );

      setState(() {
        _contents.addAll(moreContents);
        _hasMoreContent = moreContents.length >= 10;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Daha fazla içerik yüklenirken hata oluştu: ${e.toString()}';
        _isLoadingMore = false;
      });
      print(_errorMessage);
    }
  }

  // İçerikleri yenile (pull-to-refresh)
  Future<void> _refreshContents() async {
    await _loadContents();
  }

  @override
  Widget build(BuildContext context) {
    // Kategori rengini belirleme
    Color categoryColor;
    IconData categoryIcon;

    switch (widget.category) {
      case Constants.historyCategory:
        categoryColor = Constants.historyColor;
        categoryIcon = Constants.historyIcon;
        break;
      case Constants.languageCategory:
        categoryColor = Constants.languageColor;
        categoryIcon = Constants.languageIcon;
        break;
      case Constants.artCategory:
        categoryColor = Constants.artColor;
        categoryIcon = Constants.artIcon;
        break;
      case Constants.musicCategory:
        categoryColor = Constants.musicColor;
        categoryIcon = Constants.musicIcon;
        break;
      case Constants.traditionCategory:
        categoryColor = Constants.traditionColor;
        categoryIcon = Constants.traditionIcon;
        break;
      default:
        categoryColor = Constants.primaryColor;
        categoryIcon = Icons.article;
    }

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(categoryIcon),
            const SizedBox(width: 8),
            Text(widget.category),
          ],
        ),
        backgroundColor: categoryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
          ? Center(
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
              _errorMessage!,
              style: Constants.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadContents,
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      )
          : _contents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryIcon,
              size: 64,
              color: categoryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kategoride henüz içerik bulunmuyor',
              style: Constants.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Daha sonra tekrar kontrol edin',
              style: Constants.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshContents,
        color: categoryColor,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(Constants.defaultPadding),
          itemCount: _contents.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _contents.length) {
              // Son öğe - yükleniyor göstergesi
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final content = _contents[index];

            return ContentCard(
              content: content,
              onTap: () {
                // İçerik detay sayfasına git
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentDetailScreen(
                      contentId: content.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}