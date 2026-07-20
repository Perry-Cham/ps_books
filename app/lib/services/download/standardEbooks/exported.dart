import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/models/downloader_models.dart';
import './parsers/collections.dart';

enum StebSearchMode { normal, collections }

class StandardEbooks implements SeriesCapable {
  StebSearchMode mode = StebSearchMode.normal;
  final StebCollectionsScraper _scraper;

  StandardEbooks({StebSearchMode? mode, StebCollectionsScraper? scraper})
      : mode = mode ?? StebSearchMode.normal,
        _scraper = scraper ?? StebCollectionsScraper();

  @override
  Future<List<SeriesModel>> search({required String query}) async {
    if (mode == StebSearchMode.collections) {
      // In collections (series) mode, search collections by name
      final collections = await _scraper.getCollections();
      final filtered = collections
          .where((c) =>
              c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return filtered.map((c) => SeriesModel(
            id: c.url,
            title: c.title,
            coverUrl: null,
            detailUrl: c.url,
          )).toList();
    }

    return _searchNormal(query);
  }

  Future<List<SeriesModel>> _searchNormal(String query) async {
    final books = await _scraper.searchBooks(query: query);
    final result = <SeriesModel>[];

    for (final book in books) {
      final downloadUrl = await _scraper.getDownloadLink(book.detailUrl);
      if (downloadUrl == null) continue;

      result.add(SeriesModel(
        id: book.detailUrl,
        title: book.title,
        coverUrl: book.coverUrl,
        detailUrl: downloadUrl,
      ));
    }

    return result;
  }

  @override
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    // Get all books in the collection
    final books = await _scraper.getCollectionBooks(collectionUrl: volumeUrl);
    final volumes = <VolumeInfo>[];

    for (final book in books) {
      final downloadUrl = await _scraper.getDownloadLink(book.detailUrl);
      volumes.add(VolumeInfo(
        id: book.detailUrl,
        label: book.title,
        chapterUrl: downloadUrl ?? book.detailUrl,
      ));
    }

    return volumes;
  }

  @override
  void download({required VolumeInfo volume}) {
    // Delegate to downloader
  }
}
