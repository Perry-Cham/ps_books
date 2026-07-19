import 'package:ps_books/models/comic_book_model.dart';
import './parsers/series.dart';
import './parsers/files.dart';
import 'package:ps_books/models/downloader_models.dart';

enum SearchMode { files, series }

class Libgen implements SeriesCapable {
  SearchMode mode = SearchMode.files;

  Libgen({SearchMode? mode}) : mode = mode ?? SearchMode.files;

  @override
  Future<List<SeriesModel>> search({required String query}) async {
    if (mode == SearchMode.series) {
      final scraper = LibGenScraper();
      try {
        final results = await scraper.searchBooks(query: query);
        return results.map((r) => SeriesModel(
          id: r.detailUrl,
          title: r.title,
          coverUrl: r.coverImageUrl,
          detailUrl: r.detailUrl,
        )).toList();
      } finally {
        scraper.dispose();
      }
    } else {
      final result = await LibgenFilesScraper.search(query);
      return result?.map((b) => SeriesModel(
        id: b.href,
        title: b.title,
        coverUrl: b.image,
        detailUrl: b.href,
      )).toList() ?? [];
    }
  }

  @override
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    if (mode == SearchMode.series) {
      final scraper = LibGenScraper();
      try {
        final issues = await scraper.getIssueList(detailUrl: volumeUrl);
        return issues.map((i) => VolumeInfo(
          id: i.editionId,
          label: i.title ?? 'Issue #${i.issueNumber}',
          chapterUrl: i.editionUrl,
        )).toList();
      } finally {
        scraper.dispose();
      }
    }
    return [];
  }

  @override
  void download({required VolumeInfo volume}) {
    // Delegate to downloader
  }
}
