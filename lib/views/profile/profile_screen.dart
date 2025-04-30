// Dosya: lib/views/profile/profile_screen.dart
// Amaç: Kullanıcı profilini gösterir, kullanıcının paylaşımlarını ve bilgilerini listeler.
// Bağlantı: home_screen.dart’tan profil sekmesine tıklanınca çağrılır.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/content_model.dart';
import '../content/content_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    if (authViewModel.user == null) {
      return const Center(child: Text('Lütfen giriş yapın'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
        ],
      ),
      body: profileViewModel.user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileViewModel.user?['photoUrl'] != null
                  ? CachedNetworkImageProvider(profileViewModel.user!['photoUrl'])
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              profileViewModel.user?['displayName'] ?? 'Kullanıcı Adı',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(profileViewModel.user?['bio'] ?? 'Biyografi yok'),
            const SizedBox(height: 16),
            const Text(
              'Paylaşımlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profileViewModel.contents.length,
              itemBuilder: (context, index) {
                final content = profileViewModel.contents[index];
                return ListTile(
                  leading: content.imageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: content.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                      : const Icon(Icons.image),
                  title: Text(content.title),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/content_detail',
                      arguments: content.id,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}