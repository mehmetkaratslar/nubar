// Dosya: lib/main.dart
// Amaç: Uygulamanın giriş noktası, bağımlılıkları oluşturur ve App widget'ını başlatır.
// Bağlantı: app.dart ile entegre çalışır, tüm servisleri ve ViewModel'leri sağlar.
// Not: SearchViewModel için pozisyonel parametre düzeltildi.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/analytics_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/content_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter bağlayıcılarını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check'i yapılandır (Debug modunda)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Bağımlılıkları oluştur
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final storageService = StorageService();
  final analyticsService = AnalyticsService();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Uygulamayı başlat
  runApp(
    MultiProvider(
      providers: [
        // Servis sağlayıcıları
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),
        Provider<AnalyticsService>.value(value: analyticsService),
        Provider<SharedPreferences>.value(value: sharedPreferences),
        // ViewModel sağlayıcıları
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(sharedPreferences: sharedPreferences)..initialize(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentViewModel(
            firestoreService: firestoreService,
            storageService: storageService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            firestoreService: firestoreService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(firestoreService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Uygulamanın ana widget'ı
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const App(); // App widget'ını başlat
  }
}