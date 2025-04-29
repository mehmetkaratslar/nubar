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
<<<<<<< HEAD
=======
import '../../models/user_model.dart';

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

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
<<<<<<< HEAD

    // İçerikleri yükle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialContent();
    });

<<<<<<< HEAD
    // Arama değişikliklerini dinle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Kullanıcı dil tercihine göre başlangıç içeriğini yükle
  Future<void> _loadInitialContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı oturum açmışsa, tercih ettiği dili kullan
=======
  // Kullanıcı dil tercihine göre başlangıç içeriklerini yükle
  Future<void> _loadInitialContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    if (authViewModel.isLoggedIn && authViewModel.userModel != null) {
      setState(() {
        _selectedLanguage = authViewModel.userModel!.preferredLanguage;
      });
    }

<<<<<<< HEAD
    // İçerikleri yükle
    await _loadContent();
  }

  // İçerikleri yükle
=======
    await _loadContent();
  }

  // İçerik verilerini yükler
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
    // Kullanıcı tercihli dili güncelle (eğer giriş yapmışsa)
=======
    // Kullanıcının dil tercih bilgisi Firebase'e gönderilir
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.isLoggedIn) {
      await authViewModel.updatePreferredLanguage(languageCode);
    }

<<<<<<< HEAD
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
=======
    // İçerikler güncellenir
    await _loadContent();

    // Başarı bildirim mesajı gösterilir
    if (!mounted) return;

    // 🛠️ replaceAll hatasını düzelttik: dil metninde {language} yerine değer geçiyoruz
    final languageName = SupportedLanguages.languages[languageCode] ?? languageCode;
    final message = S.of(context).languageChanged(languageName);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Arama kutusu değişince
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
<<<<<<< HEAD

    // Arama gecikmesi (kullanıcı yazarken sürekli sorgu göndermemek için)
    // Burada gecikme ekleyebilirsiniz: debounce tekniği
  }

  // Aramayı gerçekleştir
=======
  }

  // Aramayı tetikle
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

<<<<<<< HEAD
    // Klavyeyi kapat
    context.hideKeyboard();

    // Aramayı yap
=======
    context.hideKeyboard(); // Klavyeyi gizle

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    await contentViewModel.searchContents(query, _selectedLanguage);
  }

  // Aramayı temizle
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });

<<<<<<< HEAD
    // İçerikleri yeniden yükle
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
        appBar: AppBar(
        title: Text(S.of(context).appName),
    actions: [
    IconButton(
    icon: const Icon(Icons.language),
    onPressed: () => _showLanguageSelector(context),
    ),
    IconButton(
    icon: const Icon(Icons.account_circle),
    onPressed: () => Navigator.pushNamed(context, '/profile'),
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

      // İçerik listesi
      Expanded(
        child: _buildContentList(),
      ),
    ],
    ),
    ),
      // Editörler için içerik ekleme butonu
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
      floatingActionButton: _buildEditorFab(),
    );
  }

<<<<<<< HEAD
  // Kategori listesi widget'ı
