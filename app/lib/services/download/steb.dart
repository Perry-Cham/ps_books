import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:ps_books/models/book_data.dart';

class _DownloadBook {
  final String title;
  final String href;
  final String? image;
  final String year;
  final String extension;
  final String size;
  final String language;
  final List<String>? isbn;

  _DownloadBook({
    required this.title,
    required this.href,
    this.image,
  })  : year = '',
        extension = 'epub',
        size = '',
        language = 'English',
        isbn = null;

  DownloadBook toDownloadBook() => DownloadBook(
    title: title,
    year: year,
    extension: extension,
    href: href,
    size: size,
    language: language,
    isbn: isbn,
    image: image,
  );
}

class StandardEbooksScraper {
  static const String baseUrl = "https://standardebooks.org";
  static final Dio _dio = Dio();

  static Future<List<DownloadBook>> search(String query) async {
    try {
      final response = await _dio.get(
        "$baseUrl/ebooks",
        queryParameters: {'query': query},
      );
      final document = html.parse(response.data);
      final results = document.querySelectorAll(
        "ol.ebooks-list li[typeof='schema:Book']",
      );

      if (results.isEmpty) {
        print('No results');
        return [];
      }

      final futures = results.map((el) => _processResult(el)).toList();
      final books = await Future.wait(futures);
      return books
          .whereType<_DownloadBook>()
          .map((b) => b.toDownloadBook())
          .toList();
    } catch (e) {
      print("Error during search: $e");
      return [];
    }
  }

  static Future<_DownloadBook?> _processResult(var el) async {
    final titleEl = el.querySelector("p a span[property='schema:name']");
    final authorEl = el.querySelector(
      "p.author a span[property='schema:name']",
    );

    String title = titleEl?.text.trim() ?? "Unknown Title";
    if (authorEl != null) {
      title = "$title - ${authorEl.text.trim()}";
    }

    final linkEl = el.querySelector("a[property='schema:url']");
    final detailPath = linkEl?.attributes['href'];
    if (detailPath == null) return null;
    final detailUrl = detailPath.startsWith("http")
        ? detailPath
        : "$baseUrl$detailPath";

    final imageEl = el.querySelector("img[property='schema:image']");
    final imagePath = imageEl?.attributes['src'];
    final imageUrl = imagePath != null
        ? (imagePath.startsWith("http") ? imagePath : "$baseUrl$imagePath")
        : null;

    final downloadUrl = await _getDownloadLink(detailUrl);
    if (downloadUrl == null) return null;

    return _DownloadBook(title: title, href: downloadUrl, image: imageUrl);
  }

  static Future<String?> _getDownloadLink(String detailUrl) async {
    try {
      final response = await _dio.get(detailUrl);
      final document = html.parse(response.data);

      final link = document.querySelector(
        "a.epub[property='schema:contentUrl']",
      );
      if (link != null) {
        final href = link.attributes['href'];
        return href!.startsWith("http") ? href : "$baseUrl$href?source=download";
      }
      print("No epubs found on detail page");
    } catch (e) {
      print("Error fetching detail page $detailUrl: $e");
    }
    return null;
  }
}
