// Dosya: lib/views/profile/profile_screen.dart
// Amaç: Kullanıcı profilini gösterir, kullanıcının paylaşımlarını ve bilgilerini listeler.
// Bağlantı: home_screen.dart'tan profil sekmesine tıklanınca çağrılır.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/content_model.dart';
import '../content/content_detail_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      if (authViewModel.user != null) {
        profileViewModel.loadUserProfile(authViewModel.user!.uid);
        profileViewModel.loadUserContents(authViewModel.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // App theme colors
    const Color primaryRed = Color(0xFFE74C3C);
    const Color primaryGreen = Color(0xFF2ECC71);
    const Color primaryYellow = Color(0xFFF1C40F);
    const Color lightGrey = Color(0xFFF5F5F5);
    const Color darkGrey = Color(0xFF333333);
    const Color white = Color(0xFFFFFFFF);

    if (authViewModel.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Lütfen giriş yapın',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: profileViewModel.user == null
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
        ),
      )
          : CustomScrollView(
        slivers: [
          // Profil Başlığı - App Bar
          SliverAppBar(
            expandedHeight: screenHeight * 0.35,
            pinned: true,
            backgroundColor: primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan görseli (varsayılan gradient)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryRed,
                          primaryRed.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Dekoratif şekiller
                  Positioned(
                    top: -20,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Profile içeriği
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Profil fotoğrafı
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: profileViewModel.user?['photoUrl'] != null
                                  ? CachedNetworkImageProvider(profileViewModel.user!['photoUrl'])
                                  : null,
                              child: profileViewModel.user?['photoUrl'] == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Kullanıcı adı
                          Text(
                            profileViewModel.user?['displayName'] ?? 'Kullanıcı Adı',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Biyografi
                          if (profileViewModel.user?['bio'] != null &&
                              profileViewModel.user!['bio'].toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                profileViewModel.user!['bio'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Düzenleme butonu
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                ),
              ),
            ],
          ),

          // Tab Bar
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: primaryRed,
                labelColor: darkGrey,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.grid_on),
                    text: 'Paylaşımlar',
                  ),
                  Tab(
                    icon: Icon(Icons.bookmark),
                    text: 'Kaydedilenler',
                  ),
                  Tab(
                    icon: Icon(Icons.favorite),
                    text: 'Beğenilenler',
                  ),
                ],
              ),
            ),
            pinned: true,
          ),

          // İçerik bölümü
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenHeight * 0.6,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Paylaşımlar
                  _buildContentGrid(profileViewModel, context),

                  // Kaydedilenler (Bu örnek için aynı içeriğin aynısını kullanıyoruz)
                  _buildPlaceholderTab('Kaydedilen içerik bulunamadı'),

                  // Beğenilenler
                  _buildPlaceholderTab('Beğenilen içerik bulunamadı'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni içerik ekleme sayfasına git
          Navigator.pushNamed(context, '/create_content');
        },
        backgroundColor: primaryRed,
        child: const Icon(Icons.add, color: white),
      ),
    );
  }

  // İçerik grid'i
  Widget _buildContentGrid(ProfileViewModel profileViewModel, BuildContext context) {
    if (profileViewModel.contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz içerik paylaşmadınız',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk içeriğinizi paylaşmak için + butonuna tıklayın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: profileViewModel.contents.length,
        itemBuilder: (context, index) {
          final content = profileViewModel.contents[index];
          return _buildContentCard(content, context);
        },
      ),
    );
  }

  // İçerik kartı
  Widget _buildContentCard(var content, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/content_detail',
          arguments: content.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İçerik görseli
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: content.imageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: content.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  )
                      : Icon(
                    Icons.image,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                ),
              ),

              // İçerik başlığı ve bilgileri
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Beğeni sayısı
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Color(0xFFE74C3C),
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${content.likes ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Yorum sayısı
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.grey[600],
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${content.comments ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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
      ),
    );
  }

  // Boş tab göstergesi
  Widget _buildPlaceholderTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_neutral, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Yapışkan TabBar için özel delegasyon sınıfı
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}