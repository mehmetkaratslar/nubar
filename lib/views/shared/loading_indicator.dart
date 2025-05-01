// Dosya: lib/views/shared/loading_indicator.dart
// Amaç: Yükleme göstergesi bileşeni sağlar.
// Bağlantı: Çeşitli ekranlarda kullanılır (örneğin, home_screen.dart, profile_screen.dart).
// Not: Constants yerine AppConstants kullanıldı, yorumlar eklendi.

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

// Yükleme göstergesi bileşeni
class LoadingIndicator extends StatelessWidget {
  // Gösterge rengi
  final Color color;
  // Gösterge boyutu
  final double size;
  // Çizgi kalınlığı
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.color = AppConstants.primaryRed,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  // Ana yapı fonksiyonu
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: strokeWidth,
      ),
    );
  }
}
