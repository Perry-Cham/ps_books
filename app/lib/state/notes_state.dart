import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesState {
  int? filter;
  int? editingNoteId;
  int? readingNoteId;
  bool displayEditor;
  NotesState({
    this.filter,
    this.editingNoteId,
    this.readingNoteId,
    this.displayEditor = false,
  });

  NotesState copyWith({
    int? filter,
    int? editingNoteId,
    int? readingNoteId,
    bool? displayEditor,
  }) {
    return NotesState(
      filter: filter,
      editingNoteId: editingNoteId,
      readingNoteId: readingNoteId,
      displayEditor: displayEditor ?? this.displayEditor,
    );
  }
}

class NotesNotifier extends Notifier<NotesState> {
  @override
  NotesState build() => NotesState();

  void setFilter(int? id) {
    state = NotesState(
      filter: id,
      editingNoteId: state.editingNoteId,
      readingNoteId: state.readingNoteId,
    );
  }

  void startEditing(int noteId) {
    state = NotesState(
      filter: state.filter,
      editingNoteId: noteId,
      readingNoteId: null,
    );
  }

  void startReading(int noteId) {
    state = NotesState(
      filter: state.filter,
      editingNoteId: null,
      readingNoteId: noteId,
    );
  }

  void createNew() {
    state = state.copyWith(displayEditor: true);
  }

  void stopEditing() {
    state = NotesState(
      filter: state.filter,
      editingNoteId: null,
      readingNoteId: state.readingNoteId,
    );
  }

  void stopReading() {
    state = NotesState(
      filter: state.filter,
      editingNoteId: state.editingNoteId,
      readingNoteId: null,
    );
  }
}

final NotesStateProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);
