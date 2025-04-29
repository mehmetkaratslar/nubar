import 'package:flutter/material.dart';
import 'package:nubar/views/profile/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/content_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../content/content_detail_screen.dart';


class ProfileScreen extends StatefulWidget {
  final String? userId; // Null ise kendi profili, değilse başka kullanıcı

  ProfileScreen({this.userId});

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
      _loadProfileData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);

    if (widget.userId == null) {
      // Kendi profili
      if (authViewModel.user != null) {
        await profileViewModel.loadUserProfile(authViewModel.user!.id);
      }
    } else {
      // Başka kullanıcının profili
      await profileViewModel.loadUserProfile(widget.userId!, isMyProfile: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    final user = profileViewModel.user;
    final isLoading = profileViewModel.isLoading;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profil yüklenemedi.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfileData,
              child: Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              actions: [
                if (profileViewModel.isMyProfile)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(),
                        ),
                      ).then((_) => _loadProfileData());
                    },
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppTheme.primaryRed,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30), // AppBar için alan bırak
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user.photoUrl != null
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                          user.displayName.substring(0, 1),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        )
                            : null,
                      ),
                      SizedBox(height: 12),
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            user.bio!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'İçerikler'),
                  Tab(text: 'Beğenilenler'),
                  Tab(text: 'Kaydedilenler'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // İçerikler Tab
            _buildContentGrid(profileViewModel.userContents),

            // Beğenilenler Tab
            _buildContentGrid(profileViewModel.likedContents),

            // Kaydedilenler Tab
            _buildContentGrid(profileViewModel.savedContents),
          ],
        ),
      ),
    );
  }

  Widget _buildContentGrid(List<ContentModel> contents) {
    if (contents.isEmpty) {
      return Center(
        child: Text('Henüz içerik bulunmamaktadır.'),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        return _buildContentCard(contents[index]);
      },
    );
  }

  Widget _buildContentCard(ContentModel content) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContentDetailScreen(contentId: content.id),
          ),
        ).then((_) => _loadProfileData()); // Detay ekranından dönünce profili yenile
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İçerik görseli
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: content.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: content.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
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

            // İçerik bilgileri
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      content.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),

                  // Başlık
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Etkileşim bilgileri
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 2),
                      Text(
                        content.likeCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 2),
                      Text(
                        content.commentCount.toString(),
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
          ],
        ),
      ),
    );
  }
}