// Dosya: lib/views/profile/edit_profile_screen.dart
// Amaç: Kullanıcı profilini düzenleme ekranını gösterir.
// Bağlantı: app.dart üzerinden çağrılır, ProfileViewModel ile entegre çalışır.
// Not: BuildContext parametresi kaldırıldı, hata yönetimi UI katmanına taşındı.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/profile_viewmodel.dart';

import '../../utils/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    _displayNameController.text = profileViewModel.userDisplayName ?? '';
    _bioController.text = profileViewModel.bio ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Profil resmini seçer
  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPhoto = File(result.files.single.path!);
      });
    }
  }

  // Profili günceller
  Future<void> _updateProfile() async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    if (_selectedPhoto != null) {
      await profileViewModel.updateProfilePhoto(_selectedPhoto!);
      if (profileViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profileViewModel.errorMessage!)),
        );
        return;
      }
    }
    await profileViewModel.updateProfile(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
    );
    if (profileViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileViewModel.errorMessage!)),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryRed,
              Colors.white,
              AppConstants.primaryGreen,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  l10n.editProfile,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryRed,
                  ),
                ),
                const SizedBox(height: 16),
                // Profil resmi
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedPhoto != null
                          ? FileImage(_selectedPhoto!)
                          : profileViewModel.userPhotoUrl != null
                          ? NetworkImage(profileViewModel.userPhotoUrl!)
                          : null,
                      child: _selectedPhoto == null && profileViewModel.userPhotoUrl == null
                          ? Text(
                        profileViewModel.userDisplayName?.isNotEmpty == true
                            ? profileViewModel.userDisplayName![0]
                            : '',
                        style: const TextStyle(fontSize: 40),
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Kullanıcı adı
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Bio
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: l10n.bio,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Kaydet butonu
                profileViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}