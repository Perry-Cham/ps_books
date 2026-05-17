import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import '../readers/reader.dart';
import '../helpers/pickBooks.dart';
import 'home comp/control_bars.dart';
import 'package:ps_books/dbs/database.dart';

BookToDb bookService = BookToDb();

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionCount = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds.length),
    );
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    String title = "My Library";
    if (isAndroid && selectionCount > 0) {
      title = "$selectionCount selected";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1E1729),
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
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1B1227),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 15,
          children: [
            FilterBar(),
            Expanded(
              child: Stack(
                children: [
                  BooksContainer(),
                  if (state.selectedBookIds.isNotEmpty && !isAndroid)
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
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      enableDrag: false,
                      backgroundColor: Color(0xFF1E1729),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => Container(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.deepPurple),
                            SizedBox(height: 20),
                            Text(
                              "Importing your books",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    await Pick_Books().pickbooks();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
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
      ),
    );
  }
}

class BooksContainer extends ConsumerWidget {
  const BooksContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.read(LibraryStateProvider.select((state) => state.filter));
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
        final books = libraryState != null
            ? data.where((t) => t.collection == libraryState).toList()
            : [...data];
        if (books.isEmpty) {
          return const Center(child: Text('No books yet'));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 20,
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
      child:Stack(
        children: [
          SizedBox.expand(
            child: Card(
              clipBehavior: Clip.antiAlias,
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
                child: Stack(
                  children: [
                    if(widget.book.coverPath != null)
                      Positioned(left:0, right:0, child:Image.file(File(widget.book.coverPath!)))
                    else
                      Image.asset('assets/no_book.jpg'),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.black87
                        ),
                        child:  Padding(
                          padding: EdgeInsetsGeometry.only(right: 5, left: 5, top: 8, bottom: 8),
                          child: Column(
                            spacing: 5,
                            children: [
                              Text(
                                widget.book.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${(widget.book.progress * 100).toStringAsFixed(2)}%",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          )
          ,
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
