// Dosya: lib/views/search/search_screen.dart
// Amaç: İçerik arama ekranı.
// Bağlantı: home_screen.dart’tan arama ikonuna tıklanınca çağrılır.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../models/content_model.dart';
import '../utils/app_constants.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ara...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _currentQuery = '';
                });
                searchViewModel.searchContents('');
              },
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              _currentQuery = value.trim();
            });
            if (_currentQuery.isNotEmpty) {
              searchViewModel.searchContents(_currentQuery);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _currentQuery = _searchController.text.trim();
              });
              if (_currentQuery.isNotEmpty) {
                searchViewModel.searchContents(_currentQuery);
              }
            },
          ),
        ],
      ),
      body: _buildSearchResults(searchViewModel),
    );
  }

  Widget _buildSearchResults(SearchViewModel searchViewModel) {
    if (_currentQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'İçerik aramak için yukarıdaki arama kutusunu kullanın',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchViewModel.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '"$_currentQuery" aramasına uygun sonuç bulunamadı',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı anahtar kelimelerle tekrar deneyin',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchViewModel.searchResults.length,
      itemBuilder: (context, index) {
        final content = searchViewModel.searchResults[index];
        return _buildSearchResultItem(content);
      },
    );
  }

  Widget _buildSearchResultItem(ContentModel content) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/content_detail',
          arguments: content.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: content.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: content.imageUrl!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              )
                  : Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        content.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.darkGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}