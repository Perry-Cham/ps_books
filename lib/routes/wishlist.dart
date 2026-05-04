import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/state/library_state.dart';

final _db = DBProvider().db;

class Wishlist extends ConsumerWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.black),
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
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        children: [
          FilterBar(),
          SavedBooksTable(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showAddBookDialog(context),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.add),
                    Text(
                      'Add Book',
                      style: TextStyle(color: Colors.black),
                    ),
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
        title: Text('Add Book to Wishlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty) {
                await _db.into(_db.savedBooks).insert(
                  SavedBooksCompanion(
                    title: Value(titleController.text),
                    author: Value(authorController.text),
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Book added to wishlist'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
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
    final libraryState = ref.watch(LibraryStateProvider);

    return StreamBuilder<List<Collection>>(
      stream: _db.select(_db.collections).watch(),
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
                  selected: libraryState.filter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(LibraryStateProvider.notifier).setFilter(null);
                    }
                  },
                ),
              ),
              ...collections.map((collection) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(collection.name),
                    selected: libraryState.filter == collection.id,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(LibraryStateProvider.notifier)
                            .setFilter(collection.id);
                      }
                    },
                  ),
                );
              }).toList(),
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
    final libraryState = ref.watch(LibraryStateProvider);

    return Expanded(
      child: StreamBuilder<List<SavedBook>>(
        stream: _db.watchAllSavedBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];
          final savedBooks = libraryState.filter != null
              ? data
                  .where((book) => book.collection == libraryState.filter)
                  .toList()
              : data;

          if (savedBooks.isEmpty) {
            return Center(child: Text('No books in wishlist'));
          }

          return SingleChildScrollView(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Author')),
                DataColumn(label: Text('Actions')),
              ],
              rows: savedBooks.map((book) {
                return DataRow(
                  cells: [
                    DataCell(Text(book.title)),
                    DataCell(Text(book.author)),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _db.deleteSavedBook(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Book removed from wishlist'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}