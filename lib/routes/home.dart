import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/binaryauthorization/v1.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import '../readers/reader.dart';
import '../helpers/pickBooks.dart';
import '../helpers/utils.dart';
import 'home comp/control_bars.dart';
import 'package:ps_books/dbs/database.dart';

BookToDb bookService = BookToDb();

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          PopUpControls(provider: LibraryStateProvider),
        ],
      ),
      body: Page(),
    );
  }
}

class Page extends ConsumerWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(LibraryStateProvider);
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        spacing: 15,
        children: [
          FilterBar(),
          Expanded(
            child: Stack(
              children: [
                BooksContainer(),
                if (state.selectedBookIds.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10.0,
                    child: ControlBar(provider: LibraryStateProvider),
                  ),
              ],
            ),
          ),
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
    final libraryState = ref.watch(LibraryStateProvider);
    return StreamBuilder<List<Book>>(
      stream: database.watchAllBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? [];
        final books = libraryState.filter != null
            ? data.where((t) => t.collection == libraryState.filter).toList()
            : [...data];
        if (books.isEmpty) {
          return const Center(child: Text('No books yet'));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 150 / 200,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(book: books[index]);
          },
        );
      },
    );
  }
}

class BookCard extends ConsumerStatefulWidget {
  const BookCard({super.key, required this.book});
  final Book book;

  @override
  ConsumerState<BookCard> createState() {
    return BookCardState();
  }
}

class BookCardState extends ConsumerState<BookCard> {
  bool display_checkbox = false;
  bool checkbox_clicked = false;
  @override
  Widget build(BuildContext context) {
    final selectedBookIds = ref.read(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );
    final controlState = ref.watch(LibraryStateProvider.select((state) => state.multi_select));
    bool isSelected = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds.contains(widget.book.id)));
    // TODO: implement build
    return InkWell(
      onHover: (val) {
        setState(() {
          display_checkbox = val;
        });
      },
      onLongPress: () {
        ref.read(LibraryStateProvider.notifier).toggleMultiSelect();
        ref.read(LibraryStateProvider.notifier).addSelected(widget.book.id);
      },
      onTap: () {
   
        if (controlState) {
          if (!isSelected) {
            ref.read(LibraryStateProvider.notifier).addSelected(widget.book.id);
          } else {
            ref
                .read(LibraryStateProvider.notifier)
                .removeSelected(widget.book.id);
            if (selectedBookIds.isEmpty) {
              ref.read(LibraryStateProvider.notifier).toggleMultiSelect();
            }
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
      child: Stack(
        children: [
          Card(
            shape: isSelected
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(5)),
                    side: BorderSide(
                      color: Colors.deepPurple.shade600,
                      width: 2,
                    ),
                  )
                : null,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Expanded(child: widget.book.coverPath != null ? Image.file(widget.book.coverPath!): Image.asset('assets/no_book.jpg')),
                  Padding(
                    padding: EdgeInsetsGeometry.all(2),
                    child: Column(
                      children: [
                        Text(
                          widget.book.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${(widget.book.progress * 100).toStringAsFixed(2)}%",
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (display_checkbox || isSelected)
            Positioned(
              top: 0,
              left: 0,
              child: Checkbox(
                value: isSelected,
                onChanged: (val) {
             
                  if (val != null) {
                    if (val) {
                      ref
                          .read(LibraryStateProvider.notifier)
                          .addSelected(widget.book.id);
                    } else {
                      ref
                          .read(LibraryStateProvider.notifier)
                          .removeSelected(widget.book.id);
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

int _getCrossAxisCount(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 6;
  if (width > 800) return 4;
  if (width > 600) return 3;
  if (width > 400) return 2;
  return 2;
}
