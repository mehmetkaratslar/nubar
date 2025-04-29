// lib/views/editor/content_editor_screen.dart
// Purpose: Allows editors to create or edit content items.
// Location: lib/views/editor/
// Connection: Navigated to from EditorDashboard, saves content to Firestore.

import 'package:flutter/material.dart';
import 'package:nubar/utils/constants.dart';

class ContentEditorScreen extends StatelessWidget {
  const ContentEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Content Editor', // TODO: Replace with AppLocalizations
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title', // TODO: Replace with AppLocalizations
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Description field
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description', // TODO: Replace with AppLocalizations
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category', // TODO: Replace with AppLocalizations
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'History', child: Text('History')),
                  DropdownMenuItem(value: 'Language', child: Text('Language')),
                  DropdownMenuItem(value: 'Art', child: Text('Art')),
                  DropdownMenuItem(value: 'Music', child: Text('Music')),
                  DropdownMenuItem(value: 'Traditions', child: Text('Traditions')),
                ],
                onChanged: (value) {
                  // TODO: Handle category selection
                },
              ),
              const SizedBox(height: 20),
              // Media upload button
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement media upload with StorageService
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Media'), // TODO: Replace with AppLocalizations
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                ),
              ),
              const SizedBox(height: 20),
              // Save button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save logic with ContentViewModel
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    'Save', // TODO: Replace with AppLocalizations
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}