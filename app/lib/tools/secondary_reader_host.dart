import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ps_books/readers/reader.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import '../dbs/database.dart';

class SecondaryReaderHost extends StatefulWidget {
  const SecondaryReaderHost({
    super.key,
    required this.bookId,
    required this.secondaryKey,
    required this.immersiveController,
    required this.onClose,
  });

  final int bookId;
  final GlobalKey<ReaderWidgetState> secondaryKey;
  final ValueListenable<bool> immersiveController;
  final VoidCallback onClose;

  @override
  State<SecondaryReaderHost> createState() => _SecondaryReaderHostState();
}

class _SecondaryReaderHostState extends State<SecondaryReaderHost> {
  Book? _book;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final book = await BookToDb().getBookById(widget.bookId);
    if (mounted) {
      setState(() {
        _book = book;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_book == null) {
      return const Center(child: Text('Book not found'));
    }
    return Reader(
      key: widget.secondaryKey,
      type: _book!.extension,
      path: _book!.path,
      id: _book!.id,
      page: _book!.page,
      position: _book!.cfi,
      isSecondary: true,
      immersiveController: widget.immersiveController,
      onCloseSecondary: widget.onClose,
    );
  }
}
