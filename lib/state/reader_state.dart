import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderState {
  final bool isReading;
  ReaderState({
    this.isReading = false,
});
}

class ReaderStateNotifier extends Notifier<ReaderState>{
  @override
  ReaderState build() => ReaderState();

  void setIsReadingTrue(){
    state = ReaderState(isReading: true);
  }
  void setIsReadingFalse(){
    state = ReaderState(isReading: false);
  }
}

final ReaderStateProvider = NotifierProvider<ReaderStateNotifier, ReaderState>(ReaderStateNotifier.new);