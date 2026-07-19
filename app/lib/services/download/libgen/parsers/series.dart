import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

// ============================================
// DATA MODELS
// ============================================

class BookResult {
  final String title;
  final String publishingPeriod;
  final String publisher;
  final String language;
  final String detailUrl;
  final String? coverImageUrl;

  const BookResult({
    required this.title,
    required this.publishingPeriod,
    required this.publisher,
    required this.language,
    required this.detailUrl,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'publishing_period': publishingPeriod,
    'publisher': publisher,
    'language': language,
    'detail_url': detailUrl,
    'cover_image_url': coverImageUrl,
  };
}

/// Represents a single issue/edition in a series
class Issue {
  final String editionId;
  final String? year;
  final String? issueNumber;
  final String? title;
  final String? authors;
  final String? publisher;
  final String? coverImageUrl;
  final String editionUrl;

  const Issue({
    required this.editionId,
    this.year,
    this.issueNumber,
    this.title,
    this.authors,
    this.publisher,
    this.coverImageUrl,
    required this.editionUrl,
  });

  @override
  String toString() => 'Issue #$issueNumber (ID: $editionId)';

  Map<String, dynamic> toJson() => {
    'edition_id': editionId,
    'year': year,
    'issue_number': issueNumber,
    'title': title,
    'authors': authors,
    'publisher': publisher,
    'cover_image_url': coverImageUrl,
    'edition_url': editionUrl,
  };
}

/// Represents a single file variant for an edition
class FileVariant {
  final String md5;
  final String size;
  final String extension;
  final String? pages;
  final String? coverInfo;
  final String? scanType;
  final String? releaser;
  final String? dpi;
  final String downloadUrl;
  final String? description;

  const FileVariant({
    required this.md5,
    required this.size,
    required this.extension,
    this.pages,
    this.coverInfo,
    this.scanType,
    this.releaser,
    this.dpi,
    required this.downloadUrl,
    this.description,
  });

  @override
  String toString() => '$extension ($size) - $releaser';

  Map<String, dynamic> toJson() => {
    'md5': md5,
    'size': size,
    'extension': extension,
    'pages': pages,
    'cover_info': coverInfo,
    'scan_type': scanType,
    'releaser': releaser,
    'dpi': dpi,
    'download_url': downloadUrl,
    'description': description,
  };
}

class ScrapingException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  const ScrapingException(this.message, {this.statusCode, this.originalError});
  @override
  String toString() => 'ScrapingException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// ============================================
// HTTP CLIENT
// ============================================

Dio createHttpClient({int timeoutSeconds = 30}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: timeoutSeconds),
      receiveTimeout: Duration(seconds: timeoutSeconds),
      sendTimeout: Duration(seconds: timeoutSeconds),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Referer': 'https://libgen.li/',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );
  return dio;
}

// ============================================
// SCRAPER
// ============================================

class LibGenScraper {
  late final Dio _dio;
  LibGenScraper() { _dio = createHttpClient(); }

  Future<List<BookResult>> searchBooks({
    required String query,
    int resultsLimit = 100,
  }) async {
    try {
      print('🔍 Searching for: "$query"');
      final response = await _dio.get(
        'https://libgen.li/index.php',
        queryParameters: {
          'req': query,
          'columns[]': ['t', 'a', 's', 'y', 'p', 'i'],
          'objects[]': ['f', 'e', 's', 'a', 'p', 'w'],
          'topics[]': ['l', 'c', 'f', 'r', 's'],
          'res': resultsLimit,
          'filesuns': 'all',
          'curtab': 's',
        },
      );
      return _parseSearchResults(response.data);
    } on DioException catch (e) {
      throw ScrapingException('Network request failed: ${e.type.name}', statusCode: e.response?.statusCode, originalError: e);
    }
  }

  /// Get list of issues from a series page
  Future<List<Issue>> getIssueList({required String detailUrl}) async {
    final url = detailUrl.startsWith('http') ? detailUrl : 'https://libgen.li/$detailUrl';
    print('📚 Fetching series from: $url');

    try {
      final response = await _dio.get(url, queryParameters: {'viewmode': 'list'});
      return _parseIssueList(response.data);
    } on DioException catch (e) {
      throw ScrapingException('Failed to fetch series: ${e.type.name}', statusCode: e.response?.statusCode, originalError: e);
    }
  }

