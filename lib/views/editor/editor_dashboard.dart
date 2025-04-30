// Dosya: lib/views/editor/editor_dashboard.dart
// Amaç: Editörlerin içerik yönetim paneli.
// Bağlantı: home_screen.dart’tan yönlendirilir, content_editor_screen.dart’a gider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../models/content_model.dart';
import 'content_editor_screen.dart';

class EditorDashboard extends StatefulWidget {
  const EditorDashboard({Key? key}) : super(key: key);

  @override
  _EditorDashboardState createState() => _EditorDashboardState();
}

class _EditorDashboardState extends State<EditorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);
      editorViewModel.fetchDraftContents();
      editorViewModel.fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorViewModel = Provider.of<EditorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editör Paneli'),
      ),
      body: editorViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Taslaklar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: editorViewModel.draftContents.length,
              itemBuilder: (context, index) {
                final draft = editorViewModel.draftContents[index];
                return ListTile(
                  title: Text(draft.title),
                  subtitle: Text(draft.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/content_editor',
                            arguments: draft.id,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.publish),
                        onPressed: () async {
                          await editorViewModel.publishDraft(draft.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Taslak yayınlandı')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await editorViewModel.deleteDraft(draft.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Taslak silindi')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Şikayetler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: editorViewModel.reports.length,
              itemBuilder: (context, index) {
                final report = editorViewModel.reports[index];
                return ListTile(
                  title: Text(report.contentTitle),
                  subtitle: Text('Sebep: ${report.reason}'),
                  trailing: Text(report.status),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/content_editor');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}