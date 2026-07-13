import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderState {
  final bool isReading;
  final bool showPomodoroTimer;
  final bool showAiChat;
  final int? secondBookId;
  final bool showNotes;
  ReaderState({
    this.isReading = false,
    this.showPomodoroTimer = false,
    this.showAiChat = false,
    this.secondBookId,
    this.showNotes = false,
  });

  ReaderState copyWith({
    bool? isReading,
    bool? showPomodoroTimer,
    bool? showAiChat,
    int? secondBookId,
    bool? showNotes,
  }) {
    return ReaderState(
      isReading: isReading ?? this.isReading,
      showPomodoroTimer: showPomodoroTimer ?? this.showPomodoroTimer,
      showAiChat: showAiChat ?? this.showAiChat,
      secondBookId: secondBookId,
      showNotes: showNotes ?? this.showNotes,
    );
  }
}

class ReaderStateNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => ReaderState();

  void setIsReadingTrue() {
    state = state.copyWith(isReading: true);
  }

  void setIsReadingFalse() {
    state = state.copyWith(isReading: false);
  }

  void setShowPomodoroTrue() {
    state = state.copyWith(showPomodoroTimer: true);
  }

  void setShowPomodoroFalse() {
    state = state.copyWith(showPomodoroTimer: false);
  }

  void setShowAiChatTrue() {
    state = state.copyWith(
      showAiChat: true,
      secondBookId: null,
      showNotes: false,
    );
  }

  void setShowAiChatFalse() {
    state = state.copyWith(showAiChat: false);
  }

  void setSecondBook(int id) {
    state = state.copyWith(
      secondBookId: id,
      showAiChat: false,
      showNotes: false,
    );
  }

  void clearSecondBook() {
    state = state.copyWith(secondBookId: null);
  }

  void setShowNotesTrue() {
    state = state.copyWith(
      showNotes: true,
      showAiChat: false,
      secondBookId: null,
    );
  }

  void setShowNotesFalse() {
    state = state.copyWith(showNotes: false);
  }

  void closeSecondScreen() {
    state = state.copyWith(
      showNotes: false,
      showAiChat: false,
      secondBookId: null,
    );
  }
}

final readerStateProvider = NotifierProvider<ReaderStateNotifier, ReaderState>(
  ReaderStateNotifier.new,
);
