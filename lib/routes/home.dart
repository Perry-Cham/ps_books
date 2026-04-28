import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import '../readers/reader.dart';
import '../helpers/pickBooks.dart';
import '../helpers/utils.dart';
import './home screen comp/control_bars.dart';
import 'package:ps_books/dbs/database.dart';
import "home screen comp/dialogs.dart";

BookToDb bookService = BookToDb();

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

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        spacing: 15,
        children: [
          ControlBar(),
          FilterBar(),
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
class BooksContainer extends ConsumerWidget {
  const BooksContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _library_state = ref.watch(LibraryStateProvider);
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

          final data = snapshot.data ?? [];
          final books = _library_state.filter != null
              ? data
                    .where((t) => t.collection == _library_state.filter)
                    .toList()
              : [...data];
          print(_library_state.filter);
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
  @override
  Widget build(BuildContext context) {
    final selectedBookIds = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );
    final isSelected = selectedBookIds.contains(widget.book.id);
    // TODO: implement build
    return InkWell(
      onTap: () {
        final controlState = ref.watch(LibraryStateProvider);
        print(controlState.multi_select);
        if (controlState.multi_select) {
          if (!isSelected) {
            ref.read(LibraryStateProvider.notifier).addSelected(widget.book.id);
          } else {
            ref
                .read(LibraryStateProvider.notifier)
                .removeSelected(widget.book.id);
          }
        } else {
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
        color: isSelected ? Colors.cyan : Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(widget.book.name, maxLines: 1, overflow: TextOverflow.fade),
              //Text(widget.book.name),
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
