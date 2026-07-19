import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'package:ps_books/models/comic_book_model.dart';

class StebOpdsParser {
  static const String baseUrl = 'https://standardebooks.org';
  static const String opdsFeedUrl = '$baseUrl/feeds/opds';
  final Dio _dio;

  StebOpdsParser({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<SeriesModel>> search({required String query}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/ebooks',
        queryParameters: {'query': query},
        options: Options(
          headers: {
            'Accept': 'application/atom+xml, text/html',
            'User-Agent': 'Mozilla/5.0 (compatible; PSBooks/1.0)',
          },
        ),
      );

      final contentType = response.headers.value('content-type') ?? '';
      if (contentType.contains('atom') || contentType.contains('xml')) {
        return _parseOpdsFeed(response.data);
      }

      return _parseHtmlResults(response.data);
    } catch (e) {
      print('Error searching Standard Ebooks: $e');
      return [];
    }
  }

  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    return [];
  }

  List<SeriesModel> _parseOpdsFeed(String xmlData) {
    final document = XmlDocument.parse(xmlData);
    final entries = document.findAllElements('entry');
    final results = <SeriesModel>[];

    for (final entry in entries) {
      final title = entry.findElements('title').firstOrNull?.innerText ?? '';
      final authorEl = entry.findElements('author').firstOrNull;
      final authorName = authorEl
          ?.findElements('name')
          .firstOrNull
          ?.innerText;

      String? coverUrl;
      String? downloadUrl;
      String? detailUrl;

      for (final link in entry.findElements('link')) {
        final rel = link.getAttribute('rel') ?? '';
        final href = link.getAttribute('href') ?? '';
        final type = link.getAttribute('type') ?? '';

        if (rel == 'http://opds-spec.org/image' || rel == 'http://opds-spec.org/image/thumbnail') {
          coverUrl = href.startsWith('http') ? href : '$baseUrl$href';
        } else if (rel == 'http://opds-spec.org/acquisition' && type.contains('epub')) {
          downloadUrl = href.startsWith('http') ? href : '$baseUrl$href';
        } else if (rel == 'alternate' && type == 'text/html') {
          detailUrl = href.startsWith('http') ? href : '$baseUrl$href';
        }
      }

      final displayTitle = authorName != null ? '$title - $authorName' : title;

      results.add(SeriesModel(
        id: detailUrl,
        title: displayTitle,
        coverUrl: coverUrl,
        detailUrl: downloadUrl ?? detailUrl ?? '',
      ));
    }

    return results;
  }

  List<SeriesModel> _parseHtmlResults(String html) {
    final regExp = RegExp(
      r'<li[^>]*typeof="schema:Book"[^>]*>(.*?)</li>',
      dotAll: true,
    );
    final matches = regExp.allMatches(html);
    final results = <SeriesModel>[];

    for (final match in matches) {
      final content = match.group(1) ?? '';

      final titleMatch = RegExp(
        r'<span[^>]*property="schema:name"[^>]*>(.*?)</span>',
        dotAll: true,
      ).firstMatch(content);
      final title = titleMatch?.group(1)?.trim() ?? 'Unknown';

      final authorMatch = RegExp(
        r'<span[^>]*property="schema:name"[^>]*>(.*?)</span>',
        dotAll: true,
      ).firstMatch(content);
      String author = '';
      if (authorMatch != null && authorMatch != titleMatch) {
        author = authorMatch.group(1)?.trim() ?? '';
      }

      final linkMatch = RegExp(
        r'<a[^>]*property="schema:url"[^>]*href="([^"]*)"',
      ).firstMatch(content);
      final detailPath = linkMatch?.group(1) ?? '';
      final detailUrl = detailPath.startsWith('http')
          ? detailPath
          : '$baseUrl$detailPath';

      final imgMatch = RegExp(
        r'<img[^>]*property="schema:image"[^>]*src="([^"]*)"',
      ).firstMatch(content);
      final imagePath = imgMatch?.group(1);
      final coverUrl = imagePath != null
          ? (imagePath.startsWith('http') ? imagePath : '$baseUrl$imagePath')
          : null;

      final displayTitle = author.isNotEmpty ? '$title - $author' : title;

      results.add(SeriesModel(
        id: detailUrl,
        title: displayTitle,
        coverUrl: coverUrl,
        detailUrl: detailUrl,
      ));
    }

    return results;
  }
}
