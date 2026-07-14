import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/state/library_state.dart';
import 'package:ps_books/state/wishlist.dart';
import 'package:ps_books/dbs/database.dart';

final bookService = BookToDb();

class DeleteCollectionDialog extends StatefulWidget {
  const DeleteCollectionDialog({super.key, this.wishlist = false});

  final bool wishlist;

  @override
  State<DeleteCollectionDialog> createState() => _DeleteCollectionDialogState();
}

class _DeleteCollectionDialogState extends State<DeleteCollectionDialog> {
  final List<int> _selectedCollections = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Collection'),
      content: StreamBuilder<List<Collection>>(
        stream: widget.wishlist
            ? BookToDb().getSavedCategories()
            : BookToDb().getCategories(),
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
            child: Column(
              spacing: 10,
              children: collections.map((t) {
                return CheckboxListTile(
                  title: Text(t.name),
                  value: _selectedCollections.contains(t.id),
                  onChanged: (val) {
                    if (val != null && val) {
                      setState(() {
                        _selectedCollections.add(t.id);
                      });
                    } else {
                      setState(() {
                        _selectedCollections.remove(t.id);
                      });
                    }
                  },
                );
              }).toList(),
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
          onPressed: _selectedCollections.isEmpty
              ? null
              : () async {
                  setState(() {
                    loading = true;
                  });
                  for (var selectedId in _selectedCollections) {
                    await bookService.deleteCollection(selectedId);
                  }

                  if (mounted) {
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


enum DialogView { main, existing }

class AddToCollectionDialog extends ConsumerStatefulWidget {
  const AddToCollectionDialog({
    super.key,
    required this.provider,
    this.wishlist = false,
  });

  final NotifierProvider provider;
  final bool wishlist;

  @override
  ConsumerState<AddToCollectionDialog> createState() => _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends ConsumerState<AddToCollectionDialog> {
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  DialogView _currentView = DialogView.main; // Tracks which layout view we are on

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // --- Submits the New Category Creation ---
  Future<void> _submitNewCategory() async {
    final selectedBookIds = ref.read(widget.provider.select((state) => state.selectedBookIds)) as Set<int>;
    final category = _categoryController.text.trim();

    if (category.isEmpty || selectedBookIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      int collectionId = await BookToDb().addCollection(
        category,
        isSavedCollection: widget.wishlist,
      );
      await _updateBooksAndClose(selectedBookIds, collectionId);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Submits to an Existing Category Selection ---
  Future<void> _selectExistingCategory(Set<int> books, int collectionId) async {
    setState(() => _isLoading = true);
    try {
      await _updateBooksAndClose(books, collectionId);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Common Logic helper to finish database update and close dialog ---
  Future<void> _updateBooksAndClose(Set<int> selectedBookIds, int collectionId) async {
    for (var id in selectedBookIds) {
      if (widget.wishlist) {
        await BookToDb().setSavedBookCollection(id, collectionId);
      } else {
        await BookToDb().setBookCollection(id, collectionId);
      }
    }

    if (widget.wishlist) {
      ref.read(WishlistStateProvider.notifier).clearSelected();
    } else {
      ref.read(LibraryStateProvider.notifier).clearSelected();
    }

    if (mounted) {
      Navigator.pop(context); // Closes the single modal cleanly
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Books added to collection successfully!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to add books: $message'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.read(widget.provider.select((s) => s.selectedBookIds)) as Set<int>;

    return AlertDialog(
      // Dynmically switch titles based on the view state
      title: Text(_currentView == DialogView.main ? 'Add to Collection' : 'Select Existing Collection'),
      content: SizedBox(
        width: 500,
        height: 280, // Explicit layout bounds for our list view switcher
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250), // Smooth transition animation
          child: _currentView == DialogView.main
          ? _buildMainView()
          : _buildExistingView(books),
        ),
      ),
      actions: [
        // Dynamic back or cancel button setup
        TextButton(
          onPressed: () {
            if (_currentView == DialogView.existing) {
              setState(() => _currentView = DialogView.main); // Just step backwards inline
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(_currentView == DialogView.existing ? 'Back' : 'Cancel'),
        ),
        if (_currentView == DialogView.main)
          FilledButton(
            onPressed: _isLoading ? null : _submitNewCategory,
            child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Add'),
          ),
      ],
    );
  }

  // VIEW 1: Input text panel for generating new tags
  Widget _buildMainView() {
    return Column(
      key: const ValueKey('MainView'), // Essential key for AnimatedSwitcher tracking
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.folder_open),
          label: const Text("Choose from existing"),
          onPressed: () => setState(() => _currentView = DialogView.existing),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            hintText: 'Enter new collection name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          enabled: !_isLoading,
        ),
      ],
    );
  }

  // VIEW 2: Streams existing categories into a selection view
  Widget _buildExistingView(Set<int> books) {
    return StreamBuilder<List<Collection>>(
      key: const ValueKey('ExistingView'),
      stream: BookToDb().getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(child: Text("No collections found. Create a new one!"));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data[index].name),
              contentPadding: EdgeInsets.zero,
              trailing: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: () => _selectExistingCategory(books, data[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
