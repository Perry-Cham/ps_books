import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import "package:html/parser.dart" as html;
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/helpers/book_processor.dart';
import 'package:kindle_unpack/kindle_unpack.dart';
import 'package:path/path.dart' as p;
import 'package:ps_books/models/book_data.dart';

final String url = "https://libgen.gl";
final _db = BookToDb();


Future<dynamic> SearchBooks(String query) async {
  print("this is");
  print(query);
  final dio = Dio();
  final response = await dio.get(
    'https://libgen.li/index.php',
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

  if(results.isEmpty){
    print("Results are empty");
    return;
  }
  print(results.length);
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

  return {
    "title": candidates.isNotEmpty ? candidates[0] : "",
    "isbn": foundIsbns.isNotEmpty ? foundIsbns : null,
    "year": data[3].text,
    "size": 6 < data.length ? data[6].text : "",
    "extension": 7 < data.length ? data[7].text : "",
    "href": 8 < data.length  ? data[8].querySelector("[title='libgen']")?.attributes['href'] : null,
    "language":4 < data.length ? data[4].text : ""
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

Future<void> _handleMobiDownload({
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

    // Clean up original MOBI file
    await File(savePath).delete();
  } catch (e) {
    print("Error converting MOBI to EPUB: $e");
    // Fallback: Add as MOBI if conversion fails
    await _db.addBook(
      name: filename.split('.')[0],
      extension: 'mobi',
      path: savePath,
    );
  }
}

Stream<double> downloadBookWithProgress(String url, CancelToken cancelToken) async* {
  final dio = Dio();
  final d = await getApplicationDocumentsDirectory();
  final supportDir = await getApplicationSupportDirectory();
  final coversDir = Directory("${supportDir.path}/Covers");
  await coversDir.create();

  final String filename = await getFileName(url);
  final String savePath = "${d.path}/Books/$filename";

  final controller = StreamController<double>();

  dio.download(
    url,
    savePath,
    cancelToken: cancelToken,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        controller.add(received / total);
      }
    },
  ).then((_) async {
    final String extension = filename.split('.').last.toLowerCase();
    if (['pdf', 'epub', 'fb2', 'cbz', 'cbt', 'cbw'].contains(extension)) {
      final fileBytes = await File(savePath).readAsBytes();
      final bookData = await processBook(
        fileBytes: fileBytes,
        fileName: filename,
        extension: extension,
        coversDir: coversDir,
      );
      await _db.addBook(
        name: bookData.title,
        author: bookData.author,
        extension: extension,
        path: savePath,
        page: (extension == 'pdf' ||
                extension == 'cbz' ||
                extension == 'cbt' ||
                extension == 'cbw')
            ? 1
            : null,
        coverPath: bookData.coverPath,
      );
    } else if (extension == 'mobi') {
      await _handleMobiDownload(
        savePath: savePath,
        filename: filename,
        coversDir: coversDir,
      );
    } else {
      await _db.addBook(
        name: filename.split('.')[0],
        extension: extension,
        path: savePath,
      );
    }
    controller.close();
  }).catchError((e) {
    controller.addError(e);
    controller.close();
  });

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
