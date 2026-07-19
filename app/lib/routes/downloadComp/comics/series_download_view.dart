import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/services/download/downloader.dart';
import 'package:ps_books/state/download_state.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';

final _db = BookToDb();

class SeriesDownloadView extends ConsumerWidget {
  final SeriesModel seriesModel;
  final List<VolumeInfo> volumes;

  const SeriesDownloadView({
    super.key,
    required this.seriesModel,
    required this.volumes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(seriesModel.title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (seriesModel.coverUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        seriesModel.coverUrl!,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 120,
                          height: 180,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.book, size: 48),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seriesModel.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${volumes.length} volumes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final volume = volumes[index];
                return ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(volume.label),
                  subtitle: Text(volume.id),
                  trailing: const Icon(Icons.file_download_outlined),
                  onTap: () => _downloadVolume(context, ref, volume),
                );
              },
              childCount: volumes.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadVolume(BuildContext context, WidgetRef ref, VolumeInfo volume) async {
    try {
      final fileName = await getFileName(volume.chapterUrl);
      ref.read(downloadProgressProvider.notifier).setFileName(fileName);
      ref.read(downloadProgressProvider.notifier).startDownload(volume.chapterUrl, fileName);

      await _createSeriesEntry(volume);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ${volume.label}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _createSeriesEntry(VolumeInfo volume) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${docsPath.path}/Books');

    var series = await _db.getSeriesByName(seriesModel.title);
    int seriesId;
    if (series != null) {
      seriesId = series.id;
      if (series.cover == null && seriesModel.coverUrl != null) {
        await _db.updateSeriesCover(seriesId, seriesModel.coverUrl);
      }
    } else {
      seriesId = await _db.addSeries(
        seriesModel.title,
        cover: seriesModel.coverUrl,
      );
    }

    await _db.addBook(
      name: volume.label,
      extension: 'epub',
      path: '${booksDir.path}/$volume.id',
      series: seriesId,
      isSeries: true,
    );
  }
}
