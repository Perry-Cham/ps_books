import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryState {
  bool multi_select;
  int? filter;
  List<int> selectedBookIds;
  LibraryState({
    this.multi_select = false,
    this.filter,
    this.selectedBookIds = const [],
  });

  LibraryState updateState({bool? multi_select_value}) {
    return LibraryState(
      multi_select: multi_select_value ?? multi_select,
      filter: filter,
      selectedBookIds: selectedBookIds,
    );
  }

  LibraryState setFilter({int? f}) {
    return LibraryState(
      multi_select: multi_select,
      filter: f,
      selectedBookIds: selectedBookIds,
    );
  }

  LibraryState updateSelected(List<int> newSelected) {
    return LibraryState(
      multi_select: multi_select,
      filter: filter,
      selectedBookIds: newSelected,
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
    state = state.setFilter(f: id);
  }

  void addSelected(int id) {
    if (!state.selectedBookIds.contains(id)) {
      state = state.updateSelected([...state.selectedBookIds, id]);
    }
  }

  void removeSelected(int id) {
    state = state.updateSelected(
      state.selectedBookIds.where((element) => element != id).toList(),
    );
  }

  void clearSelected() {
    state = state.updateSelected([]);
  }
}

final LibraryStateProvider = NotifierProvider<LibraryNotifier, LibraryState>(
  LibraryNotifier.new,
);
