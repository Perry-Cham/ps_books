import './book_data.dart';

class SeriesModel extends DownloadBook {
  final String? id;
  @override
  final String title;
  final String? coverUrl;
  final String detailUrl;

  SeriesModel({
    this.id,
    required this.title,
    this.coverUrl,
    required this.detailUrl,
  }) : super(
    title: title,
    year: '',
    extension: 'epub',
    href: detailUrl,
    size: '',
    language: 'English',
    isbn: null,
    image: coverUrl,
  );

  @override
  String toString() => '[$id] $title';
}

class VolumeInfo {
  final String id;
  final String label;
  final String chapterUrl;
  final String? publishedAt;
  final String? parentSeriesId;

  const VolumeInfo({
    required this.id,
    required this.label,
    required this.chapterUrl,
    this.publishedAt,
    this.parentSeriesId,
  });

  @override
  String toString() => label;
}
