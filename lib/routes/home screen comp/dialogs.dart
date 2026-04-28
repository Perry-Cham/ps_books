import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ps_books/services/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/dbs/database.dart';
import './utils.dart';

final bookService = BookToDb();

class DeleteCollectionDialog extends StatefulWidget {
  @override
  State<DeleteCollectionDialog> createState() => _DeleteCollectionDialogState();
}

class _DeleteCollectionDialogState extends State<DeleteCollectionDialog> {
  int? _selectedCollectionId;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Collection'),
      content: StreamBuilder<List<Collection>>(
        stream: BookToDb().getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final collections = snapshot.data ?? [];
          if (collections.isEmpty) {
            return const Text('No collections available.');
          }
        
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: RadioGroup<int>(
              groupValue: _selectedCollectionId, // Current selected value
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCollectionId = newValue;
                });
              },
              child: Column(
                // Any layout widget
                children: collections.map((t) {
                  return Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Radio(value: t.id),
                        Text(t.name),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedCollectionId == null
              ? null
              : () async {
                  setState(() {
                    loading = true;
                  });
                  final selectedId = _selectedCollectionId!;
                  await bookService.deleteCollection(selectedId);

                  if (mounted && loading == false) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Deleted'),
                        content: const Text('The collection was deleted.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
          child: loading ? CircularProgressIndicator() : const Text('Delete'),
        ),
      ],
    );
  }
}

class AddToCollectionDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddToCollectionDialog> createState() =>
      _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends ConsumerState<AddToCollectionDialog> {
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final selectedBookIds = ref.read(
      LibraryStateProvider.select((state) => state.selectedBookIds),
    );
    final category = _categoryController.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (selectedBookIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select books first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      int? collectionId;
      for (var id in selectedBookIds) {
        await addToCollection(category, id);
      }

      ref.read(LibraryStateProvider.notifier).clearSelected();

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Books added to collection successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add books: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: 'Enter collection name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}


