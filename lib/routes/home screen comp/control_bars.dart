import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/dbs/database.dart';
import './utils.dart';
import './dialogs.dart';


class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _library_state = ref.watch(LibraryStateProvider);
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBookIds = ref.watch(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await deleteBooks(selectedBookIds);
              ref.read(LibraryStateProvider.notifier).clearSelected();
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
              builder: (context) => DeleteCollectionDialog(),
            );
          },
          icon: Icon(Icons.folder_delete),
          label: Text("Delete Collection"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddToCollectionDialog(),
            );
          },
          icon: Icon(Icons.add),
          label: Text("Add To Collection"),
        ),
      ],
    );
  }
}
