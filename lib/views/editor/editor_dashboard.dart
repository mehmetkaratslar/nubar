// lib/views/editor/editor_dashboard.dart
// Editör kontrol paneli
// Editörün içerik yönetimi yapabileceği ana ekran

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';

// Models
import '../../models/content_model.dart';
import '../../models/report_model.dart';

// Utils
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

// Çoklu dil desteği
import '../../generated/l10n.dart';

class EditorDashboard extends StatefulWidget {
  const EditorDashboard({Key? key}) : super(key: key);

  @override
  State<EditorDashboard> createState() => _EditorDashboardState();
}

class _EditorDashboardState extends State<EditorDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadContents();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
      _loadActiveTabContent();
    }
  }

  Future<void> _loadActiveTabContent() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

    switch (_activeTabIndex) {
      case 0:
        await editorViewModel.loadEditorContents(authViewModel.userId);
        break;
      case 1:
        await editorViewModel.loadDraftContents(authViewModel.userId);
        break;
      case 2:
        await editorViewModel.loadPublishedContents(authViewModel.userId);
        break;
      case 3:
        await editorViewModel.loadReportedContents();
        break;
    }
  }

  void _loadContents() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final editorViewModel = Provider.of<EditorViewModel>(context, listen: false);

    editorViewModel.loadEditorContents(authViewModel.userId);
  }

  void _navigateToCreateContent() {
    Navigator.pushNamed(context, '/editor/content').then((_) => _loadActiveTabContent());
  }

  void _navigateToEditContent(String contentId) {
    Navigator.pushNamed(
      context,
      '/editor/content',
      arguments: {'contentId': contentId},
    ).then((_) => _loadActiveTabContent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).editorDashboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm İçerikler'),
            Tab(text: 'Taslaklar'),
            Tab(text: 'Yayınlananlar'),
            Tab(text: 'Şikayetler'),
          ],
        ),
      ),
      body: Consumer<EditorViewModel>(
        builder: (context, editorViewModel, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildContentList(editorViewModel.editorContents, editorViewModel.isLoading),
              _buildContentList(editorViewModel.draftContents, editorViewModel.isLoadingDrafts),
              _buildContentList(editorViewModel.publishedContents, editorViewModel.isLoadingPublished),
              _buildReportsList(
                editorViewModel.reportedContents,
                editorViewModel.reportedComments,
                editorViewModel.isLoadingReports,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateContent,
        child: const Icon(Icons.add),
        tooltip: S.of(context).createContent,
      ),
    );
  }

  Widget _buildContentList(List<ContentModel> contents, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contents.isEmpty) {
      return const Center(child: Text('Henüz içerik bulunmuyor'));
    }

    return RefreshIndicator(
      onRefresh: _loadActiveTabContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final content = contents[index];
          return _buildContentItem(content);
        },
      ),
    );
  }

  Widget _buildContentItem(ContentModel content) {
    final title = content.title['ku'] ?? content.title.values.first;
    final summary = content.summary['ku'] ?? content.summary.values.first;
    final languages = content.title.keys.toList().join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(summary, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Text(languages, style: const TextStyle(fontSize: 12)),
        onTap: () => _navigateToEditContent(content.id),
      ),
    );
  }

  Widget _buildReportsList(List<ReportModel> contentReports, List<ReportModel> commentReports, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contentReports.isEmpty && commentReports.isEmpty) {
      return const Center(child: Text('Bekleyen şikayet yok'));
    }

    return RefreshIndicator(
      onRefresh: _loadActiveTabContent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (contentReports.isNotEmpty)
            ...contentReports.map((report) => ListTile(
              title: Text('Içerik Şikayeti: ${report.description}'),
              onTap: () => _showReportDetails(report),
            )),
          if (commentReports.isNotEmpty)
            ...commentReports.map((report) => ListTile(
              title: Text('Yorum Şikayeti: ${report.description}'),
              onTap: () => _showReportDetails(report),
            )),
        ],
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detaylar'),
        content: Text(report.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
