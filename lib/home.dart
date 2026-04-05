import 'package:dart_pdf_reader/dart_pdf_reader_io.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';
import 'package:ps_books/readers/epubReader.dart';
import 'dart:io';
import './readers/pdfReader.dart';
import 'dart:typed_data';

import './helpers/pickBooks.dart';
import 'package:ps_books/dbs/database.dart';
import './helpers/utils.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            onPressed: () => print('testing'),
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  List<String> filters = ["All", "Adventure"];
  String selectedFilter = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        spacing: 15,
        children: [
          FilterBar(filters: filters),
          BooksContainer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Pick_Books().pickbooks(),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.add),
                    Text('Import', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.filters});

  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: filters.map((el) {
        print(filters);
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: 100),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: Center(
                child: Text(el, style: TextStyle(fontWeight: FontWeight(500))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BooksContainer extends StatelessWidget {
  const BooksContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<BookData>>(
        stream: database.watchAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text('No books yet'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookCard(book: books[index]);
            },
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  BookCard({super.key, required this.book});
  BookData book;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      elevation: 5,
      child: Column(
        children: [
          Expanded(child: Container()),
          Text(book.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text("${book.progress.toString()}%"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Reader(
                        path: book.path,
                        type: book.extension,
                        id: book.id,
                      ),
                    ),
                  );
                },
                child: Text("Read"),
              ),
              ElevatedButton(
                onPressed: () => database.deleteBook(book.id),
                child: Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Reader extends StatefulWidget {
  const Reader({
    super.key,
    required this.type,
    required this.path,
    required this.id,
  });
  final String path;
  final String type;
  final int id;
 
 @override
  State<Reader> createState() => ReaderState();
}

class ReaderState extends State<Reader> {
   final controller = PdfViewerController();

  storeBook({position, page}) {
    
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'pdf') {
      return PDF(path: widget.path, controller: controller);
    } else if (widget.type == 'epub') {
      return FutureBuilder(
        future: convertEpubToBytes(path: widget.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return EpubReaderScreen(epubBytes: snapshot.data);
          } else {
            return Center(child: Text('An error occured'));
          }
        },
      );
    } else {
      return Center(child: Text('Unsupported file'));
    }
  }
}
