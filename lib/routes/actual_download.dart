import 'package:flutter/material.dart';
import 'package:ps_books/services/downloader.dart';

class ActualDownloadPage extends StatelessWidget {
  final DownloadBook book;

  const ActualDownloadPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download ${book.title}')),
      body: Center(
        child: Text('Placeholder for download functionality. Book: ${book.title}, Year: ${book.year}, Extension: ${book.extension}'),
      ),
    );
  }
}