import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'downloader.dart';

Future<List<DownloadBook>> searchSteb(String query) async {
  final dio = Dio();
  try {
    final response = await dio.get(
      'https://standardebooks.org/ebooks',
      queryParameters: {'query': query},
    );
    final document = html.parse(response.data);
    final results = document.querySelectorAll('li.ebook'); 
    
    List<DownloadBook> books = [];
    for (var el in results) {
      final title = el.querySelector('a')?.text.trim() ?? 'Unknown';
      final author = el.querySelector('.author')?.text.trim() ?? 'Unknown';
      final href = el.querySelector('a')?.attributes['href'] ?? '';
      
      // Standard Ebooks usually have multiple formats on their page.
      // For simplicity, we'll point to the main page and let the scraper handle it,
      // or we can pre-populate if we know the patterns.
      
      books.add(DownloadBook(
        title: '$title - $author',
        year: 'Unknown',
        extension: 'epub', // Default for Standard Ebooks
        href: href,
        size: 'Unknown',
        language: 'English',
        isbn: [],
      ));
    }
    return books;
  } catch (e) {
    print('Standard Ebooks search error: $e');
    return [];
  }
}
