import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import "package:html/parser.dart" as html;
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/helpers/pickBooks.dart';
import 'package:ps_books/services/bookToDb.dart';

final String url = "https://libgen.gl";
final _db = BookToDb();

class DownloadBook {
  final String title;
  final String year;
  final String extension;
  final String href;
  final String size;
  List<String>? isbn;

  DownloadBook({
    required this.title,
    required this.year,
    required this.extension,
    required this.href,
    required this.size,
  });

  static DownloadBook? fromMap(Map<String, dynamic> book) {
    if (book['extension'] != "pdf" && book['extension'] != "pdf") {
      return null;
    } else {
      return DownloadBook(
        extension: book['extension'],
        year: book['year'],
        title: book['title'],
        href: book['href'],
        size: book['size'],
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
      'topics[]': ['l', 'c', 'f', 'a', 'm', 'r', 's'],
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
  if (data.length < 1) return null;

  List<Element> titles = data[0].querySelectorAll("a[data-html='true']");
  List<String> candidates = [];
  for (var el in titles) {
    var j = el.text.trim();
    //print(el.text);
    print(j);
    if (j == '') {
      continue;
    } else {
      candidates.add(j);
    }
  }

  return {
    "title": candidates[0],
    "year": data[3].text,
    "size": data[6].text,
    "extension": data[7].text,
    "href": data[8].querySelector("[title='libgen']")?.attributes['href'],
  };
}

Future<String?> downloadPageScraper(String link) async {
  final dio = Dio();
  print(link);
  final response = await dio.get("${url}${link}");
  final page = html.parse(response.data);
  final downloadLink = page.querySelector("#main a")!.attributes['href'];
  print("${url}/${downloadLink}");

  if (downloadLink != null) {
    return "${url}/${downloadLink}";
  } else {
    return null;
  }
}

Stream<double> downloadBookWithProgress(String url) async* {
  final dio = Dio();
  final controller = StreamController<double>();
  final d = await getApplicationDocumentsDirectory();
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
    String extension = filename.split('.').last;
    String title = filename.split('.')[0];
    Map<String, dynamic> bookData = {
      'name': title,
      'extension': extension,
      'path': savePath,
    };
    if (extension == 'pdf') {
      print("start of pdf code");

      await _db.addBook(
        name: bookData['name'],
        extension: bookData['extension'],
        path: bookData['path'],
        page: 1,
      );
    } else if (extension == 'epub') {
      await _db.addBook(
        name: bookData['name'],
        extension: bookData['extension'],
        path: bookData['path'],
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
