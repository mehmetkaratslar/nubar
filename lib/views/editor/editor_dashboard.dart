// lib/views/editor/editor_dashboard.dart
// Purpose: Provides a dashboard for editors to manage content and moderate comments.
// Location: lib/views/editor/
// Connection: Navigates to ContentEditorScreen for adding/editing content.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';
import 'package:nubar/views/editor/content_editor_screen.dart';

class EditorDashboard extends StatelessWidget {
  const EditorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Editor Dashboard', // TODO: Replace with AppLocalizations
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new content button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContentEditorScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Content'), // TODO: Replace with AppLocalizations
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Moderation section
            const Text(
              'Moderation Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // TODO: Replace with dynamic data (e.g., reported comments)
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Reported Comment $index'),
                      subtitle: const Text('User reported this comment for review.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement comment deletion
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}