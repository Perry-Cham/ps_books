import 'package:flutter_test/flutter_test.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/models/downloader_models.dart';
import 'package:ps_books/services/download/downloader.dart';
import 'package:ps_books/services/download/libgen/exported.dart' as libgen;
import 'package:ps_books/services/download/standardEbooks/exported.dart' as steb;
import 'package:ps_books/services/download/manga/exported.dart' as manga;

void main() {
  group('SeriesCapable interface', () {
    test('libgen implements SeriesCapable', () {
      final instance = libgen.Libgen();
      expect(instance, isA<SeriesCapable>());
    });

    test('standard ebooks implements SeriesCapable', () {
      final instance = steb.StandardEbooks();
      expect(instance, isA<SeriesCapable>());
    });

    test('manga implements SeriesCapable', () {
      final instance = manga.MangaDownloader();
      expect(instance, isA<SeriesCapable>());
    });
  });

  group('SearchBooks', () {
    test('returns empty list for unknown provider', () async {
      final result = await SearchBooks('query', 'unknown');
      expect(result, isEmpty);
    });
  });

  group('SeriesModel', () {
    test('creates SeriesModel with correct values', () {
      final model = SeriesModel(
        id: '123',
        title: 'Test Book',
        coverUrl: 'https://example.com/cover.jpg',
        detailUrl: 'https://example.com/book',
      );

      expect(model.id, equals('123'));
      expect(model.title, equals('Test Book'));
      expect(model.coverUrl, equals('https://example.com/cover.jpg'));
      expect(model.detailUrl, equals('https://example.com/book'));
      expect(model.extension, equals('epub'));
    });
  });

  group('VolumeInfo', () {
    test('creates VolumeInfo with correct values', () {
      final volume = VolumeInfo(
        id: 'ch1',
        label: 'Chapter 1',
        chapterUrl: 'https://example.com/ch1',
      );

      expect(volume.id, equals('ch1'));
      expect(volume.label, equals('Chapter 1'));
      expect(volume.chapterUrl, equals('https://example.com/ch1'));
    });
  });

  group('SearchMode', () {
    test('libgen defaults to files search mode', () {
      final instance = libgen.Libgen();
      expect(instance.mode, equals(libgen.SearchMode.files));
    });

    test('libgen can be set to series search mode', () {
      final instance = libgen.Libgen(mode: libgen.SearchMode.series);
      expect(instance.mode, equals(libgen.SearchMode.series));
    });

    test('standard ebooks defaults to normal mode', () {
      final instance = steb.StandardEbooks();
      expect(instance.mode, equals(steb.StebSearchMode.normal));
    });
  });

  group('DownloadProvider routing', () {
    test('GetVolumes returns empty for unknown provider', () async {
      final result = await GetVolumes('unknown', 'https://example.com', series: false);
      expect(result, isEmpty);
    });
  });
}
