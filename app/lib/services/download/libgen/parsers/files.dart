import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:kindle_unpack/kindle_unpack.dart';
import 'package:path/path.dart' as p;
import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';

final String url = "https://libgen.li";
final List<String> mirrors = [
  "https://libgen.gs",
"https://libgen.la",
"https://libgen.vg",
"https://libgen.bz",
];
final _db = BookToDb();

class LibgenFilesScraper {
  static final Dio _dio = Dio();

  static Future<List<DownloadBook>?> search(String query) async {
    Response? response;

    try {
      response = await _dio.get(
        url,
        queryParameters: {
          'req': query,
          'columns[]': ['t', 'a', 's', 'y', 'p', 'i'],
          'objects[]': ['f', 'e', 's', 'a', 'p', 'w'],
          'topics[]': ['l', 'c', 'f', 'r', 's'],
          'res': 100,
          'filesuns': 'all',
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      for (var link in mirrors) {
        try {
          response = await _dio.get(
            link,
            queryParameters: {
              'req': query,
              'columns[]': ['t', 'a', 's', 'y', 'p', 'i'],
              'objects[]': ['f', 'e', 's', 'a', 'p', 'w'],
              'topics[]': ['l', 'c', 'f', 'r', 's'],
              'res': 100,
              'filesuns': 'all',
            },
          );
          if (response.statusCode == 200) break;
        } catch (mirrorError) {
          debugPrint("Failed on mirror $link: $mirrorError");
          continue; // Try the next mirror if this one fails
        }
      }
    }

    if (response == null) return null;

    final document = html.parse(response.data);
    final results = document.querySelectorAll("#tablelibgen tr");

    if (results.isEmpty) {
      print("Results are empty");
      return null;
    }

    final List<Map<String, dynamic>> bookMaps = [];
    for (var el in results) {
      final book = _convertToMap(el);
      if (book != null) {
        bookMaps.add(book);
      }
    }

    // Fetch download links in BATCHES to avoid rate limits and IP bans
    const int batchSize = 5;
    final List<DownloadBook> books = [];

    for (int i = 0; i < bookMaps.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, bookMaps.length);
      final batch = bookMaps.sublist(i, end);

      // Process the current batch in parallel
      final batchResults = await Future.wait(
        batch.map((book) async {
          String? href = book['href'];
          String? downloadLink;
          try {
            if (href != null && href.startsWith('/ads.php?')) {
              downloadLink = await _downloadPageScraper(href);
            } else if (href != null && href.isNotEmpty) {
              downloadLink = "$url$href";
            }
          } catch (e) {
            debugPrint("Failed to fetch download link for ${book['title']}: $e");
          }
          book['href'] = downloadLink;
          return DownloadBook.fromMap(book);
        }),
      );

      // Add successful results to the final list
      books.addAll(batchResults.whereType<DownloadBook>());

      // Optional: Add a small delay between batches to further avoid rate limits
      if (i + batchSize < bookMaps.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return books;
  }

  static Map<String, dynamic>? _convertToMap(dom.Element el) {
    List<dom.Element> data = el.querySelectorAll("td");
    if (data.isEmpty) return null;

    final bool isFileRow = data[0].attributes['colspan'] != null;

    if (isFileRow) {
      // Shape A: colspan title cell + pages/size/ext/mirrors
      if (data.length < 5) return null;

      final titleSpan = data[0].querySelector('span[data-toggle="tooltip"]');
      final title = titleSpan?.text.trim() ?? '';

      return {
        "title": title,
        "isbn": null,
        "year": "",
        "size": data[2].text.trim(),
        "extension": data[3].text.trim(),
        "href": data[4].querySelector("[title='libgen']")?.attributes['href'],
        "language": "",
      };
    } else {
      // Shape B: full 9-column "book/edition" row
      if (data.length < 9) return null;

      List<dom.Element> titles = data[0].querySelectorAll(
        "a[data-html='true']",
      );
      List<String> candidates = [];
      for (var el in titles) {
        var j = el.text.trim();
        if (j.isNotEmpty) candidates.add(j);
      }

      final String cellText = data[0].text;
      final isbnRegex = RegExp(r'\b\d{13}\b|\b\d{9}[\dXx]\b');
      final foundIsbns = isbnRegex
      .allMatches(cellText)
      .map((m) => m.group(0)!)
      .toList();

      return {
        "title": composeTitle(data[0], data[7]),
        "isbn": foundIsbns.isNotEmpty ? foundIsbns : null,
        "year": data[3].text.trim(),
        "size": data[6].text.trim(),
        "extension": data[7].text.trim(),
        "href": data[8].querySelector("[title='libgen']")?.attributes['href'],
        "language": data[4].text.trim(),
      };
    }
  }

  static Future<String?> _downloadPageScraper(String link) async {
    final response = await _dio.get("$url$link");

    final page = html.parse(response.data);
    final downloadLink = page.querySelector("#main a")?.attributes['href'];
    if (downloadLink != null) {
      return "$url/$downloadLink";
    }
    return null;
  }

  static Future<void> handleMobiDownload({
    required String savePath,
    required String filename,
    required Directory coversDir,
  }) async {
    try {
      final fileBytes = await File(savePath).readAsBytes();
      final book = KindleBook.fromBytes(fileBytes);
      final bookData = await processBook(
        fileBytes: fileBytes,
        fileName: filename,
        extension: 'mobi',
        coversDir: coversDir,
      );

      final booksDirPath = p.dirname(savePath);
      final convertedEpubPath = p.join(booksDirPath, "${bookData.title}.epub");

      await File(convertedEpubPath).writeAsBytes(book.toEpub());

      await _db.addBook(
        name: bookData.title,
        author: bookData.author,
        extension: 'epub',
        path: convertedEpubPath,
        coverPath: bookData.coverPath,
      );

      await File(savePath).delete();
    } catch (e) {
      print("Error converting MOBI to EPUB: $e");
      await _db.addBook(
        name: filename.split('.')[0],
        extension: 'mobi',
        path: savePath,
      );
    }
  }
}

String extractTitle(dom.Element titleCell) {
  // The "real" title is the data-html anchor that is NOT inside <b>
  // (the one inside <b> is the issue/volume tag, e.g. "#2 1994-mar").
  final allTitleAnchors = titleCell.querySelectorAll("a[data-html='true']");
  String title = '';
  for (final a in allTitleAnchors) {
    final insideBold = a.parent?.localName == 'b';
    final text = a.text.trim();
    if (!insideBold && text.isNotEmpty) {
      title = text;
      return title;
    }
  }

  // Fallback: if there's no anchor outside <b> (no separate real title),
  // use the series name from the first plain <a> in <b>, or the issue tag.
  if (title.isEmpty) {
    final seriesAnchor = titleCell.querySelector('b > a:not([data-html])');
    title = seriesAnchor?.text.trim() ?? '';
    return title;
  }
  title = allTitleAnchors.first.text.trim();
  return title;
}

String? extractIssue(dom.Element titleCell) {
  final allTitleAnchors = titleCell.querySelectorAll("a[data-html='true']");
  for (var text in allTitleAnchors) {
    if (text.parent?.localName == 'b') return text.text;
  }
  return null;
}

String composeTitle(dom.Element titleCell, dom.Element extensionCell) {
  final title = extractTitle(titleCell);
  String? issue;
  final comicsFormats = ["cbz", "cbr", "cbt"];
  if (comicsFormats.contains(extensionCell.text.trim())) {
    issue = extractIssue(titleCell);
  }
  if (issue == null) {
    return title;
  } else {
    return "$title: $issue";
  }
}
