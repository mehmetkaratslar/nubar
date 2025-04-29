// lib/views/home/home_screen.dart
// Ana sayfa ekranı
// Kullanıcıya içerik kategorilerini, öne çıkan ve son eklenen içerikleri gösterir

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/content_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';

// Models
import '../../models/content_model.dart';

// Utils
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

// Çoklu dil desteği
import '../../generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Arama kontrolü
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  // Seçilen dil
  String _selectedLanguage = 'ku'; // Varsayılan dil: Kürtçe

  @override
  void initState() {
    super.initState();

    // İçerikleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialContent();
    });

    // Arama değişikliklerini dinle
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Kullanıcı dil tercihine göre başlangıç içeriğini yükle
  Future<void> _loadInitialContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı oturum açmışsa, tercih ettiği dili kullan
    if (authViewModel.isLoggedIn && authViewModel.userModel != null) {
      setState(() {
        _selectedLanguage = authViewModel.userModel!.preferredLanguage;
      });
    }

    // İçerikleri yükle
    await _loadContent();
  }

  // İçerikleri yükle
  Future<void> _loadContent() async {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    await contentViewModel.loadContents(
      language: _selectedLanguage,
      refresh: true,
    );
  }

  // Kategori değiştiğinde içerikleri filtrele
  Future<void> _onCategorySelected(ContentCategory? category) async {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    await contentViewModel.loadContents(
      category: category,
      language: _selectedLanguage,
      refresh: true,
    );
  }

  // Dil değiştiğinde içerikleri yeniden yükle
  Future<void> _onLanguageChanged(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Kullanıcı tercihli dili güncelle (eğer giriş yapmışsa)
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.isLoggedIn) {
      await authViewModel.updatePreferredLanguage(languageCode);
    }

    // İçerikleri yeniden yükle
    await _loadContent();

    // Başarılı bildirim göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).languageChanged.replaceAll(
            '{language}',
            SupportedLanguages.languages[languageCode] ?? languageCode,
          )),
        ),
      );
    }
  }

  // Arama metni değiştiğinde
  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });

    // Arama gecikmesi (kullanıcı yazarken sürekli sorgu göndermemek için)
    // Burada gecikme ekleyebilirsiniz: debounce tekniği
  }

  // Aramayı gerçekleştir
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Klavyeyi kapat
    context.hideKeyboard();

    // Aramayı yap
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    await contentViewModel.searchContents(query, _selectedLanguage);
  }

  // Aramayı temizle
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });

    // İçerikleri yeniden yükle
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appName),
        actions: [
          // Dil seçimi butonu
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context),
          ),
          // Profil butonu
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadContent,
        child: Column(
          children: [
            // Arama alanı
            Padding(
              padding: const EdgeInsets.all(AppSizes.medium),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: S.of(context).search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.medium),
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),

            // Kategori listesi
            _buildCategoryList(),

            // İçerikler
            Expanded(
              child: _buildContentList(),
            ),
          ],
        ),
      ),
      // Editör butonu (editör yetkisi varsa)
      floatingActionButton: _buildEditorFab(),
    );
  }

  // Kategori listesi widget'ı
  Widget _buildCategoryList() {
    return Consumer<ContentViewModel>(
      builder: (context, contentViewModel, child) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: AppSizes.medium),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.medium),
            children: [
              // Tüm kategoriler
              _buildCategoryItem(
                context,
                icon: Icons.grid_view,
                title: S.of(context).all,
                isSelected: contentViewModel.selectedCategory == null,
                onTap: () => _onCategorySelected(null),
              ),

              // Diğer kategoriler
              ...ContentCategory.values.map((category) {
                IconData icon;
                String title;

                switch (category) {
                  case ContentCategory.history:
                    icon = Icons.history;
                    title = S.of(context).history;
                    break;
                  case ContentCategory.language:
                    icon = Icons.language;
                    title = S.of(context).language;
                    break;
                  case ContentCategory.art:
                    icon = Icons.palette;
                    title = S.of(context).art;
                    break;
                  case ContentCategory.music:
                    icon = Icons.music_note;
                    title = S.of(context).music;
                    break;
                  case ContentCategory.traditions:
                    icon = Icons.celebration;
                    title = S.of(context).traditions;
                    break;
                }

                return _buildCategoryItem(
                  context,
                  icon: icon,
                  title: title,
                  isSelected: contentViewModel.selectedCategory == category,
                  onTap: () => _onCategorySelected(category),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Kategori öğesi widget'ı
  Widget _buildCategoryItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: AppSizes.medium),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.medium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 32,
            ),
            const SizedBox(height: AppSizes.small),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // İçerik listesi widget'ı
  Widget _buildContentList() {
    return Consumer<ContentViewModel>(
      builder: (context, contentViewModel, child) {
        if (contentViewModel.isLoading) {
          return _buildLoadingShimmer();
        }

        if (contentViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  contentViewModel.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.medium),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: Text(S.of(context).retry),
                ),
              ],
            ),
          );
        }

        if (contentViewModel.contents.isEmpty) {
          return Center(
            child: Text(
              _isSearching
                  ? S.of(context).noSearchResults
                  : S.of(context).noContents,
              textAlign: TextAlign.center,
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!contentViewModel.isLoadingMore &&
                contentViewModel.hasMoreContents &&
                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              // Scroll en aşağıya geldiğinde daha fazla içerik yükle
              contentViewModel.loadContents(
                category: contentViewModel.selectedCategory,
                language: _selectedLanguage,
              );
            }
            return true;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.medium),
            itemCount: contentViewModel.contents.length +
                (contentViewModel.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= contentViewModel.contents.length) {
                // Daha fazla yükleniyor göstergesi
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.medium),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final content = contentViewModel.contents[index];
              return _buildContentItem(content);
            },
          ),
        );
      },
    );
  }

  // İçerik öğesi widget'ı
  Widget _buildContentItem(ContentModel content) {
    // İçerik başlığını, seçilen dilde veya mevcut ilk dilde göster
    final title = content.title[_selectedLanguage] ??
        content.title.values.first;

    // İçerik özetini, seçilen dilde veya mevcut ilk dilde göster
    final summary = content.summary[_selectedLanguage] ??
        content.summary.values.first;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.medium),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          // İçerik detay sayfasına yönlendir
          Navigator.pushNamed(
            context,
            '/content',
            arguments: {'contentId': content.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail veya ilk medya
            if (content.thumbnailUrl != null || content.mediaUrls.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: content.thumbnailUrl ?? content.mediaUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundLight,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),

            // İçerik metni
            Padding(
              padding: const EdgeInsets.all(AppSizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.small),

                  // Özet
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.medium),

                  // Alt bilgiler (beğeni, yorum, görüntüleme sayısı)
                  Row(
                    children: [
                      // Kategori etiketi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ContentCategories.categories[
                          content.category.toString().split('.').last
                          ] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Beğeni sayısı
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            content.likesCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSizes.medium),

                      // Yorum sayısı
                      Row(
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            content.commentsCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSizes.medium),

                      // Görüntülenme sayısı
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            content.viewsCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yükleniyor animasyonu
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.medium),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görsel alanı
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
                ),
              ),
              const SizedBox(height: AppSizes.medium),

              // Başlık alanı
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: AppSizes.small),

              // İçerik alanı
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: 200,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: AppSizes.medium),

              // Alt bilgiler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Editör FAB (Editör rolü varsa)
  Widget? _buildEditorFab() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı editör rolüne sahipse, içerik ekleme butonu göster
    if (authViewModel.isLoggedIn && authViewModel.userRole == UserRole.editor) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/editor/content');
        },
        icon: const Icon(Icons.add),
        label: Text(S.of(context).createContent),
        backgroundColor: AppColors.primary,
      );
    }

    return null;
  }

  // Dil seçimi dialogu
  void _showLanguageSelector(BuildContext context) {
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
                    _onLanguageChanged(entry.key);
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
}