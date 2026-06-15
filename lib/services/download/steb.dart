import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

class _DownloadBook {
  final String title;
  final String href; // Direct EPUB download link
  final String? image; // Cover image URL
  final String year;
  final String extension;
  final String size;
  final String language;
  final List<String>? isbn;

  _DownloadBook({
    required this.title,
    required this.href,
    this.image,
    this.year = "",
    this.extension = "epub",
    this.size = "",
    this.language = "English",
    this.isbn,
  });

  @override
  String toString() {
    return 'Book: $title\nDownload: $href\nImage: $image\n---';
  }
}


class StandardEbooksScraper {
  static const String baseUrl = "https://standardebooks.org";
  final Dio _dio;

  StandardEbooksScraper() : _dio = Dio() {
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };
  }

  /// Searches for books and returns a list of DownloadBook objects.
  /// Note: Fetches detail pages in parallel to get the actual download links.
  Future<List<_DownloadBook>> search(String query) async {
    try {
      final response = await _dio.get("$baseUrl/ebooks", queryParameters: {'query': query});
      print("Search URL: ${response.realUri}");
      print("Response status: ${response.statusCode}");
      final document = html.parse(response.data);
      final results = document.querySelectorAll("ol.ebooks-list li[typeof='schema:Book']");
      //print(document.outerHtml);
      print("Found ${results.length} raw results.");

      if (results.isEmpty) {
        print('No results');
        return [];
      }
      print(results[0].outerHtml);
      // Process results in parallel to fetch direct download links
      List<Future<_DownloadBook?>> futures = results.map((el) => _processResult(el)).toList();

      final books = await Future.wait(futures);
      return books.whereType<_DownloadBook>().toList();
    } catch (e) {
      print("Error during search: $e");
      return [];
    }
  }

  Future<_DownloadBook?> _processResult(var el) async {
    // 1. Get Title and Author
    final titleEl = el.querySelector("p a span[property='schema:name']");
    final authorEl = el.querySelector("p.author a span[property='schema:name']");

    String title = titleEl?.text.trim() ?? "Unknown Title";
    if (authorEl != null) {
      title = "$title - ${authorEl.text.trim()}";
    }

    // 2. Get Detail Link
    final linkEl = el.querySelector("a[property='schema:url']");
    final detailPath = linkEl?.attributes['href'];
    print("Processing result: $title, Detail Path: $detailPath");
    if (detailPath == null) return null;
    final detailUrl = detailPath.startsWith("http") ? detailPath : "$baseUrl$detailPath";

    // 3. Get Image Link
    final imageEl = el.querySelector("img[property='schema:image']");
    final imagePath = imageEl?.attributes['src'];
    final imageUrl = imagePath != null ? (imagePath.startsWith("http") ? imagePath : "$baseUrl$imagePath") : null;

    // 4. Fetch Detail Page for Download Link
    print(detailUrl);
    final downloadUrl = await _getDownloadLink(detailUrl);
    print("Download URL for $title: $downloadUrl");
    if (downloadUrl == null) return null;

    return _DownloadBook(
      title: title,
      href: downloadUrl,
      image: imageUrl,
    );
  }

  Future<String?> _getDownloadLink(String detailUrl) async {
    try {
      final response = await _dio.get(detailUrl);
      final document = html.parse(response.data);

      // Standard Ebooks uses property="schema:downloadUrl" for download links
      final link = document.querySelector("a.epub[property='schema:contentUrl']");
      print("Found a link download links on detail page.");
      if(link != null){
        final href = link.attributes['href'];
        final text = link.text.toLowerCase();
        print("Link text: $text, Link href: $href");
        return href!.startsWith("http") ? href : "$baseUrl$href";
      }else{
        print("No epubs found");
      }


    } catch (e) {
      print("Error fetching detail page $detailUrl: $e");
    }
    return null;
  }
}
