// lib/views/content/content_list_screen.dart
// Purpose: Displays a list of content items in a specific category.
// Location: lib/views/content/
// Connection: Navigated to from CategoryScreen, navigates to ContentDetailScreen on item tap.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/content/content_detail_screen.dart'; // Added import

class ContentListScreen extends StatelessWidget {
  const ContentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Content List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5, // TODO: Replace with dynamic data from ContentViewModel
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Constants.lightGray,
                child: const Center(child: Text('Thumb')),
              ),
              title: Text(
                'Content Title $index',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Content snippet...'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContentDetailScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}