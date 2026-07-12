import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/dbServices/notesToDB.dart';
import 'package:ps_books/state/notes_state.dart';
import './notes_editor.dart';
import './notes_renderer.dart';

final _notesDb = NotesToDB();

class Notes extends ConsumerWidget {
  final int? bookId;

  const Notes({super.key, this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(NotesStateProvider);

    return Stack(
      children: [
        _NotesList(bookId: bookId),
        if (notesState.editingNoteId != null || notesState.displayEditor)
          NotesEditor(
            noteId: notesState.editingNoteId!,
            onBack: () => ref.read(NotesStateProvider.notifier).stopEditing(),
          ),
        if (notesState.readingNoteId != null)
          NotesRenderer(
            noteId: notesState.readingNoteId!,
            onBack: () => ref.read(NotesStateProvider.notifier).stopReading(),
          ),
      ],
    );
  }
}

class _NotesList extends ConsumerWidget {
  final int? bookId;

  const _NotesList({this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(NotesStateProvider);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        children: [
          _FilterBar(),
          Expanded(
            child: bookId != null
                ? _buildBookNotesStream(bookId!)
                : _buildAllNotesStream(notesState.filter),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: () async {
                  final id = await _notesDb.createNewNote(
                    title: 'New Note',
                    bookId: bookId,
                    collection: notesState.filter,
                  );
                  ref.read(NotesStateProvider.notifier).startEditing(id);
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllNotesStream(int? filter) {
    return StreamBuilder<List<Note>>(
      stream: _notesDb.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? [];
        final notes = filter != null
            ? data.where((n) => n.collection == filter).toList()
            : data;
        if (notes.isEmpty) {
          return Center(child: Text("You haven't created any notes"));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteTile(note: notes[index]),
        );
      },
    );
  }

  Widget _buildBookNotesStream(int bookId) {
    return StreamBuilder<List<Note>>(
      stream: _notesDb.getNotesByBookId(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return Center(child: Text("You haven't created any notes"));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteTile(note: notes[index]),
        );
      },
    );
  }
}

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(NotesStateProvider);
    final db = NotesToDB();

    return StreamBuilder<List<Collection>>(
      stream: db.getAllNoteCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        final collections = snapshot.data ?? [];
        return Row(
          children: [
            ActionChip(
              label: Text('All'),
              backgroundColor: notesState.filter == null ? Colors.blue : null,
              labelStyle: TextStyle(
                color: notesState.filter == null ? Colors.white : null,
              ),
              onPressed: () {
                ref.read(NotesStateProvider.notifier).setFilter(null);
              },
            ),
            SizedBox(width: 10),
            PopupMenuButton<int?>(
              initialValue: notesState.filter,
              onSelected: (int? value) {
                ref.read(NotesStateProvider.notifier).setFilter(value);
              },
              constraints: BoxConstraints(maxHeight: 300),
              itemBuilder: (BuildContext context) {
                return collections.map((collection) {
                  return PopupMenuItem<int>(
                    value: collection.id,
                    child: Text(collection.name),
                  );
                }).toList();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).popupMenuTheme.color,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notesState.filter == null || collections.isEmpty
                          ? 'Filter by Collection'
                          : collections
                              .firstWhere(
                                (c) => c.id == notesState.filter,
                                orElse: () => collections.first,
                              )
                              .name,
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoteTile extends ConsumerWidget {
  final Note note;

  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(note.title),
      onTap: () {
        ref.read(NotesStateProvider.notifier).startReading(note.id);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              ref.read(NotesStateProvider.notifier).startEditing(note.id);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await _notesDb.deleteNote(note.id);
            },
          ),
        ],
      ),
    );
  }
}
