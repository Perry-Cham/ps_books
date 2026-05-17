import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/helpers/utils.dart';
import 'package:ps_books/state/wishlist.dart';
import 'dialogs.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(LibraryStateProvider);
    return StreamBuilder<List<Collection>>(
      stream: BookToDb().getCategories(),
      builder: (context, snapshot) {
        List<Widget>? data;
        if (snapshot.hasData) {
          data = snapshot.data!.map((el) {
            return ElevatedButton(
              onPressed: () =>
                  ref.read(LibraryStateProvider.notifier).setFilter(el.id),
              child: Text(el.name),
            );
          }).toList();
        }

        return Row(
          spacing: 10,
          children: data != null
              ? [
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(LibraryStateProvider.notifier).setFilter(null),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple[800]!, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Colors.purple[800]!,
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
                  await deleteSavedBooks(booksToDelete: selectedBookIds);
                    ref.read(WishlistStateProvider.notifier).clearSelected();
                } else {
                  await deleteBooks(selectedBookIds);
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
    // TODO: implement build
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => DeleteCollectionDialog(wishlist: wishlist),
            );
          },
          child: Row(
            spacing: 5,
            children: [Icon(Icons.delete), Text('Delete Collection')],
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
            children: [Icon(Icons.add), Text('Add To Collection')],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            try {
              if (wishlist) {
                await deleteSavedBooks(booksToDelete: selectedBookIds);
                ref.read(WishlistStateProvider.notifier).clearSelected();
              } else {
                await deleteBooks(selectedBookIds);
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
          child: Row(
            spacing: 5,
            children: [Icon(Icons.delete), Text('Delete')],
          ),
        ),
      ],
    );
  }
}
