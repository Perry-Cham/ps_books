import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comic_reader/src/widgets/comic_viewer.dart';
import 'package:comic_reader/src/models/comic_model.dart';

void main() {
  testWidgets('ComicViewer responds to arrow keys', (WidgetTester tester) async {
    // Setup mock data
    final tempDir = await Directory.systemTemp.createTemp('comic_viewer_test');
    final page1 = File('${tempDir.path}/page1.jpg');
    await page1.writeAsBytes([0]);
    final page2 = File('${tempDir.path}/page2.jpg');
    await page2.writeAsBytes([0]);

    final comic = ComicModel(
      comicPages: [page1.path, page2.path],
      comicName: 'Test Comic',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ComicViewer(comic: comic),
      ),
    );

    // Initial page should be 0
    expect(find.text('Page 1 of 2'), findsOneWidget);

    // Press right arrow
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    // Should be on page 2
    expect(find.text('Page 2 of 2'), findsOneWidget);

    // Press left arrow
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    // Should be back on page 1
    expect(find.text('Page 1 of 2'), findsOneWidget);
    
    // Clean up
    await tempDir.delete(recursive: true);
  });

  testWidgets('ComicViewer responds to space key', (WidgetTester tester) async {
    // Setup mock data
    final tempDir = await Directory.systemTemp.createTemp('comic_viewer_test_space');
    final page1 = File('${tempDir.path}/page1.jpg');
    await page1.writeAsBytes([0]);
    final page2 = File('${tempDir.path}/page2.jpg');
    await page2.writeAsBytes([0]);

    final comic = ComicModel(
      comicPages: [page1.path, page2.path],
      comicName: 'Test Comic',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ComicViewer(comic: comic),
      ),
    );

    // Initial page should be 0
    expect(find.text('Page 1 of 2'), findsOneWidget);

    // Press space key
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    // Should be on page 2
    expect(find.text('Page 2 of 2'), findsOneWidget);
    
    // Clean up
    await tempDir.delete(recursive: true);
  });
}
