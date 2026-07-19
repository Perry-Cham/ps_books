import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/models/downloader_models.dart';
import './parsers/opds.dart';

enum StebSearchMode { normal, opds }

class StandardEbooks implements SeriesCapable {
  StebSearchMode mode = StebSearchMode.normal;

  StandardEbooks({StebSearchMode? mode}) : mode = mode ?? StebSearchMode.normal;

  @override
  Future<List<SeriesModel>> search({required String query}) async {
    if (mode == StebSearchMode.opds) {
      final parser = StebOpdsParser();
      return parser.search(query: query);
    }
    return _searchNormal(query);
  }

  Future<List<SeriesModel>> _searchNormal(String query) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'https://standardebooks.org/ebooks',
        queryParameters: {'query': query},
      );
      final document = html.parse(response.data);
      final results = document.querySelectorAll(
        "ol.ebooks-list li[typeof='schema:Book']",
      );

      final books = <SeriesModel>[];
      for (final el in results) {
        final titleEl = el.querySelector("p a span[property='schema:name']");
        final authorEl = el.querySelector(
          "p.author a span[property='schema:name']",
        );

        String title = titleEl?.text.trim() ?? 'Unknown Title';
        String author = '';
        if (authorEl != null) {
          author = authorEl.text.trim();
          title = '$title - $author';
        }

        final linkEl = el.querySelector("a[property='schema:url']");
        final detailPath = linkEl?.attributes['href'];
        if (detailPath == null) continue;
        final detailUrl = detailPath.startsWith('http')
            ? detailPath
            : 'https://standardebooks.org$detailPath';

        final imageEl = el.querySelector("img[property='schema:image']");
        final imagePath = imageEl?.attributes['src'];
        final imageUrl = imagePath != null
            ? (imagePath.startsWith('http')
                ? imagePath
                : 'https://standardebooks.org$imagePath')
            : null;

        final downloadUrl = await _getDownloadLink(detailUrl);
        if (downloadUrl == null) continue;

        books.add(SeriesModel(
          id: detailUrl,
          title: title,
          coverUrl: imageUrl,
          detailUrl: downloadUrl,
        ));
      }
      return books;
    } catch (e) {
      print('Error in StandardEbooks search: $e');
      return [];
    }
  }

  Future<String?> _getDownloadLink(String detailUrl) async {
    final dio = Dio();
    try {
      final response = await dio.get(detailUrl);
      final document = html.parse(response.data);
      final link = document.querySelector(
        "a.epub[property='schema:contentUrl']",
      );
      if (link != null) {
        final href = link.attributes['href'];
        return href!.startsWith('http')
            ? href
            : 'https://standardebooks.org$href?source=download';
      }
    } catch (e) {
      print('Error fetching detail page $detailUrl: $e');
    }
    return null;
  }

  @override
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    return [];
  }

  @override
  void download({required VolumeInfo volume}) {
    // Delegate to downloader
  }
}
