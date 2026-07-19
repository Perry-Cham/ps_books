import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ps_books/tools/ai_chat.dart';
import 'package:ps_books/routes/homeComp/currently_reading.dart';
import 'package:ps_books/routes/homeComp/series_view.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/state/reader_state.dart';
import 'package:ps_books/models/library_item.dart';
import '../readers/reader_shell.dart';
import '../helpers/pickBooks.dart';
import 'homeComp/control_bars.dart';
import 'package:ps_books/dbs/database.dart';

BookToDb bookService = BookToDb();

final libraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  final booksStream = bookService.watchAllBooks();
  final seriesStream = bookService.watchAllSeries();

  return CombineLatestStream.combine2(
    booksStream,
    seriesStream,
    (List<Book> books, List<Sery> series) {
      final bookItems = books
          .where((b) => !b.isSeries)
          .map((b) => LibraryItem.fromBook(b))
          .toList();

      final seriesItems = series.map((s) {
        final seriesBooks = books.where((b) => b.series == s.id && !b.isSeries).toList();
        final coverPath = seriesBooks.isNotEmpty
            ? (seriesBooks.first.coverPath ?? s.cover)
            : s.cover;
        return LibraryItem.fromSeries(s, coverPath: coverPath);
      }).toList();

      return [...bookItems, ...seriesItems];
    },
  );
});

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

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
      title: Text(title),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        PopUpControls(provider: LibraryStateProvider),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AiChatPanel()));
          },
        ),
      ],
    );
  }

  @override
  get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: const Page(),
      floatingActionButton: IconButton.filled(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: const Color(0xFF1E1729),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.all(30),
              child: const Column(
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
        icon: const Icon(Icons.add),
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
    final libraryItemsAsync = ref.watch(libraryItemsProvider);

    return libraryItemsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $err')),
      ),
      data: (items) {
        final filtered = filter != null
            ? items.where((t) => t.collection == filter).toList()
            : items;
        if (filtered.isEmpty) {
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
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return LibraryItemCard(item: filtered[index]);
          },
        );
      },
    );
  }
}

class LibraryItemCard extends ConsumerStatefulWidget {
  const LibraryItemCard({super.key, required this.item});
  final LibraryItem item;

  @override
  ConsumerState<LibraryItemCard> createState() => LibraryItemCardState();
}

class LibraryItemCardState extends ConsumerState<LibraryItemCard> {
  bool display_checkbox = false;

  @override
  Widget build(BuildContext context) {
    final controlState = ref.watch(
      LibraryStateProvider.select((state) => state.multi_select),
    );
    bool isSelected = ref.watch(
      LibraryStateProvider.select(
        (state) => state.selectedBookIds.contains(widget.item.id),
      ),
    );

    return InkWell(
      onHover: (val) => setState(() => display_checkbox = val),
      onLongPress: () {
        ref.read(LibraryStateProvider.notifier).setSelectTrue();
        ref.read(LibraryStateProvider.notifier).addSelected(widget.item.id);
      },
      onTap: () {
        if (controlState) {
          if (!isSelected) {
            ref.read(LibraryStateProvider.notifier).addSelected(widget.item.id);
          } else {
            ref.read(LibraryStateProvider.notifier).removeSelected(widget.item.id);
          }
        } else if (widget.item.isSeries) {
          _openSeriesView();
        } else {
          _openReader();
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
                    ? BorderSide(color: Colors.deepPurple.shade600, width: 3)
                    : const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.04)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.item.coverPath != null
                        ? (widget.item.coverPath!.startsWith('http')
                            ? Image.network(
                                widget.item.coverPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const _CardFallbackBackground(),
                              )
                            : Image.file(
                                File(widget.item.coverPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const _CardFallbackBackground(),
                              ))
                        : const _CardFallbackBackground(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                          stops: const [0.0, 0.4, 0.85],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Text(
                            widget.item.name,
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
                          if (widget.item.isSeries)
                            _buildMiniBadge(
                              "Series",
                              Colors.teal.shade700,
                            )
                          else
                            _buildMiniBadge(
                              "${(widget.item.progress * 100).toStringAsFixed(1)}% Read",
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
          if (widget.item.isSeries)
            Positioned(
              top: 8,
              left: 8,
              child: Icon(Icons.collections_bookmark, color: Colors.teal.shade300, size: 20),
            ),
          if (display_checkbox || isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Checkbox(
                value: isSelected,
                onChanged: (val) {
                  if (val != null) {
                    if (val) {
                      ref.read(LibraryStateProvider.notifier).addSelected(widget.item.id);
                    } else {
                      ref.read(LibraryStateProvider.notifier).removeSelected(widget.item.id);
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openSeriesView() async {
    final sery = await bookService.getSeriesById(widget.item.id);
    if (sery != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesViewHome(
            series: sery,
            coverPath: widget.item.coverPath,
          ),
        ),
      );
    }
  }

  void _openReader() async {
    try {
      final book = await bookService.getBookById(widget.item.id);
      if (context.mounted) {
        ref.read(readerStateProvider.notifier).setIsReadingTrue();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderShell(
              path: book.path,
              type: book.extension,
              id: book.id,
              page: book.page,
              position: book.cfi,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error opening book: $e');
    }
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
          color: Colors.white.withValues(alpha: 0.15),
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
