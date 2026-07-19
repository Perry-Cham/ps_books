import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/readers/reader_shell.dart';
import 'package:ps_books/state/reader_state.dart';

final _db = BookToDb();

class SeriesViewHome extends ConsumerStatefulWidget {
  final Sery series;
  final String? coverPath;

  const SeriesViewHome({
    super.key,
    required this.series,
    this.coverPath,
  });

  @override
  ConsumerState<SeriesViewHome> createState() => _SeriesViewHomeState();
}

class _SeriesViewHomeState extends ConsumerState<SeriesViewHome> {
  bool _isGridView = true;
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    _isGridView = isWide;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.series.name),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSelected(),
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSeries(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addToSeries(),
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: _db.watchAllBooks(),
        builder: (context, snapshot) {
          final books = snapshot.data
              ?.where((b) => b.series == widget.series.id && !b.isSeries)
              .toList() ?? [];

          final coverPath = widget.coverPath ?? widget.series.cover;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (coverPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: coverPath.startsWith('http')
                              ? Image.network(
                                  coverPath,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _coverFallback(),
                                )
                              : Image.file(
                                  File(coverPath),
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _coverFallback(),
                                ),
                        )
                      else
                        _coverFallback(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.series.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.series.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.series.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              '${books.length} books',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildProgressBar(books),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (books.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No books in this series yet'),
                  )),
                )
              else if (_isGridView)
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 200 / 300,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBookCard(books[index]),
                    childCount: books.length,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBookTile(books[index]),
                    childCount: books.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(List<Book> books) {
    if (books.isEmpty) return const SizedBox();
    final completed = books.where((b) => b.progress >= 1.0).length;
    final pct = completed / books.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(pct * 100).toStringAsFixed(0)}% complete ($completed/${books.length})',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book) {
    final isSelected = _selectedIds.contains(book.id);
    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(book.id);
          } else {
            _selectedIds.add(book.id);
          }
        });
      },
      onTap: () {
        if (_selectedIds.isNotEmpty) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(book.id);
            } else {
              _selectedIds.add(book.id);
            }
          });
        } else {
          ref.read(readerStateProvider.notifier).setIsReadingTrue();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderShell(
                path: book.path,
                type: book.extension,
                id: book.id,
                page: book.page,
                position: book.cfi,
              ),
            ),
          );
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Colors.deepPurple.shade600, width: 3)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: book.coverPath != null
                  ? Image.file(
                      File(book.coverPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _gradientFallback(),
                    )
                  : _gradientFallback(),
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
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                book.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.deepPurple, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTile(Book book) {
    final isSelected = _selectedIds.contains(book.id);
    return ListTile(
      leading: book.coverPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(book.coverPath!),
                width: 40,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.book),
              ),
            )
          : const Icon(Icons.book),
      title: Text(book.name),
      subtitle: Text('${(book.progress * 100).toStringAsFixed(0)}% read'),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.deepPurple)
          : null,
      onTap: () {
        if (_selectedIds.isNotEmpty) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(book.id);
            } else {
              _selectedIds.add(book.id);
            }
          });
        } else {
          ref.read(readerStateProvider.notifier).setIsReadingTrue();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderShell(
                path: book.path,
                type: book.extension,
                id: book.id,
                page: book.page,
                position: book.cfi,
              ),
            ),
          );
        }
      },
      onLongPress: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(book.id);
          } else {
            _selectedIds.add(book.id);
          }
        });
      },
    );
  }

  void _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete selected?'),
        content: Text('${_selectedIds.length} books will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in _selectedIds) {
        await _db.deleteBook(id);
      }
      setState(() => _selectedIds.clear());
    }
  }

  void _editSeries() async {
    final nameController = TextEditingController(text: widget.series.name);
    final descController = TextEditingController(text: widget.series.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Series'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Series Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _db.updateSeries(
        widget.series.id,
        name: nameController.text,
        description: descController.text,
      );
    }
  }

  void _addToSeries() async {
    final allBooks = await _db.getAllBooks();
    final notInSeries = allBooks.where((b) => b.series == null || b.series != widget.series.id).toList();

    if (!context.mounted) return;

    final selected = await showDialog<List<Book>>(
      context: context,
      builder: (_) => _AddBooksDialog(books: notInSeries),
    );

    if (selected != null) {
      for (final book in selected) {
        await _db.addBook(
          name: book.name,
          author: book.author,
          path: book.path,
          extension: book.extension,
          coverPath: book.coverPath,
          series: widget.series.id,
        );
      }
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 800) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _coverFallback() {
    return Container(
      width: 120,
      height: 180,
      color: Colors.grey.shade800,
      child: const Icon(Icons.collections_bookmark, size: 48, color: Colors.white54),
    );
  }

  Widget _gradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey.shade900, Colors.grey.shade900],
        ),
      ),
    );
  }
}

class _AddBooksDialog extends StatefulWidget {
  final List<Book> books;
  const _AddBooksDialog({required this.books});

  @override
  State<_AddBooksDialog> createState() => _AddBooksDialogState();
}

class _AddBooksDialogState extends State<_AddBooksDialog> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Books to Series'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView(
          children: widget.books.map((book) => CheckboxListTile(
            title: Text(book.name),
            subtitle: Text(book.author ?? ''),
            value: _selected.contains(book.id),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selected.add(book.id);
                } else {
                  _selected.remove(book.id);
                }
              });
            },
          )).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final selectedBooks = widget.books.where((b) => _selected.contains(b.id)).toList();
            Navigator.pop(context, selectedBooks);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
