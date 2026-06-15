import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:ps_books/models/book_data.dart';
import 'downloader.dart';

Future<List<DownloadBook>> searchZlib(String query) async {
  final dio = Dio();
  // Zlib often requires specific headers or mirrors. 
  // For now, I'll use a placeholder or a known public gateway if possible.
  // The user mentioned zlib.fm.
  try {
    final response = await dio.get(
      'https://z-lib.fm/s/',
      queryParameters: {'q': query},
    );
    final document = html.parse(response.data);
    final results = document.querySelectorAll('.book-item'); // Placeholder selector
    
    List<DownloadBook> books = [];
    for (var el in results) {
      // Logic to parse book items from zlib.fm
      final title = el.querySelector('.title')?.text.trim() ?? 'Unknown';
      final author = el.querySelector('.author')?.text.trim() ?? 'Unknown';
      final href = el.querySelector('a')?.attributes['href'] ?? '';
      final extension = el.querySelector('.extension')?.text.trim().toLowerCase() ?? 'epub';
      final size = el.querySelector('.size')?.text.trim() ?? 'Unknown';
      final language = el.querySelector('.language')?.text.trim() ?? 'Unknown';

      books.add(DownloadBook(
        title: '$title - $author',
        year: 'Unknown',
        extension: extension,
        href: href,
        size: size,
        language: language,
        isbn: [],
      ));
    }
    return books;
  } catch (e) {
    print('Zlib search error: $e');
    return [];
  }
}
