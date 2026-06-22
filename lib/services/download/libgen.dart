import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:kindle_unpack/kindle_unpack.dart';
import 'package:path/path.dart' as p;
import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';

final String url = "https://libgen.gl";
final _db = BookToDb();

class LibgenScraper {
  static final Dio _dio = Dio();

  static Future<List<DownloadBook>?> search(String query) async {
    final response = await _dio.get(
      'https://libgen.gl/',
      queryParameters: {
        'req': query,
        'columns[]': ['t', 'a', 's', 'y', 'p', 'i'],
        'objects[]': ['f', 'e', 's', 'a', 'p', 'w'],
        'topics[]': ['l', 'c', 'f', 'r', 's'],
        'res': 100,
        'filesuns': 'all',
      },
    );
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
print(document.querySelector('#tablelibgen')!.outerHtml);
    // Fetch download links in parallel
    final books = await Future.wait(
      bookMaps.map((book) async {
        String href = book['href'];
        String? downloadLink;
        if(href.startsWith('/ads.php?')){
downloadLink = await _downloadPageScraper(href);
        }else{
          downloadLink = "$url${book['href']}";
        }
        book['href'] = downloadLink;
        return DownloadBook.fromMap(book);
      }),
    );

    return books.whereType<DownloadBook>().toList();
  }

  static Map<String, dynamic>? _convertToMap(Element el) {
    List<Element> data = el.querySelectorAll("td");
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
        "year": "",   // not present in this row shape; could regex from title/path
        "size": data[2].text.trim(),
        "extension": data[3].text.trim(),
        "href": data[4].querySelector("[title='libgen']")?.attributes['href'],
        "language": "",
      };
    } else {
      // Shape B: full 9-column "book/edition" row
      if (data.length < 9) return null;

      List<Element> titles = data[0].querySelectorAll("a[data-html='true']");
      List<String> candidates = [];
      for (var el in titles) {
        var j = el.text.trim();
        if (j.isNotEmpty) candidates.add(j);
      }

      final String cellText = data[0].text;
      final isbnRegex = RegExp(r'\b\d{13}\b|\b\d{9}[\dXx]\b');
      final foundIsbns = isbnRegex.allMatches(cellText).map((m) => m.group(0)!).toList();

      return {
        "title": candidates.isNotEmpty ? candidates[0] : "",
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
    print('$url$link');
    final response = await _dio.get("$url$link");
print("res r");
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
