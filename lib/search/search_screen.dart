import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/content_model.dart';
import '../../utils/constants.dart';
import '../../viewmodels/search_viewmodel.dart';

import '../views/content/content_detail_screen.dart';
import '../views/shared/content_card.dart';
import '../views/shared/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ViewModel'i temizle
      Provider.of<SearchViewModel>(context, listen: false).clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      setState(() {
        _isSearching = true;
      });

      // ViewModel üzerinden arama yap
      Provider.of<SearchViewModel>(context, listen: false)
          .searchContents(query)
          .then((_) {
        setState(() {
          _isSearching = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ara', style: Constants.titleStyle),
        backgroundColor: Constants.bgColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ne arıyorsunuz?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<SearchViewModel>(context, listen: false).clearSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Constants.defaultRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0
                ),
              ),
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Arama sonuçları
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, searchViewModel, child) {
                if (_isSearching) {
                  return const Center(child: LoadingIndicator());
                }

                if (_searchController.text.isEmpty) {
                  return const Center(
                    child: Text(
                      'Arama yapmak için bir şeyler yazın',
                      style: Constants.bodyStyle,
                    ),
                  );
                }

                final searchResults = searchViewModel.searchResults;

                if (searchViewModel.errorMessage != null) {
                  return Center(
                    child: Text(
                      'Hata: ${searchViewModel.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Constants.subtextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sonuç bulunamadı',
                          style: Constants.subheadingStyle.copyWith(
                            color: Constants.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Başka anahtar kelimelerle aramayı deneyin',
                          style: Constants.captionStyle,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(Constants.smallPadding),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final content = searchResults[index];
                    return ContentCard(
                      content: content,
                      onTap: () {
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}