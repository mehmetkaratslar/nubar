// Dosya: lib/views/home/home_screen.dart
// Amaç: Ana sayfa, kategorileri ve içerikleri listeler.
// Bağlantı: splash_screen.dart’tan yönlendirilir, category_screen.dart, profile_screen.dart, search_screen.dart’a bağlantı verir.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/content_model.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

import '../editor/editor_dashboard.dart';
import '../../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.loadHomePageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NÛBAR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler (gelecekte eklenecek)
            },
          ),
        ],
      ),
      body: _buildSelectedTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppConstants.primaryRed,
        unselectedItemColor: AppConstants.darkGray,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Kaydedilenler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppConstants.primaryRed,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    backgroundImage: authViewModel.userData?['photoUrl'] != null
                        ? CachedNetworkImageProvider(authViewModel.userData!['photoUrl'])
                        : null,
                    child: authViewModel.userData?['photoUrl'] == null
                        ? Text(
                      authViewModel.userData?['displayName']?.substring(0, 1) ?? 'N',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryRed,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authViewModel.userData?['displayName'] ?? 'Kullanıcı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authViewModel.userData?['email'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Dil Değiştir'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/language_selection');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.pop(context);
                // Ayarlar ekranı (gelecekte eklenecek)
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Hakkında'),
              onTap: () {
                Navigator.pop(context);
                // Hakkında ekranı (gelecekte eklenecek)
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                await authViewModel.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: authViewModel.isEditor
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/editor_dashboard');
        },
        child: const Icon(Icons.edit),
      )
          : null,
    );
  }

  Widget _buildSelectedTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildSavedTab();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final homeViewModel = Provider.of<HomeViewModel>(context);

    if (homeViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeViewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(homeViewModel.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => homeViewModel.loadHomePageData(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => homeViewModel.loadHomePageData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeViewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = homeViewModel.categories[index];
                  final isSelected = category == homeViewModel.selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      homeViewModel.setCategory(category);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConstants.primaryRed : AppConstants.lightGray,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? AppConstants.primaryRed : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppConstants.darkGray,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (homeViewModel.featuredContents.isNotEmpty) ...[
              const Text(
                'Öne Çıkan İçerikler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeViewModel.featuredContents.length,
                  itemBuilder: (context, index) {
                    final content = homeViewModel.featuredContents[index];
                    return _buildFeaturedContentCard(content);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Son Eklenenler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (homeViewModel.filteredContents.isEmpty)
              const Center(
                child: Text('Bu kategoride henüz içerik bulunmamaktadır.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeViewModel.filteredContents.length,
                itemBuilder: (context, index) {
                  final content = homeViewModel.filteredContents[index];
                  return _buildContentListItem(content);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return const Center(
      child: Text('Keşfet - Bu özellik yakında - Bu özellik yakında eklenecek.'),
    );
  }

  Widget _buildSavedTab() {
    return const Center(
      child: Text('Kaydedilenler - Bu özellik yakında eklenecek.'),
    );
  }

  Widget _buildFeaturedContentCard(ContentModel content) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/content_detail',
          arguments: content.id,
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: content.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: content.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              )
                  : Container(
                height: 120,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Padding(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentListItem(ContentModel content) {
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(content.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  String _formatDate(DateTime? timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    final date = timestamp;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}