  /// Get file variants from an edition page
  Future<List<FileVariant>> getFileVariants({required String editionUrl}) async {
    final url = editionUrl.startsWith('http') ? editionUrl : 'https://libgen.li/$editionUrl';
    print('📖 Fetching edition from: $url');

    try {
      final response = await _dio.get(url);
      return _parseFileVariants(response.data);
    } on DioException catch (e) {
      throw ScrapingException('Failed to fetch edition: ${e.type.name}', statusCode: e.response?.statusCode, originalError: e);
    }
  }

  // ============================================
  // PARSERS
  // ============================================

  List<BookResult> _parseSearchResults(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final table = document.querySelector('#tablelibgen');
    if (table == null) {
      throw const ScrapingException('Results table not found');
    }

    final rows = table.querySelectorAll('tbody > tr');
    print('📊 Found ${rows.length} results');

    final results = <BookResult>[];
    for (final row in rows) {
      try {
        final cells = row.querySelectorAll('td');
        if (cells.length < 4) continue;

        final titleCell = cells[0];
        final linkElement = titleCell.querySelector("a[data-toggle='tooltip']");

        results.add(BookResult(
          title: titleCell.text.trim(),
          publishingPeriod: cells[1].text.trim(),
          publisher: cells[2].text.trim(),
          language: cells[3].text.trim(),
          detailUrl: linkElement?.attributes['href'] ?? '',
          coverImageUrl: "",
        ));
      } catch (e) {
        print('⚠️  Error parsing row: $e');
        continue;
      }
    }
    return results;
  }

  /// Parse series.php page — returns list of issues
  List<Issue> _parseIssueList(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final rows = document.querySelectorAll('#tablelibgen tbody > tr');

    print('📖 Found ${rows.length} issues');

    final issues = <Issue>[];
    for (final row in rows) {
      try {
        final cells = row.querySelectorAll('td');
        if (cells.isEmpty) continue;

        // Cell 0: Green status cell with link to edition.php
        final statusCell = cells[0];
        final editionLink = statusCell.querySelector('a')?.attributes['href'] ?? '';
        final editionId = _extractIdFromUrl(editionLink);

        // Cell 1: Cover image
        final coverImg = cells.length > 1
        ? cells[1].querySelector('img')?.attributes['src']
        : null;

        // Cell 2: Year
        final year = cells.length > 2 ? cells[2].text.trim() : null;

        // Cell 4: Total number (issue number)
        final issueNum = cells.length > 4 ? cells[4].text.trim() : null;

        // Cell 7: Title
        final title = cells.length > 7 ? cells[7].text.trim() : null;

        // Cell 8: Authors
        final authors = cells.length > 8 ? cells[8].text.trim() : null;

        // Cell 9: Publisher
        final publisher = cells.length > 9 ? cells[9].text.trim() : null;

        issues.add(Issue(
          editionId: editionId,
          year: year,
          issueNumber: issueNum,
          title: title,
          authors: authors,
          publisher: publisher,
          coverImageUrl: coverImg,
          editionUrl: editionLink,
        ));
      } catch (e) {
        print('⚠️  Error parsing issue row: $e');
        continue;
      }
    }
    return issues;
  }

