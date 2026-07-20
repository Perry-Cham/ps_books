import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/models/downloader_models.dart';
import './parsers/gutenberg.dart';

enum GutenbergSearchMode { normal, series }

class Gutenberg implements SeriesCapable {
  GutenbergSearchMode mode = GutenbergSearchMode.normal;
  final GutenbergScraper _scraper;

  Gutenberg({GutenbergSearchMode? mode, GutenbergScraper? scraper})
      : mode = mode ?? GutenbergSearchMode.normal,
        _scraper = scraper ?? GutenbergScraper();

  @override
  Future<List<SeriesModel>> search({required String query}) async {
    if (mode == GutenbergSearchMode.series) {
      // In series mode, search collections whose title matches the query
      final collections = await _scraper.getCollections();
      final filtered = collections
          .where((c) =>
              c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return filtered.map((c) => SeriesModel(
            id: c.id,
            title: c.title,
            coverUrl: null,
            detailUrl: c.url,
          )).toList();
    }

    // Normal mode: search for individual books
    final books = await _scraper.searchBooks(query: query);
    return books.map((b) => SeriesModel(
          id: b.id,
          title: b.author != null ? '${b.title} - ${b.author}' : b.title,
          coverUrl: b.coverUrl,
          detailUrl: b.downloadUrl ?? b.detailUrl,
        )).toList();
  }

  @override
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    // Get all books in the collection
    final books = await _scraper.getCollectionBooks(collectionUrl: volumeUrl);
    return books.map((b) => VolumeInfo(
          id: b.id,
          label: b.author != null ? '${b.title} - ${b.author}' : b.title,
          chapterUrl: b.downloadUrl ?? b.detailUrl,
        )).toList();
  }

  @override
  void download({required VolumeInfo volume}) {
    // Delegate to the central downloader
  }
}
