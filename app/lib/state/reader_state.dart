import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderState {
  final bool isReading;
  final bool showPomodoroTimer;
  final bool showAiChat;
  final int? secondBookId;
  ReaderState({
    this.isReading = false,
    this.showPomodoroTimer = false,
    this.showAiChat = false,
    this.secondBookId,
  });

  ReaderState copyWith({
    bool? isReading,
    bool? showPomodoroTimer,
    bool? showAiChat,
    int? secondBookId,
  }) {
    return ReaderState(
      isReading: isReading ?? this.isReading,
      showPomodoroTimer: showPomodoroTimer ?? this.showPomodoroTimer,
      showAiChat: showAiChat ?? this.showAiChat,
      secondBookId: secondBookId,
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
    state = state.copyWith(showAiChat: true, secondBookId: null);
  }

  void setShowAiChatFalse() {
    state = state.copyWith(showAiChat: false);
  }

  void setSecondBook(int id) {
    state = state.copyWith(secondBookId: id, showAiChat: false);
  }

  void clearSecondBook() {
    state = state.copyWith(secondBookId: null);
  }
}

final readerStateProvider =
    NotifierProvider<ReaderStateNotifier, ReaderState>(ReaderStateNotifier.new);
