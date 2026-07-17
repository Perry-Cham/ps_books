class ComicBook{
  /// Site-specific manga identifier (e.g. "01J76XY7E9FNDZ1DBBM6PBJPFK").
  final String? id;

  /// Human-readable manga/comic title.
  final String title;

  /// URL of the cover art thumbnail.
  final String? coverUrl;

  /// URL of the manga's detail page (where chapter list lives).
  final String detailUrl;

  const ComicBook({
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
