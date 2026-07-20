import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

/// A single book found on Project Gutenberg.
class GutenbergBook {
  final String id;
  final String title;
  final String? author;
  final String? coverUrl;
  final String detailUrl;
  final String? downloadUrl;

  const GutenbergBook({
    required this.id,
    required this.title,
    this.author,
    this.coverUrl,
    required this.detailUrl,
    this.downloadUrl,
  });

  @override
  String toString() => '[$id] $title${author != null ? ' by $author' : ''}';
}

/// A collection (bookshelf) on Project Gutenberg.
class GutenbergCollection {
  final String id;
  final String title;
  final String url;

  const GutenbergCollection({
    required this.id,
    required this.title,
    required this.url,
  });

  @override
  String toString() => '[$id] $title';
}

/// Thrown when Gutenberg returns an unexpected response.
class GutenbergException implements Exception {
  final String message;
  final int? statusCode;
  const GutenbergException(this.message, {this.statusCode});

  @override
  String toString() =>
      'GutenbergException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// ─────────────────────────────────────────────────────────────
// HTTP Client
// ─────────────────────────────────────────────────────────────

Dio _createHttpClient({int timeoutSeconds = 30}) {
  return Dio(BaseOptions(
    connectTimeout: Duration(seconds: timeoutSeconds),
    receiveTimeout: Duration(seconds: timeoutSeconds),
    sendTimeout: Duration(seconds: timeoutSeconds),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
    },
    validateStatus: (status) => status != null && status < 500,
  ));
}

// ─────────────────────────────────────────────────────────────
// Parser — pure functions, exported for testing
// ─────────────────────────────────────────────────────────────

/// Parse the bookshelf index page at /ebooks/bookshelf/
/// Returns a list of all collections found in the "All Reading Lists" section.
List<GutenbergCollection> parseCollectionsPage(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final collections = <GutenbergCollection>[];

  // The "All Reading Lists" section has links like /ebooks/bookshelf/82
  final bookshelfLinks = document.querySelectorAll(
    'div.bookshelves a[href*="/ebooks/bookshelf/"]',
  );

  for (final link in bookshelfLinks) {
    final href = link.attributes['href'] ?? '';
    final title = link.attributes['title'] ?? link.text.trim();
    if (href.isEmpty || title.isEmpty) continue;

    // Extract the numeric ID from /ebooks/bookshelf/82
    final idMatch = RegExp(r'/ebooks/bookshelf/(\d+)').firstMatch(href);
    if (idMatch == null) continue;

    collections.add(GutenbergCollection(
      id: idMatch.group(1)!,
      title: title,
      url: href.startsWith('http')
          ? href
          : 'https://www.gutenberg.org$href',
    ));
  }

  return collections;
}

/// Parse a bookshelf page (e.g. /ebooks/bookshelf/82) or search results page.
/// Both use the same `<li class="booklink">` structure.
List<GutenbergBook> parseBookList(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final books = <GutenbergBook>[];

  for (final li in document.querySelectorAll('li.booklink')) {
    try {
      final link = li.querySelector('a.link');
      if (link == null) continue;

      final href = link.attributes['href'] ?? '';
      if (href.isEmpty) continue;

      // Extract book ID from /ebooks/1342
      final idMatch = RegExp(r'/ebooks/(\d+)').firstMatch(href);
      if (idMatch == null) continue;
      final id = idMatch.group(1)!;

      final titleSpan = link.querySelector('span.title');
      final subtitleSpan = link.querySelector('span.subtitle');
      final coverImg = link.querySelector('img.cover-thumb');

      final title = titleSpan?.text.trim() ?? '';
      if (title.isEmpty) continue;

      final author = subtitleSpan?.text.trim();
      final coverSrc = coverImg?.attributes['src'];
      final coverUrl = coverSrc != null
          ? (coverSrc.startsWith('http')
              ? coverSrc
              : 'https://www.gutenberg.org$coverSrc')
          : null;

      final detailUrl = href.startsWith('http')
          ? href
          : 'https://www.gutenberg.org$href';

      // Construct the direct epub download URL from the book ID.
      // Gutenberg provides: /ebooks/{id}.epub3.images (with images)
      // and /ebooks/{id}.epub.images (older format)
      final downloadUrl = 'https://www.gutenberg.org/ebooks/$id.epub3.images';

      books.add(GutenbergBook(
        id: id,
        title: title,
        author: author,
        coverUrl: coverUrl,
        detailUrl: detailUrl,
        downloadUrl: downloadUrl,
      ));
    } catch (e) {
      continue;
    }
  }

  return books;
}

// ─────────────────────────────────────────────────────────────
// Scraper
// ─────────────────────────────────────────────────────────────

class GutenbergScraper {
  late final Dio _dio;

  GutenbergScraper({Dio? dio}) : _dio = dio ?? _createHttpClient();

  /// Search for books matching [query].
  Future<List<GutenbergBook>> searchBooks({required String query}) async {
    try {
      final response = await _dio.get(
        'https://www.gutenberg.org/ebooks/search/',
        queryParameters: {'query': query},
      );
      return parseBookList(response.data);
    } on DioException catch (e) {
      throw GutenbergException(
        'Search request failed: ${e.type.name}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get all books in a collection (bookshelf).
  Future<List<GutenbergBook>> getCollectionBooks({
    required String collectionUrl,
  }) async {
    try {
      final url = collectionUrl.startsWith('http')
          ? collectionUrl
          : 'https://www.gutenberg.org$collectionUrl';
      final response = await _dio.get(url);
      return parseBookList(response.data);
    } on DioException catch (e) {
      throw GutenbergException(
        'Collection request failed: ${e.type.name}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get all available collections from the bookshelf index.
  Future<List<GutenbergCollection>> getCollections() async {
    try {
      final response = await _dio.get(
        'https://www.gutenberg.org/ebooks/bookshelf/',
      );
      return parseCollectionsPage(response.data);
    } on DioException catch (e) {
      throw GutenbergException(
        'Collections request failed: ${e.type.name}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}
