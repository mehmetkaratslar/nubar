// Dosya: lib/main.dart
// Amaç: Uygulamanın giriş noktası, Firebase ve servisleri başlatır, App widget’ına bağımlılıkları enjekte eder.
// Bağlantı: App widget’ı (app.dart) ile bağlantılıdır, tüm ekranlara altyapı sağlar.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // Doğru firebase_options.dart dosyasını import ediyoruz
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/content_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase’i lib/firebase_options.dart’tan gelen yapılandırma ile başlatıyoruz
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase başarıyla başlatıldı.");
  } catch (e) {
    print("Firebase başlatma hatası: $e");
  }
  final sharedPreferences = await SharedPreferences.getInstance();
  final authService = AuthService();
  final firestoreService = FirestoreService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService, sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentViewModel(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(firestoreService),
        ),
      ],
      child: App(
        authService: authService,
        firestoreService: firestoreService,
        sharedPreferences: sharedPreferences,
      ),
    ),
  );
}