=======
  // Kategori listesini yatay olarak oluşturan widget
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // Kategori öğesi widget'ı
=======
  // Tek bir kategori kartını döndüren yardımcı widget
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // İçerik listesi widget'ı
=======
  // İçerik listesini oluşturan widget
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
          onNotification: (ScrollNotification scrollInfo) {
            if (!contentViewModel.isLoadingMore &&
                contentViewModel.hasMoreContents &&
                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              // Scroll en aşağıya geldiğinde daha fazla içerik yükle
=======
          onNotification: (scrollInfo) {
            if (!contentViewModel.isLoadingMore &&
                contentViewModel.hasMoreContents &&
                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
                // Daha fazla yükleniyor göstergesi
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD

  // İçerik öğesi widget'ı
  Widget _buildContentItem(ContentModel content) {
    // İçerik başlığını, seçilen dilde veya mevcut ilk dilde göster
    final title = content.title[_selectedLanguage] ??
        content.title.values.first;

    // İçerik özetini, seçilen dilde veya mevcut ilk dilde göster
    final summary = content.summary[_selectedLanguage] ??
        content.summary.values.first;
=======
  // Tek bir içerik kartını oluşturan widget
  Widget _buildContentItem(ContentModel content) {
    final title = content.title[_selectedLanguage] ?? content.title.values.first;
    final summary = content.summary[_selectedLanguage] ?? content.summary.values.first;
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.medium),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
<<<<<<< HEAD
          // İçerik detay sayfasına yönlendir
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
          Navigator.pushNamed(
            context,
            '/content',
            arguments: {'contentId': content.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
<<<<<<< HEAD
            // Thumbnail veya ilk medya
=======
            // Thumbnail veya medya
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
                      child: Container(
                        color: Colors.white,
                      ),
=======
                      child: Container(color: Colors.white),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
            // İçerik metni
=======
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
            Padding(
              padding: const EdgeInsets.all(AppSizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    title,
<<<<<<< HEAD
                    style: Theme.of(context).textTheme.titleLarge,
=======
                    style: Theme.of(context).textTheme.titleLarge, // 🆕 subtitle1 → titleLarge
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.small),

                  // Özet
                  Text(
                    summary,
<<<<<<< HEAD
                    style: Theme.of(context).textTheme.bodyMedium,
=======
                    style: Theme.of(context).textTheme.bodyMedium, // 🆕 bodyText2 → bodyMedium
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.medium),

<<<<<<< HEAD
                  // Alt bilgiler (beğeni, yorum, görüntüleme sayısı)
=======
                  // Alt bilgi satırı
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                  Row(
                    children: [
                      // Kategori etiketi
                      Container(
<<<<<<< HEAD
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
=======
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ContentCategories.categories[
<<<<<<< HEAD
                          content.category.toString().split('.').last
                          ] ?? '',
=======
                          content.category.toString().split('.').last] ?? '',
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

<<<<<<< HEAD
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
=======
                      // Beğeni, yorum, görüntüleme
                      Row(children: [
                        const Icon(Icons.favorite, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${content.likesCount}', style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(width: AppSizes.medium),
                      Row(children: [
                        const Icon(Icons.comment, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${content.commentsCount}', style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(width: AppSizes.medium),
                      Row(children: [
                        const Icon(Icons.visibility, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${content.viewsCount}', style: const TextStyle(fontSize: 12)),
                      ]),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // Yükleniyor animasyonu
=======
  // İçerik yüklenirken shimmer efekti
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
              // Görsel alanı
              Container(
                width: double.infinity,
=======
              Container(
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
                ),
              ),
              const SizedBox(height: AppSizes.medium),
<<<<<<< HEAD

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
=======
              Container(width: double.infinity, height: 20, color: Colors.white),
              const SizedBox(height: AppSizes.small),
              Container(width: double.infinity, height: 16, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: double.infinity, height: 16, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: 200, height: 16, color: Colors.white),
              const SizedBox(height: AppSizes.medium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 80, height: 20, color: Colors.white),
                  Container(width: 100, height: 20, color: Colors.white),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  // Editör FAB (Editör rolü varsa)
  Widget? _buildEditorFab() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Kullanıcı editör rolüne sahipse, içerik ekleme butonu göster
=======
  // Editör kullanıcısı için içerik ekleme FAB butonu
  Widget? _buildEditorFab() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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

<<<<<<< HEAD
  // Dil seçimi dialogu
=======
  // Dil seçme diyaloğu
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD

                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  )
=======
                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
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
<<<<<<< HEAD
              onPressed: () {
                Navigator.pop(context);
              },
=======
              onPressed: () => Navigator.pop(context),
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 2760134 (Hataların düzeltilmesi ve kod yapısının iyileştirilmesi)
