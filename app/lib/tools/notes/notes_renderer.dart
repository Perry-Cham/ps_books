import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:ps_books/services/dbServices/notesToDB.dart';

final _notesDb = NotesToDB();

class NotesRenderer extends StatefulWidget {
  final int noteId;
  final VoidCallback onBack;

  const NotesRenderer({super.key, required this.noteId, required this.onBack});

  @override
  createState() => NotesRendererState();
}

class NotesRendererState extends State<NotesRenderer> {
  String? _title;
  String? _content;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await _notesDb.getSingleNote(widget.noteId);
    if (note == null || !mounted) return;
    setState(() {
      _title = note.title;
      _content = note.content;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_title ?? ''),
      ),
      body: SingleChildScrollView(
        child:Padding(
        padding: EdgeInsets.all(16),
        child: SmoothMarkdown(
          data: _content ?? '',
          selectable: true,
        ),
      ),
    ));
  }
}
