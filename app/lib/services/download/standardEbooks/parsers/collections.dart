import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

/// A collection from standardebooks.org/collections
class StebCollection {
  final String title;
  final String url;

  const StebCollection({required this.title, required this.url});

  @override
  String toString() => title;
}

// ─────────────────────────────────────────────────────────────
// Parser — pure functions, exported for testing
// ─────────────────────────────────────────────────────────────

/// Parse the /collections page to get all available collections.
List<StebCollection> parseCollectionsPage(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final collections = <StebCollection>[];

  // Collection links are in <a href="/collections/...">
  for (final a in document.querySelectorAll('a[href^="/collections/"]')) {
    final href = a.attributes['href'] ?? '';
    final title = a.text.trim();
    if (href.isEmpty || title.isEmpty) continue;

    collections.add(StebCollection(
      title: title,
      url: href.startsWith('http') ? href : 'https://standardebooks.org$href',
    ));
  }

  return collections;
}

/// Parse the /collections/<name> page to get books in that collection.
/// The page uses the same structure as the main ebooks page:
/// ol.ebooks-list li[typeof='schema:Book']
List<StebBookEntry> parseCollectionBooks(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final books = <StebBookEntry>[];

  for (final el in document.querySelectorAll(
    "ol.ebooks-list li[typeof='schema:Book']",
  )) {
    final titleEl = el.querySelector("p a span[property='schema:name']");
    final authorEl = el.querySelector(
      "p.author a span[property='schema:name']",
    );

    String title = titleEl?.text.trim() ?? 'Unknown Title';
    String author = '';
    if (authorEl != null) {
      author = authorEl.text.trim();
      title = '$title - $author';
    }

    final linkEl = el.querySelector("a[property='schema:url']");
    final detailPath = linkEl?.attributes['href'];
    if (detailPath == null) continue;
    final detailUrl = detailPath.startsWith('http')
        ? detailPath
        : 'https://standardebooks.org$detailPath';

    final imageEl = el.querySelector("img[property='schema:image']");
    final imagePath = imageEl?.attributes['src'];
    final imageUrl = imagePath != null
        ? (imagePath.startsWith('http')
            ? imagePath
            : 'https://standardebooks.org$imagePath')
        : null;

    books.add(StebBookEntry(
      title: title,
      author: author,
      detailUrl: detailUrl,
      coverUrl: imageUrl,
    ));
  }

  return books;
}

/// Parse the /ebooks search page (normal mode).
List<StebBookEntry> parseSearchResults(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final books = <StebBookEntry>[];

  for (final el in document.querySelectorAll(
    "ol.ebooks-list li[typeof='schema:Book']",
  )) {
    final titleEl = el.querySelector("p a span[property='schema:name']");
    final authorEl = el.querySelector(
      "p.author a span[property='schema:name']",
    );

    String title = titleEl?.text.trim() ?? 'Unknown Title';
    String author = '';
    if (authorEl != null) {
      author = authorEl.text.trim();
      title = '$title - $author';
    }

    final linkEl = el.querySelector("a[property='schema:url']");
    final detailPath = linkEl?.attributes['href'];
    if (detailPath == null) continue;
    final detailUrl = detailPath.startsWith('http')
        ? detailPath
        : 'https://standardebooks.org$detailPath';

    final imageEl = el.querySelector("img[property='schema:image']");
    final imagePath = imageEl?.attributes['src'];
    final imageUrl = imagePath != null
        ? (imagePath.startsWith('http')
            ? imagePath
            : 'https://standardebooks.org$imagePath')
        : null;

    books.add(StebBookEntry(
      title: title,
      author: author,
      detailUrl: detailUrl,
      coverUrl: imageUrl,
    ));
  }

  return books;
}

class StebBookEntry {
  final String title;
  final String author;
  final String detailUrl;
  final String? coverUrl;

  const StebBookEntry({
    required this.title,
    required this.author,
    required this.detailUrl,
    this.coverUrl,
  });
}

// ─────────────────────────────────────────────────────────────
// Scraper
// ─────────────────────────────────────────────────────────────

class StebCollectionsScraper {
  final Dio _dio;

  StebCollectionsScraper({Dio? dio}) : _dio = dio ?? Dio();

  static const String baseUrl = 'https://standardebooks.org';

  /// Search for books matching [query] (normal mode).
  Future<List<StebBookEntry>> searchBooks({required String query}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/ebooks',
        queryParameters: {'query': query},
      );
      return parseSearchResults(response.data);
    } catch (e) {
      print('Error searching Standard Ebooks: $e');
      return [];
    }
  }

  /// Get all collections from /collections.
  Future<List<StebCollection>> getCollections() async {
    try {
      final response = await _dio.get('$baseUrl/collections');
      return parseCollectionsPage(response.data);
    } catch (e) {
      print('Error fetching Standard Ebooks collections: $e');
      return [];
    }
  }

  /// Get all books in a collection.
  Future<List<StebBookEntry>> getCollectionBooks({
    required String collectionUrl,
  }) async {
    try {
      final url = collectionUrl.startsWith('http')
          ? collectionUrl
          : '$baseUrl$collectionUrl';
      final response = await _dio.get(url);
      return parseCollectionBooks(response.data);
    } catch (e) {
      print('Error fetching Standard Ebooks collection: $e');
      return [];
    }
  }

  /// Get the download link for a specific book from its detail page.
  Future<String?> getDownloadLink(String detailUrl) async {
    try {
      final response = await _dio.get(detailUrl);
      final document = html_parser.parse(response.data);
      final link = document.querySelector(
        "a.epub[property='schema:contentUrl']",
      );
      if (link != null) {
        final href = link.attributes['href'];
        return href!.startsWith('http')
            ? href
            : '$baseUrl$href?source=download';
      }
    } catch (e) {
      print('Error fetching detail page $detailUrl: $e');
    }
    return null;
  }

  void dispose() {
    _dio.close(force: true);
  }
}
