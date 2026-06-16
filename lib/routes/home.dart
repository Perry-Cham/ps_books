import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/readers/mobiReader.dart';
import 'package:ps_books/routes/home%20comp/currently_reading.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/state/reader_state.dart';
import '../readers/reader.dart';
import '../helpers/pickBooks.dart';
import 'home comp/control_bars.dart';
import 'package:ps_books/dbs/database.dart';

BookToDb bookService = BookToDb();
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget{

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
    return AppBar(
      title: Text(
        title
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        PopUpControls(provider: LibraryStateProvider),
      ],
    );
  }
  @override get preferredSize => Size.fromHeight(kToolbarHeight);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  /**/

    return Scaffold(
      appBar: HomeAppBar(),
      body: Page(),
       floatingActionButton: IconButton.filled(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Color(0xFF1E1729),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        icon: Icon(Icons.add),
      ), 
    );
  }
}

class Page extends ConsumerWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
             SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: CurrentlyReading(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: FilterBar(),
                ),
              ),
              const BooksContainer(),
            ],
          ),
          if (state.isNotEmpty && !isAndroid)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10.0,
              child: ControlBar(provider: LibraryStateProvider),
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
    final filter = ref.watch(LibraryStateProvider.select((state) => state.filter));
    return StreamBuilder<List<Book>>(
      stream: database.watchAllBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data ?? [];
        final books = filter != null
            ? data.where((t) => t.collection == filter).toList()
            : [...data];
        if (books.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No books yet')),
          );
        }

        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            childAspectRatio: 200 / 300,
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
    final controlState = ref.watch(
      LibraryStateProvider.select((state) => state.multi_select),
    );
    bool isSelected = ref.watch(
      LibraryStateProvider.select(
        (state) => state.selectedBookIds.contains(widget.book.id),
      ),
    );

    return InkWell(
      onHover: (val) {
        setState(() {
          display_checkbox = val;
        });
      },
      onLongPress: () {
        ref.read(LibraryStateProvider.notifier).setSelectTrue();
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
          }
        } else {
          ref.read(readerStateProvider.notifier).setIsReadingTrue();
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
          SizedBox.expand(
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(
                        color: Colors.deepPurple.shade600,
                        width: 3,
                      )
                    : const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.04)),
              ),
              child: Stack(
                children: [
                  // LAYER 1: VISUAL BACKGROUND (COVER IMAGE OR FALLBACK)
                  Positioned.fill(
                    child: widget.book.coverPath != null
                        ? Image.file(
                            File(widget.book.coverPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const _CardFallbackBackground(),
                          )
                        : const _CardFallbackBackground(),
                  ),

                  // LAYER 2: THE GRADIENT SHADOW SHIELD
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.4, 0.85],
                        ),
                      ),
                    ),
                  ),

                  // LAYER 3: CONTENT OVERLAY (TITLE & PROGRESS BADGE)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Book Title Text
                          Text(
                            widget.book.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Reading Progress Badge
                          _buildMiniBadge(
                            "${(widget.book.progress * 100).toStringAsFixed(1)}% Read",
                            Colors.deepPurple.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (display_checkbox || isSelected)
            Positioned(
              top: 8,
              left: 8,
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

class _CardFallbackBackground extends StatelessWidget {
  const _CardFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey.shade900, Colors.grey.shade900],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.book_outlined,
          size: 48,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}

Widget _buildMiniBadge(String label, Color backgroundColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
