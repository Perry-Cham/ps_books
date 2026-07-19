import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/routes/homeComp/series_view.dart';
import 'package:ps_books/routes/downloadComp/comics/series_download_view.dart';

void main() {
  group('SeriesViewHome', () {
    testWidgets('renders series name in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SeriesViewHome(
            series: Sery(
              id: 1,
              name: 'Test Series',
              cover: null,
              description: 'Description',
              collection: null,
            ),
          ),
        ),
      );

      expect(find.text('Test Series'), findsOneWidget);
    });
  });

  group('SeriesDownloadView', () {
    testWidgets('renders series title', (tester) async {
      final seriesModel = SeriesModel(
        id: '1',
        title: 'Download Series',
        coverUrl: null,
        detailUrl: 'https://example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SeriesDownloadView(
            seriesModel: seriesModel,
            volumes: [],
          ),
        ),
      );

      expect(find.text('Download Series'), findsOneWidget);
    });

    testWidgets('shows volume count', (tester) async {
      final seriesModel = SeriesModel(
        id: '1',
        title: 'Series',
        coverUrl: null,
        detailUrl: 'https://example.com',
      );

      final volumes = [
        VolumeInfo(id: '1', label: 'Chapter 1', chapterUrl: 'https://example.com/1'),
        VolumeInfo(id: '2', label: 'Chapter 2', chapterUrl: 'https://example.com/2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SeriesDownloadView(
            seriesModel: seriesModel,
            volumes: volumes,
          ),
        ),
      );

      expect(find.text('2 volumes'), findsOneWidget);
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);
    });

    testWidgets('shows volume list tiles', (tester) async {
      final seriesModel = SeriesModel(
        id: '1',
        title: 'Series',
        coverUrl: null,
        detailUrl: 'https://example.com',
      );

      final volumes = [
        VolumeInfo(id: '1', label: 'Issue 1', chapterUrl: 'https://example.com/1'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SeriesDownloadView(
            seriesModel: seriesModel,
            volumes: volumes,
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
