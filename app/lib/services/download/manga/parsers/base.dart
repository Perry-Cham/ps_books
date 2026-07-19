// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
//
// DISCLAIMER:
//   This project is strictly for educational purposes. It teaches HTTP
//   scraping, HTML parsing, and modular parser design. All manga,
//   characters, artwork, and trademarks belong to their rightful rights
//   holders. Do NOT use this code to download content you do not have
//   the legal right to access. Support official releases whenever
//   possible.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/parsers/base.dart — The parser contract.
//
// Direct port of `src/parsers/base.js` from the Node.js version. Dart
// has real abstract classes (unlike JavaScript's "throw on call"
// pattern), so this is a true abstract class with abstract methods.
//
// To add a new parser:
//   1. Create `lib/parsers/mysite.dart` extending BaseParser.
//   2. Register it in `lib/parsers/registry.dart`.
//   3. Done — the UI reads from the registry.
// -----------------------------------------------------------------------------

/// A single search result returned by [BaseParser.search].
class MangaSearchResult {
  /// Site-specific manga identifier (e.g. "01J76XY7E9FNDZ1DBBM6PBJPFK").
  final String id;

  /// Human-readable manga title.
  final String title;

  /// URL of the cover art thumbnail.
  final String coverUrl;

  /// URL of the manga's detail page (where chapter list lives).
  final String detailUrl;

  const MangaSearchResult({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.detailUrl,
  });

  @override
  String toString() => '[$id] $title';
}

/// A single chapter in a manga's chapter list.
class ChapterInfo {
  /// Site-specific chapter identifier.
  final String id;

  /// Display label, e.g. "Chapter 1187".
  final String label;

  /// URL of the chapter reader page.
  final String chapterUrl;

  /// ISO timestamp of when the chapter was released, if available.
  final String? publishedAt;

  const ChapterInfo({
    required this.id,
    required this.label,
    required this.chapterUrl,
    this.publishedAt,
  });

  @override
  String toString() => label;
}

/// Abstract base class for all site parsers.
///
/// Subclasses MUST override every member. The Dart analyzer enforces
/// this at compile time — unlike the JS version which throws at
/// runtime, the Dart version fails to build if a method is missing.
abstract class BaseParser {
  /// A short, lowercase identifier used in config — e.g. "weebcentral".
  String get key;

  /// A human-readable name shown in the UI — e.g. "Weeb Central".
  String get displayName;

  /// Search the site for manga matching [query].
  Future<List<MangaSearchResult>> search(String query);

  /// Fetch the list of chapters for a given manga.
  Future<List<ChapterInfo>> getChapters({required String detailUrl});

  /// Fetch the list of image URLs for a given chapter, in reading order.
  Future<List<String>> getChapterImages(ChapterInfo chapter);
}