  /// Parse edition.php page — returns list of file variants
  List<FileVariant> _parseFileVariants(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final rows = document.querySelectorAll('#tablelibgen tbody > tr');

    print('📁 Found ${rows.length} file variants');

    final variants = <FileVariant>[];
    for (final row in rows) {
      try {
        final cells = row.querySelectorAll('td');
        if (cells.length < 2) continue;

        // Cell 0: Cover thumbnail with link to ads.php?md5=...
        final coverCell = cells[0];
        final md5Link = coverCell.querySelector('a')?.attributes['href'] ?? '';
        final md5 = _extractMd5FromUrl(md5Link);

        // Cell 1: Metadata and download links
        final metaCell = cells[1];

        // Parse the text content for metadata
        final textContent = metaCell.text;

        // Extract fields using regex patterns
        final size = _extractField(textContent, r'Size:\s*([^\n]+)');
        final extension = _extractField(textContent, r'Extension:\s*(\w+)');
        final pages = _extractField(textContent, r'Pages:\s*(\d+)');
        final coverInfo = _extractField(textContent, r'Cover info:\s*([^\n]+)');
        final scanType = _extractField(textContent, r'Scan type:\s*([^\n]+)');
        final releaser = _extractField(textContent, r'Releaser:\s*([^\n]+)');
        final dpi = _extractField(textContent, r'DPI:\s*([^\n]+)');

        // Find the libgen download link
        final libgenLink = metaCell.querySelector('a[data-original-title="libgen"]')?.attributes['href'] ?? '';
        final downloadUrl = libgenLink.startsWith('/') ? 'https://libgen.li$libgenLink' : libgenLink;

        // Description from the silver text
        final description = metaCell.querySelector('font[color="silver"]')?.text.trim();

        variants.add(FileVariant(
          md5: md5,
          size: size ?? 'Unknown',
          extension: extension ?? 'Unknown',
          pages: pages,
          coverInfo: coverInfo,
          scanType: scanType,
          releaser: releaser,
          dpi: dpi,
          downloadUrl: downloadUrl,
          description: description,
        ));
      } catch (e) {
        print('⚠️  Error parsing file variant: $e');
        continue;
      }
    }
    return variants;
  }

  // ============================================
  // HELPERS
  // ============================================

  String _extractIdFromUrl(String url) {
    final match = RegExp(r'id=(\d+)').firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _extractMd5FromUrl(String url) {
    final match = RegExp(r'md5=([a-f0-9]+)').firstMatch(url);
    return match?.group(1) ?? '';
  }

  String? _extractField(String text, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
    return match?.group(1)?.trim();
  }

  void dispose() {
    _dio.close(force: true);
  }
}

// ============================================
// MAIN
// ============================================

void main() async {
  print('🚀 LibGen Educational Scraper Starting...\n');

  final scraper = LibGenScraper();

  try {
    // Step 1: Search
    final books = await scraper.searchBooks(
      query: "Old Man Logan",
      resultsLimit: 25,
    );

    if (books.isEmpty) {
      print('😔 No results found');
      return;
    }

    print('\n📚 SEARCH RESULTS:');
    print('=' * 50);
    for (var i = 0; i < books.length.clamp(0, 5); i++) {
      final book = books[i];
      print('${i + 1}. ${book.title}');
      print('   Publisher: ${book.publisher} | Lang: ${book.language}');
      print('   URL: ${book.detailUrl}\n');
    }

    // Step 2: Get issues from first result
    if (books.first.detailUrl.isNotEmpty) {
      print('\n🔄 Fetching issue list for: "${books.first.title}"...');

      final issues = await scraper.getIssueList(
        detailUrl: books.first.detailUrl,
      );

      if (issues.isNotEmpty) {
        print('\n📖 ISSUES FOUND: ${issues.length}');
        print('-' * 50);
        for (final issue in issues) {
          print('Issue #${issue.issueNumber} (${issue.year}) - ID: ${issue.editionId}');
        }

        // Step 3: Get file variants for the first issue
        print('\n📁 Fetching file variants for Issue #${issues.first.issueNumber}...');
        final variants = await scraper.getFileVariants(
          editionUrl: issues.first.editionUrl,
        );

        print('\n💾 FILE VARIANTS: ${variants.length}');
        print('-' * 50);
        for (final variant in variants) {
          print('${variant.extension} | ${variant.size} | ${variant.releaser}');
          print('   Download: ${variant.downloadUrl}');
          print('   ${variant.description ?? ""}');
          print('');
        }
      } else {
        print('ℹ️  No issues found');
      }
    }

  } on ScrapingException catch (e) {
    print('\n💥 Scraping failed: $e');
  } catch (e) {
    print('\n💥 Unexpected error: $e');
  } finally {
    scraper.dispose();
    print('\n✅ Done!');
  }
}
