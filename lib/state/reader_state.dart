import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderState {
  final bool isReading;
  final bool showPomodoroTimer;
  ReaderState({
    this.isReading = false,
    this.showPomodoroTimer = true,
});

  ReaderState copyWith({
    bool? isReading,
    bool? showPomodoroTimer,
}){
    return ReaderState(
        isReading: isReading ?? this.isReading,
        showPomodoroTimer: showPomodoroTimer ?? this.showPomodoroTimer,
      );
  }
}

class ReaderStateNotifier extends Notifier<ReaderState>{
  @override
  ReaderState build() => ReaderState();

  void setIsReadingTrue(){
    state = state.copyWith(isReading: true);
  }
  void setIsReadingFalse(){
    state = state.copyWith(isReading: false);
  }

  void setShowPomodoroTrue(){
    state = state.copyWith(showPomodoroTimer: true);
  }
  void setShowPomodoroFalse(){
    state = state.copyWith(showPomodoroTimer: false);
  }
}

final readerStateProvider = NotifierProvider<ReaderStateNotifier, ReaderState>(ReaderStateNotifier.new);