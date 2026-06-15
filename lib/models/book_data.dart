class BookData {
  final String title;
  final String? author;
  final String? coverPath;
  final Map<String, dynamic> properties;

  BookData({
    required this.title,
    this.author,
    this.coverPath,
    this.properties = const {},
  });
}


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
    if ((ext != "pdf" && ext != "epub" && ext != "fb2" && ext != "mobi" &&
        ext != "cbz" && ext != "cbt" && ext != "cbw") ||
        book['href'] == null) {
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