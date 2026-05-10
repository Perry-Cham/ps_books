import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/routes/home%20comp/control_bars.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/wishlist.dart';

final _db = DBProvider().db;

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        children: [
          FilterBar(),
          ControlBar(provider: WishlistStateProvider,),
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
          final savedBooks = wishlistState.filter != null
              ? data
                  .where((book) => book.collection == wishlistState.filter)
                  .toList()
              : data;

          if (savedBooks.isEmpty) {
            return Center(child: Text('No books in wishlist'));
          }

          final isDesktop = MediaQuery.of(context).size.width > 600;
          final crossAxisCount = isDesktop ? 5 : 2;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: savedBooks.length,
            itemBuilder: (context, index) {
              final book = savedBooks[index];
              return SavedBookCard(
                name: book.title,
                author: book.author,
              );
            },
          );
        },
      ),
    );
  }
}

class SavedBookCard extends StatelessWidget{
  const SavedBookCard({super.key, 
    required this.name,
    required this.author,
  });

  final String name;
  final String author;
  @override
  Widget build(BuildContext context) {
   return Card(
    child: Column(
      children: [
        Text(name),
        Text(author)
      ],
    ),
   );

  }
}