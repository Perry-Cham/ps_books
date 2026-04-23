import 'package:dart_pdf_reader/dart_pdf_reader_io.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';
import 'package:ps_books/readers/epubReader.dart';
import 'package:ps_books/state/library_state.dart';
import 'dart:io';
import 'dart:convert';
import './readers/pdfReader.dart';
import 'dart:typed_data';

import './helpers/pickBooks.dart';
import './helpers/utils.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/bookToDb.dart';

import 'package:katbook_epub_reader/src/models/reading_position.dart';

List<int> SelectedBookIds = [];

final bookService = BookToDb();

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library_state = ref.watch(LibraryStateProvider);
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
          IconButton(
            onPressed: () {
              ref.read(LibraryStateProvider.notifier).toggleMultiSelect();
            },
            icon: Icon(Icons.done_all),
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
          ControlBar(),
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

class BookCard extends ConsumerStatefulWidget {
  BookCard({super.key, required this.book});
  BookData book;

  @override
  ConsumerState<BookCard> createState() {
    return BookCardState();
  }
}

class BookCardState extends ConsumerState<BookCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () {
        final controlState = ref.watch(LibraryStateProvider);
        print(controlState.multi_select);
        if (controlState.multi_select) {
          if (selected == false) {
            setState(){
              selected = true;
            }
            SelectedBookIds.add(widget.book.id);
          } else {
         setState(){
              selected = true;
            }
            int index = SelectedBookIds.indexOf(widget.book.id);
            SelectedBookIds.removeAt(index);
          }
        }else{    
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Reader(
              path: widget.book.path,
              type: widget.book.extension,
              id: widget.book.id,
              page: widget.book.page,
              position: widget.book.cfi,
            ),
          ),
        );
        }
      },
      child: Card(
        color: selected ? Colors.cyan : Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(widget.book.name, maxLines: 1, overflow: TextOverflow.fade),
              Text("${(widget.book.progress * 100).toStringAsFixed(2)}%"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await deleteBook(
                        path: widget.book.path,
                        id: widget.book.id,
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Book(s) Deleted'),
                            content: Text('Deleted Book(s)'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    this.page,
    this.position,
  });
  final String path;
  final String type;
  final int id;
  final int? page;
  final position;

  @override
  State<Reader> createState() => ReaderState();
}

class ReaderState extends State<Reader> {
  final controller = PdfViewerController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  savePDFProgress() async {
    int Page = controller.pageNumber ?? 1;
    int totalPages = controller.pageCount;
    double progress = Page / totalPages;
    await database.updatePage(widget.id, Page);
    await database.updateProgress(widget.id, progress);
  }

  saveEpubPosition(position) {
    String pos = jsonEncode(position);
    database.updatePositionAndProgress(widget.id, pos);
  }

  saveEpubProgress(progress) {
    database.updateProgress(widget.id, progress);
  }

  ReadingPosition? getPosition() {
    if (widget.position == null) return null;
    var json = jsonDecode(widget.position);
    ReadingPosition pos = ReadingPosition(
      chapterIndex: json['chapterIndex'],
      paragraphIndex: json['paragraphIndex'],
      totalParagraphs: json['totalParagraphs'],
    );
    return pos;
  }

  checkWidget() {
    if (widget.type == 'pdf') {
      return PDF(path: widget.path, controller: controller, page: widget.page ?? 1);
    } else if (widget.type == 'epub') {
      return FutureBuilder(
        future: convertEpubToBytes(path: widget.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return EpubReaderScreen(
              epubBytes: snapshot.data,
              initialPosition: getPosition(),
              onPositionChanged: saveEpubPosition,
              onProgressChanged: saveEpubProgress,
            );
          } else if (widget.type == 'docx' || widget.type == 'pptx') {
            return FutureBuilder(
              future: File(widget.path).readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return MicrosoftViewer(snapshot.data!, false);
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Text("Loading...");
                } else {
                  return Text("An Error has occured");
                }
              },
            );
          } else {
            return Center(child: Text('An error occured'));
          }
        },
      );
    } else {
      return Center(child: Text('Unsupported file'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // your logic here
        if (widget.type == 'pdf') {
          await savePDFProgress();
        }
        if (mounted) Navigator.pop(context);
      },
      canPop: true,
      child: checkWidget(),
    );
  }
}

class AddToCollectionDialog extends StatefulWidget {
  @override
  State<AddToCollectionDialog> createState() => _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends State<AddToCollectionDialog> {
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final category = _categoryController.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      for (var id in SelectedBookIds) {
        await addToCollection(id, category);
      }

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Books added to collection successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add books: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: 'Enter collection name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}

class ControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await deleteBooks(SelectedBookIds);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Success"),
                    content: Text("The operation completed successfully!"),
                  );
                },
              );
            } catch (e) {
              print(e);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("The operation failed!"),
                  );
                },
              );
            }
          },
          icon: Icon(Icons.delete),
          label: Text("Delete"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddToCollectionDialog(),
            );
          },
          icon: Icon(Icons.add),
          label: Text("Add To Collection"),
        ),
      ],
    );
  }
}

Future<void> deleteBooks(List<int> deletedBookIds) async {
  if (deletedBookIds.isEmpty) return;

  for (final id in deletedBookIds) {
    await bookService.deleteBook(id);
  }
}

Future<void> deleteGroup() async {
  if (SelectedBookIds.isEmpty) return;

  await deleteBooks(SelectedBookIds);
  SelectedBookIds.clear();
}

Future<void> addToCollection(int id, String category) async {
  await bookService.setAllCategories(category, id);
}
