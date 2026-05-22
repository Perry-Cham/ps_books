import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import "package:html/parser.dart" as html;
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/helpers/book_processor.dart';

final String url = "https://libgen.gl";
final _db = BookToDb();

class DownloadBook {
  final String title;
  final String year;
  final String extension;
  final String href;
  final String size;
  List<String>? isbn;
final String language;
  DownloadBook({
    required this.title,
    required this.year,
    required this.extension,
    required this.href,
    required this.size,
    required this.language,
    required this.isbn
  });

  static DownloadBook? fromMap(Map<String, dynamic> book) {
  //  print(book['href']);
    String ext = (book['extension'] ?? "").toString().toLowerCase();
    if ((ext != "pdf" && ext != "epub" && ext != "fb2") || book['href'] == null) {
      return null;
    } else {
      return DownloadBook(
        extension: book['extension'],
        year: book['year'],
        title: book['title'],
        href: book['href'],
        size: book['size'],
        isbn:book['isbn'],
        language: book['language']
      );
    }
  }
}

Future<dynamic> SearchBooks(String query) async {
  print("this is");
  print(query);
  final dio = Dio();
  final response = await dio.get(
    'https://libgen.gl/index.php',
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
  List<Map<String, dynamic>> bookMaps = [];
  List<DownloadBook> books = [];

  for (var el in results) {
    final book = convertToMap(el);
    if (book != null) {
      bookMaps.add(book);
    }
  }

  //convert book maps to proper objects
  for (var book in bookMaps) {
    var j = DownloadBook.fromMap(book);
    if (j != null) {
      books.add(j);
    }
  }
  //print(bookMaps);
  return books;
}

Map<String, dynamic>? convertToMap(Element el) {
  List<Element> data = el.querySelectorAll("td");
  if (data.isEmpty) return null;

  List<Element> titles = data[0].querySelectorAll("a[data-html='true']");
  List<String> candidates = [];
  for (var el in titles) {
    var j = el.text.trim();
    if (j == '') {
      continue;
    } else {
      candidates.add(j);
    }
  }

//LOGIC TO GET ISBN
// 1. Grab ALL text from the first column cell
  final String cellText = data[0].text;

  // 2. Define the ISBN Regex
  // \b\d{13}\b     -> Matches standalone 13-digit numbers (ISBN-13)
  // \b\d{9}[\dXx]\b -> Matches standalone 10-digit combinations ending in a digit or X (ISBN-10)
  final isbnRegex = RegExp(r'\b\d{13}\b|\b\d{9}[\dXx]\b');

  // 3. Extract all matches out of the garbage text
  final Iterable<RegExpMatch> matches = isbnRegex.allMatches(cellText);
  final List<String> foundIsbns = matches.map((m) => m.group(0)!).toList();


  print(candidates[0]);
  print(foundIsbns);
  return {
    "title": candidates[0],
    "isbn": foundIsbns.isNotEmpty ? foundIsbns : null,
    "year": data[3].text,
    "size": data[6].text,
    "extension": data[7].text,
    "href": data[8].querySelector("[title='libgen']")?.attributes['href'],
    "language":data[4].text
  };
}

Future<String?> downloadPageScraper(String link) async {
  final dio = Dio();
  print(link);
  final response = await dio.get("$url$link");
  final page = html.parse(response.data);
  final downloadLink = page.querySelector("#main a")!.attributes['href'];
  print("$url/$downloadLink");

  if (downloadLink != null) {
    return "$url/$downloadLink";
  } else {
    return null;
  }
}

Stream<double> downloadBookWithProgress(String url) async* {
  final dio = Dio();
  final controller = StreamController<double>();
  final d = await getApplicationDocumentsDirectory();
  final supportDir = await getApplicationSupportDirectory();
  final CoversDir = Directory("${supportDir.path}/Covers");
  await CoversDir.create(recursive: true);

  String filename = await getFileName(url);
  String savePath = "${d.path}/Books/$filename";

  try {
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // Calculate percentage and push to stream
          double progress = received / total;
          controller.add(progress);
        }
      },
    );
  } finally {
    controller.close();
    String extension = filename.split('.').last.toLowerCase();
    
    if (['pdf', 'epub', 'fb2'].contains(extension)) {
      final fileBytes = await File(savePath).readAsBytes();
      final bookData = await processBook(
        fileBytes: fileBytes,
        fileName: filename,
        extension: extension,
        coversDir: CoversDir,
      );

      await _db.addBook(
        name: bookData.title,
        author: bookData.author,
        extension: extension,
        path: savePath,
        page: extension == 'pdf' ? 1 : null,
        coverPath: bookData.coverPath,
      );
    } else {
      await _db.addBook(
        name: filename.split('.')[0],
        extension: extension,
        path: savePath,
      );
    }
  }

  // yield* allows us to return the stream directly from the controller
  yield* controller.stream;
}

Future<String> getFileName(String url) async {
  final dio = Dio();
  // We use a HEAD request to get metadata without downloading the whole file
  final response = await dio.head(url);

  // Look for the 'content-disposition' header
  final contentDisposition = response.headers.value('content-disposition');

  if (contentDisposition != null && contentDisposition.contains('filename=')) {
    // This regex extracts the text between 'filename=' and the end or semicolon
    final regExp = RegExp(r'filename="?([^";]+)"?');
    final match = regExp.firstMatch(contentDisposition);
    if (match != null) {
      return match.group(1)!;
    }
  }

  // Fallback: If header is missing, try to get it from the URL path
  return url.split('/').last.split('?').first;
}
