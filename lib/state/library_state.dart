import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryState {
  bool multi_select;
  LibraryState({this.multi_select = false});

  updateState({bool? multi_select_value}) {
    return LibraryState(multi_select: multi_select_value ?? this.multi_select);
  }
}


class LibraryNotifier extends Notifier<LibraryState>{
  @override LibraryState build() => LibraryState();

  void toggleMultiSelect(){
    state  = state.updateState(multi_select_value: !state.multi_select);
  }
}

final LibraryStateProvider = NotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);