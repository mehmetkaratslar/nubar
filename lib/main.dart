// lib/main.dart
// Uygulamanın başlangıç noktası ve genel yapılandırması
// Bu dosya, Firebase'i başlatır, provider'ları ayarlar ve MyApp widget'ını çalıştırır

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Firebase yapılandırması
import 'firebase_options.dart';

// Uygulama ana widget'ı
import 'app.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/content_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/editor_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';

// Servisler
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/analytics_service.dart';

// Çoklu dil desteği için oluşturulan sınıf
import 'generated/l10n.dart';

void main() async {
  // Flutter engine'i başlat
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Splash screen'i göster ve beklet
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Servisleri oluştur
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final storageService = StorageService();
  final analyticsService = AnalyticsService();

  // Splash screen'i kaldır
  FlutterNativeSplash.remove();

  // Uygulamayı başlat
  runApp(
    // MultiProvider ile tüm ViewModel'leri oluştur ve bağımlılıklarını enjekte et
    MultiProvider(
      providers: [
        // Servis provider'ları - Diğer provider'lar için gerekli
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),
        Provider<AnalyticsService>.value(value: analyticsService),

        // ViewModel provider'ları - UI'a veri ve davranış sağlar
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authService: authService,
            firestoreService: firestoreService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
          ),
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
            authService: authService,
            firestoreService: firestoreService,
            storageService: storageService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EditorViewModel(
            firestoreService: firestoreService,
            storageService: storageService,
            analyticsService: analyticsService,
          ),
        ),
      ],
      // Uygulamanın root widget'ı
      child: const MyApp(),
    ),
  );
}