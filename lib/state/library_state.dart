import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryState {
  bool multi_select;
  int? filter;
  Set<int> selectedBookIds;
  LibraryState({
    this.multi_select = false,
    this.filter,
    this.selectedBookIds = const {},
  });

  LibraryState updateState({bool? multi_select_value, int? filter, Set<int>? selectedBookIds}) {
    return LibraryState(
      multi_select: multi_select_value ?? this.multi_select,
      filter: filter ?? this.filter,
      selectedBookIds: selectedBookIds ?? this.selectedBookIds,
    );
  }


}

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() => LibraryState();

  void toggleMultiSelect() {
    state = state.updateState(multi_select_value: !state.multi_select);
  }

  void setFilter(int? id) {
    state = state.updateState(filter: id);
  }

  void addSelected(int id) {
    state = state.updateState(selectedBookIds: {...state.selectedBookIds, id});
  }

  void removeSelected(int id) {
    final updatedSelection = Set<int>.from(state.selectedBookIds)..remove(id);
    state = state.updateState(selectedBookIds: updatedSelection);
  }

  void clearSelected() {
    state = state.updateState(selectedBookIds: {});
  }
}

final LibraryStateProvider = NotifierProvider<LibraryNotifier, LibraryState>(
  LibraryNotifier.new,
);
