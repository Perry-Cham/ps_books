import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/helpers/utils.dart';
import 'package:ps_books/state/wishlist.dart';
import 'dialogs.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Collection>>(
      stream: BookToDb().getCategories(),
      builder: (context, snapshot) {
        List<Widget>? data;
        if (snapshot.hasData) {
          data = snapshot.data!.map((el) {
            return ElevatedButton(
              onPressed: (){
                  ref.read(LibraryStateProvider.notifier).setFilter(el.id);
                  print("The filter is");
                  print(ref.read(LibraryStateProvider.notifier).state.filter);
              },
              child: Text(el.name),
            );
          }).toList();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: data != null
                ? [
                    ElevatedButton(
                      onPressed: (){
                          ref.read(LibraryStateProvider.notifier).setFilter(null);
                          print("The filter is");
                    print(ref.read(LibraryStateProvider.notifier).state.filter);
                      },
                      child: Text('All'),
                    ),
                    ...data,
                  ]
                : [
                    ElevatedButton(
                      onPressed: () => print("hello"),
                      child: Text('All'),
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class ControlBar extends ConsumerWidget {
  const ControlBar({super.key, required this.provider, this.wishlist = false});
  final NotifierProvider provider;
  final bool wishlist;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBookIds = ref.watch(
      provider.select((state) => (state as dynamic).selectedBookIds),
    );
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple[300]!.withValues(alpha: 0.4), width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            gradient: LinearGradient(
              colors: [
                Colors.purple[800]!.withValues(alpha: 0.65),
                Colors.purple[600]!.withValues(alpha: 0.45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10.0,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              try {
                if (wishlist) {
                  await deleteSavedBooks(booksToDelete: Set<int>.from(selectedBookIds));
                    ref.read(WishlistStateProvider.notifier).clearSelected();
                } else {
                  await _deleteLibraryItems(Set<({int id, bool isSeries})>.from(selectedBookIds));
                  ref.read(LibraryStateProvider.notifier).clearSelected();
                }
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
                builder: (context) => DeleteCollectionDialog(wishlist: wishlist),
              );
            },
            icon: Icon(Icons.folder_delete),
            label: Text("Delete Collection"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddToCollectionDialog(provider: provider, wishlist: wishlist),
              );
            },
            icon: Icon(Icons.add),
            label: Text("Add To Collection"),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class PopUpControls extends ConsumerWidget {
  const PopUpControls({super.key, required this.provider, this.wishlist = false});
  final NotifierProvider provider;
  final bool wishlist;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBookIds = ref.watch(
      provider.select((state) => (state as dynamic).selectedBookIds),
    );
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => _showSortDialog(context, ref),
          child: Row(
            spacing: 5,
            children: const [Icon(Icons.sort), Text('Sort')],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => DeleteCollectionDialog(wishlist: wishlist),
            );
          },
          child: Row(
            spacing: 5,
            children: const [Icon(Icons.delete), Text('Delete Collection')],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AddToCollectionDialog(provider: provider, wishlist: wishlist),
            );
          },
          child: Row(
            spacing: 5,
            children: const [Icon(Icons.add), Text('Add To Collection')],
          ),
        ),
        PopupMenuItem(
          onTap: () async  {
           for(var bookId in selectedBookIds){
              await BookToDb().removeCollection(bookId.id);
           }
          },
          child: Row(
            spacing: 5,
            children: const [Icon(Icons.remove), Text('Remove from Collection')],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            try {
              if (wishlist) {
                await deleteSavedBooks(booksToDelete: Set<int>.from(selectedBookIds));
                ref.read(WishlistStateProvider.notifier).clearSelected();
              } else {
                await _deleteLibraryItems(Set<({int id, bool isSeries})>.from(selectedBookIds));
                ref.read(LibraryStateProvider.notifier).clearSelected();
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Success"),
                    content: const Text("The operation completed successfully!"),
                  );
                },
              );
            } catch (e) {
              print(e);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: const Text("The operation failed!"),
                  );
                },
              );
            }
          },
          child: Row(
            spacing: 5,
            children: const [Icon(Icons.delete), Text('Delete')],
          ),
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(LibraryStateProvider.notifier).state.sort;
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sort by'),
        children: [
          for (final option in SortOrder.values)
            RadioListTile<SortOrder>(
              title: Text(_sortLabel(option)),
              value: option,
              groupValue: currentSort,
              onChanged: (val) {
                if (val != null) {
                  ref.read(LibraryStateProvider.notifier).setSort(val);
                  Navigator.pop(ctx);
                }
              },
            ),
        ],
      ),
    );
  }

  String _sortLabel(SortOrder order) {
    switch (order) {
      case SortOrder.dateAddedAsc:
        return 'Date added (oldest first)';
      case SortOrder.dateAddedDesc:
        return 'Date added (newest first)';
      case SortOrder.nameAsc:
        return 'Name (A–Z)';
      case SortOrder.nameDesc:
        return 'Name (Z–A)';
    }
  }
}

Future<void> _deleteLibraryItems(Set<({int id, bool isSeries})> selected) async {
  if (selected.isEmpty) return;
  final _db = BookToDb();
  await _db.deleteBooksBatch(selected);
  await _db.deleteSeriesBatch(selected);
}
