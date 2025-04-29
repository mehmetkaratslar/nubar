// lib/views/home/category_screen.dart
// Amaç: Kullanıcıların içerik kategorilerini görüntülediği ekran.
// Konum: lib/views/home/
// Bağlantı: HomeScreen'den gelir, ContentListScreen'e yönlendirir.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/content/content_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Tarih', 'icon': Constants.categoryIcons['history']},
      {'title': 'Dil', 'icon': Constants.categoryIcons['language']},
      {'title': 'Sanat', 'icon': Constants.categoryIcons['art']},
      {'title': 'Müzik', 'icon': Constants.categoryIcons['music']},
      {'title': 'Gelenekler', 'icon': Constants.categoryIcons['traditions']},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Kategoriler',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Constants.backgroundColor,
              Constants.lightGray,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Constants.spacingMedium),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Constants.spacingMedium,
              mainAxisSpacing: Constants.spacingMedium,
              childAspectRatio: 1.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContentListScreen()),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.cardBorderRadius),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Constants.cardBorderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constants.primaryColor.withOpacity(0.8),
                          Constants.secondaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: Constants.spacingSmall),
                        Text(
                          category['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: Constants.textLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}