// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/services/download_service.dart — Orchestrate a chapter download.
//
// Direct port of `src/services/downloadService.js`. Same flow:
//   1. Call the parser to get image URLs.
//   2. Fetch each image's bytes.
//   3. Either write them as .jpg files OR pack into a .cbz.
//
// The Dart version uses async/await + Future.wait for parallelism,
// matching the JS version's Promise.all approach.
// -----------------------------------------------------------------------------

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../parsers/base.dart';
import 'cbz_service.dart';

const String _kUserAgent =
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Safari/537.36';

/// Result of a chapter download.
class DownloadResult {
  final int pages;
  final String outputPath;
  const DownloadResult({required this.pages, required this.outputPath});
}

/// Download a single chapter via the given parser.
///
/// Mirrors downloadChapter() in downloadService.js. The [onProgress]
/// callback is fired after each image is fetched — same as the JS
/// version's progress hook.
Future<DownloadResult> downloadChapter({
  required BaseParser parser,
  required ChapterInfo chapter,
  required String outputDir,
  required String format, // 'img' or 'cbz'
  void Function(int downloaded, int total)? onProgress,
}) async {
  // 1. Get image URLs from the parser.
  final imageUrls = await parser.getChapterImages(chapter);
  if (imageUrls.isEmpty) {
    throw Exception('No images found for chapter ${chapter.label}');
  }

  // 2. Fetch each image's bytes in parallel.
  final bytesList = await Future.wait(
    imageUrls.asMap().entries.map((entry) async {
      final i = entry.key;
      final url = entry.value;
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _kUserAgent,
          'Referer': chapter.chapterUrl,
        },
      );
      if (res.statusCode != 200) {
        throw Exception('GET $url returned HTTP ${res.statusCode}');
      }
      onProgress?.call(i + 1, imageUrls.length);
      return Uint8List.fromList(res.bodyBytes);
    }),
  );

  // 3. Sanitize the chapter label for use as a filename.
  final safeName = chapter.label
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // 4. Either write images to disk or pack a CBZ.
  if (format == 'img') {
    final chapterDir = p.join(outputDir, safeName);
    await Directory(chapterDir).create(recursive: true);
    final filenames = pageFilenames(bytesList.length);
    await Future.wait(
      bytesList.asMap().entries.map((e) async {
        final path = p.join(chapterDir, filenames[e.key]);
        await File(path).writeAsBytes(e.value);
      }),
    );
    return DownloadResult(pages: bytesList.length, outputPath: chapterDir);
  }

  // CBZ mode.
  final filenames = pageFilenames(bytesList.length);
  final pages = bytesList
      .asMap()
      .entries
      .map((e) => CbzPage(data: e.value, filename: filenames[e.key]))
      .toList();
  final outputPath = p.join(outputDir, '$safeName.cbz');
  await packCbz(pages, outputPath);
  return DownloadResult(pages: bytesList.length, outputPath: outputPath);
}
