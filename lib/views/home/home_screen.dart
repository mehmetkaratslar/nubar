// Dosya: lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../shared/content_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsü
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _animationController.forward();

    // Ana ekran verilerini asenkron olarak yükle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      await Future.wait([
        homeViewModel.loadHomePageData(),
        homeViewModel.loadStories(),
      ]);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Yenileme işlemi için manuel metod
  Future<void> _handleRefresh() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    await Future.wait([
      homeViewModel.loadHomePageData(),
      homeViewModel.loadStories(),
    ]);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryRed.withOpacity(0.8),
              Colors.white,
              AppConstants.primaryGreen.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: homeViewModel.isLoading
              ? _buildLoadingIndicator()
              : homeViewModel.errorMessage != null
              ? _buildErrorMessage(homeViewModel.errorMessage!)
              : FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(context, homeViewModel, l10n, size),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryRed,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.of(context).pushNamed('/content_editor'),
      ),
    );
  }

  // Yükleme göstergesi
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitPulsingGrid(
            color: AppConstants.primaryRed,
            size: 50.0,
          ),
          const SizedBox(height: 24),
          const Text(
            "Naverok tê barkirin...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Hata mesajı
  Widget _buildErrorMessage(String errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppConstants.primaryRed,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Dîsa biceribîne"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ana içerik yapısı
  Widget _buildContent(BuildContext context, HomeViewModel homeViewModel, AppLocalizations l10n, Size size) {
    return Column(
      children: [
        _buildHeader(),
        _buildCategorySelector(homeViewModel, l10n),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStorySection(homeViewModel, l10n),
                _buildFeaturedSection(homeViewModel, l10n),
                _buildAllContentsSection(homeViewModel, l10n, size),
                const SizedBox(height: 80), // Ekranın altında boşluk
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Başlık ve Arama Düğmesi
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "N",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "NÛBAR",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppConstants.primaryRed,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, size: 26),
                color: AppConstants.primaryRed,
                onPressed: () => Navigator.of(context).pushNamed('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                color: AppConstants.primaryRed,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kategori Seçici
  Widget _buildCategorySelector(HomeViewModel homeViewModel, AppLocalizations l10n) {
    final categories = [
      {'id': 'all', 'name': l10n.allLabel},
      {'id': 'history', 'name': l10n.historyLabel},
      {'id': 'language', 'name': l10n.languageLabel},
      {'id': 'music', 'name': l10n.musicLabel},
      {'id': 'art', 'name': l10n.artLabel},
      {'id': 'traditions', 'name': l10n.traditionsLabel},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = homeViewModel.selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => homeViewModel.selectCategory(category['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryRed : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )]
                      : null,
                ),
                child: Center(
                  child: Text(
                    category['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hikayeler Bölümü
  Widget _buildStorySection(HomeViewModel homeViewModel, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            l10n.storiesLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryRed,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: homeViewModel.stories.isEmpty
              ? _buildEmptyPlaceholder(
            context,
            l10n.noStoriesLabel,
            "Hikaye oluştur",
            '/content_editor',
            Icons.add_a_photo,
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: homeViewModel.stories.length + 1, // +1 için ekleme butonu
            itemBuilder: (context, index) {
              // Son öğe olarak ekleme butonu
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/content_editor'),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppConstants.primaryRed.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 30,
                            color: AppConstants.primaryRed.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Yeni",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final story = homeViewModel.stories[index - 1]; // -1 çünkü ilk öğe ekleme butonu
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryRed,
                                AppConstants.primaryGreen,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: story.mediaUrl != null
                                  ? DecorationImage(
                                image: NetworkImage(story.mediaUrl!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: story.mediaUrl == null
                                ? Center(
                              child: Text(
                                story.userDisplayName[0],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryRed.withOpacity(0.8),
                                ),
                              ),
                            )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 14,
                              color: AppConstants.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 68,
                      child: Text(
                        story.userDisplayName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Öne Çıkan İçerikler Bölümü
  Widget _buildFeaturedSection(HomeViewModel homeViewModel, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.featuredContents,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryRed,
                ),
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Text(
                        l10n.seeAllLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.primaryRed.withOpacity(0.8),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppConstants.primaryRed.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: homeViewModel.featuredContents.isEmpty
              ? _buildEmptyPlaceholder(
            context,
            l10n.noFeaturedContentsLabel,
            "İçerik ekle",
            '/content_editor',
            Icons.add_to_photos,
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: homeViewModel.featuredContents.length,
            itemBuilder: (context, index) {
              final content = homeViewModel.featuredContents[index];

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ContentCard(content: content),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Tüm İçerikler Bölümü
  Widget _buildAllContentsSection(HomeViewModel homeViewModel, AppLocalizations l10n, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.allContents,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryRed,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/all_contents'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Text(
                        l10n.seeAllLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.primaryRed.withOpacity(0.8),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppConstants.primaryRed.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        homeViewModel.filteredContents.isEmpty
            ? Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: _buildEmptyPlaceholder(
            context,
            l10n.noContentsFoundLabel,
            "İlk içeriğinizi oluşturun",
            '/content_editor',
            Icons.post_add,
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StaggeredGridView(
            crossAxisCount: 2,
            itemCount: homeViewModel.filteredContents.length > 4
                ? 4
                : homeViewModel.filteredContents.length,
            itemBuilder: (context, index) {
              final content = homeViewModel.filteredContents[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ContentCard(content: content),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Boş durumlar için yer tutucu
  Widget _buildEmptyPlaceholder(
      BuildContext context, String message, String actionText, String route, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppConstants.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(route),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(120, 36),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

// StaggeredGridView Widget
class StaggeredGridView extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const StaggeredGridView({
    Key? key,
    required this.crossAxisCount,
    required this.itemCount,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}