// lib/views/content/content_detail_screen.dart
// Purpose: Displays detailed information about a specific content item (e.g., article, video).
// Location: lib/views/content/
// Connection: Navigated to from ContentListScreen, allows interaction (like, comment).

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';

class ContentDetailScreen extends StatelessWidget {
  const ContentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Content Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Content Title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.darkGray, // Removed const
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              color: Constants.lightGray,
              child: const Center(
                child: Text('Image/Video Placeholder'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This is a sample content description. It will be replaced with actual content fetched from Firestore.',
              style: TextStyle(fontSize: 16, color: Constants.darkGray),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Like'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.accentColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment),
                  label: const Text('Comment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Comments Section',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              color: Constants.lightGray,
              child: const Center(
                child: Text('Comments will be displayed here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}