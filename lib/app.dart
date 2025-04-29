import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/splash/splash_screen.dart';
import 'utils/theme.dart';


// Uygulamanın giriş noktası - sadeleştirilmiş temel hali
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nûbar - Kürt Kültür Platformu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      themeMode: ThemeMode.system,
      locale: const Locale('ku'), // Varsayılan dil Kürtçe
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
