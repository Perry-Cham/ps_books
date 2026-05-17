import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/routes/home%20comp/control_bars.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/wishlist.dart';
import 'package:ps_books/state/library_state.dart';

final _db = DBProvider().db;

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(WishlistStateProvider);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        children: [
          FilterBar(),
          Expanded(
            child: Stack(
              children: [
                SavedBooksTable(),
                if (wishlist.selectedBookIds.isNotEmpty && !isAndroid)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10.0,
                    child: ControlBar(provider: WishlistStateProvider, wishlist: true,),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showAddBookDialog(context),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.add),
                    Text('Add Book', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Add Book to Wishlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: authorController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Author',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty) {
                await _db
                    .into(_db.savedBooks)
                    .insert(
                      SavedBooksCompanion(
                        title: Value(titleController.text),
                        author: Value(authorController.text),
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Book added to wishlist')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(WishlistStateProvider);

    return StreamBuilder<List<Collection>>(
      stream: BookToDb().getSavedCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        final collections = snapshot.data ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: FilterChip(
                  label: Text('All'),
                  selected: wishlist.filter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(WishlistStateProvider.notifier).setFilter(null);
                    }
                  },
                ),
              ),
              ...collections.map((collection) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(collection.name),
                    selected: wishlist.filter == collection.id,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(WishlistStateProvider.notifier)
                            .setFilter(collection.id);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class SavedBooksTable extends ConsumerWidget {
  const SavedBooksTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(WishlistStateProvider);
    final librarySelected = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );

    return StreamBuilder<List<Collection>>(
      stream: BookToDb().getSavedCategories(),
      builder: (context, collectionSnapshot) {
        final collectionMap = {
          for (var c in collectionSnapshot.data ?? []) c.id: c.name
        };

        return StreamBuilder<List<SavedBook>>(
          stream: _db.watchAllSavedBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data ?? [];
            final savedBooks = wishlistState.filter != null
                ? data
                    .where((book) => book.collection == wishlistState.filter)
                    .toList()
                : data;

            if (savedBooks.isEmpty) {
              return Center(
                  child: Text(
                'No books in wishlist',
                style: TextStyle(color: Colors.white),
              ));
            }

            if (defaultTargetPlatform == TargetPlatform.android) {
              return ListView.builder(
                itemCount: savedBooks.length,
                itemBuilder: (context, index) {
                  final el = savedBooks[index];
                  final isSelected = wishlistState.selectedBookIds.contains(el.id) ||
                      librarySelected.contains(el.id);
                  final collectionName = collectionMap[el.collection] ?? "None";

                  return InkWell(
                    onTap: () {
                      if (isSelected) {
                        ref
                            .read(WishlistStateProvider.notifier)
                            .removeSelected(el.id);
                      } else {
                        ref.read(WishlistStateProvider.notifier).addSelected(el.id);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        border: Border(
                          bottom: BorderSide(color: Colors.white12, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  el.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  el.author,
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  collectionName,
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.download, color: Colors.blue),
                                onPressed: () {
                                  context.go("/download?search=${el.title}");
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _db.deleteSavedBook(el.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Author")),
                DataColumn(label: Text("Collection")),
                DataColumn(label: Text("Actions")),
              ],
              rows: savedBooks.map((el) {
                final isSelected = wishlistState.selectedBookIds.contains(el.id) ||
                    librarySelected.contains(el.id);
                final collectionName = collectionMap[el.collection] ?? "Placeholder";
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (selected == null) return;
                    if (selected) {
                      ref.read(WishlistStateProvider.notifier).addSelected(el.id);
                    } else {
                      ref
                          .read(WishlistStateProvider.notifier)
                          .removeSelected(el.id);
                    }
                  },
                  cells: [
                    DataCell(Text(el.title)),
                    DataCell(Text(el.author)),
                    DataCell(Text(collectionName)),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            context.go("/download?search=${el.title}");
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
