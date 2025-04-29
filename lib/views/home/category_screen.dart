// lib/views/home/category_screen.dart
// Purpose: Displays a list of categories for users to browse content.
// Location: lib/views/home/
// Connection: Navigated to from HomeScreen, navigates to ContentListScreen on category selection.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/content/content_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['History', 'Language', 'Art', 'Music', 'Traditions'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Categories', // TODO: Replace with AppLocalizations
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                categories[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContentListScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}