import 'package:flutter/material.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';
import 'package:su/data/github_api_service.dart';
import 'package:su/data/pdf_downloader.dart';
import 'package:su/pages/code_viewer_page.dart';
import 'package:su/pages/pdf_viewer_page.dart';
import 'package:su/widgets/app_bar_widget.dart';
import 'package:su/widgets/file_tiles.dart';

class SemesterPage extends StatelessWidget {
  final String title;
  final String apiPath;

  const SemesterPage({
    super.key,
    required this.title,
    required this.apiPath,
  });

  Future<void> _openFile(BuildContext context, Map item) async {
    final name = item['name'] as String;
    final url  = item['download_url'] as String;

    if (name.toLowerCase().endsWith('.pdf')) {
      final file = await PdfDownloader.download(url, name);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(file: file, title: name),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CodeViewerPage(fileName: name, rawUrl: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(title),
      body: FutureBuilder<List<dynamic>>(
        future: GitHubApiService.fetchContents(apiPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final data    = snapshot.data!;
          final folders = data.where((i) => i['type'] == 'dir').toList();
          final files   = data.where((i) => i['type'] == 'file').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              if (folders.isNotEmpty) ...[
                Text('Folders', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 8),
                ...folders.map((item) => FolderTile(
                      name: item['name'],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SemesterPage(
                            title:   item['name'],
                            apiPath: item['path'],
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (files.isNotEmpty) ...[
                Text('Files', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 8),
                ...files.map((item) => FileTile(
                      name:  item['name'],
                      onTap: () => _openFile(context, item),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
