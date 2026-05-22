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
