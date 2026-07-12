import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown_editor.dart';
import 'package:ps_books/services/dbServices/notesToDB.dart';

final _notesDb = NotesToDB();

class NotesEditor extends StatefulWidget {
  final int? noteId;
  final VoidCallback onBack;

  const NotesEditor({super.key, this.noteId, required this.onBack});

  @override
  createState() => NotesEditorState();
}

class NotesEditorState extends State<NotesEditor> {
  final titleController = TextEditingController();
  late MarkdownEditorController editorController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    editorController = MarkdownEditorController(
      text: '',
      historyLimit: 200,
    );
    if(widget.noteId == null){
      setState(() => _loaded = true);
      return;
    }
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await _notesDb.getSingleNote(widget.noteId!);
    if (note == null || !mounted) return;
    titleController.text = note.title;
    editorController.text = note.content;
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    titleController.dispose();
    editorController.dispose();
    super.dispose();
  }

  void _save() {
    if(widget.noteId == null){
    _notesDb.createNewNote(title: titleController.text, content: editorController.text);
    }
    _notesDb.editTitle(widget.noteId!, titleController.text);
    _notesDb.editContent(widget.noteId!, editorController.text);
    editorController.markSaved();
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
          onPressed: () {
            _save();
            widget.onBack();
          },
        ),
        title: TextField(
          controller: titleController,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Title',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          onChanged: (_) => _save(),
        ),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: Icon(Icons.save_outlined),
            onPressed: _save,
          ),
        ],
      ),
      body: SmoothMarkdownEditor(
        controller: editorController,
        mode: MarkdownEditorMode.formatted,
        wikilinkSuggestions: const ['Daily Notes', 'Project Plan'],
        toolbarCommands: const [
          MarkdownEditorCommand.bold,
          MarkdownEditorCommand.italic,
          MarkdownEditorCommand.link,
          MarkdownEditorCommand.image,
          MarkdownEditorCommand.codeBlock,
          MarkdownEditorCommand.table,
        ],
        toolbarTrailing: [
          IconButton(
            tooltip: 'Save',
            icon: Icon(Icons.save_outlined),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
