// Dosya: lib/views/notifications/notifications_screen.dart
// Amaç: Bildirim ekranını gösterir.
// Bağlantı: app.dart üzerinden çağrılır.
// Not: Bildirim yükleme işlemleri asenkron hale getirildi.

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/app_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Bildirimleri asenkron olarak yükle
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Örnek: Firestore'dan bildirimleri yükle
    // Gerçek uygulamada bu kısım Firestore veya başka bir servisten veri çekebilir
    await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş gecikme
    setState(() {
      _notifications = [
        "New content added to History category",
        "Your comment received a reply",
        "A new follower: @user123",
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : _notifications.isEmpty
              ? Center(child: Text(l10n.noNotificationsLabel))
              : ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            itemCount: _notifications.length,
            itemExtent: 80,
            cacheExtent: 1000,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notification),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}