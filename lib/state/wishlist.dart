import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistState {
  bool multi_select;
  int? filter;
  Set<int> selectedBookIds;
  WishlistState({
    this.multi_select = false,
    this.filter,
    this.selectedBookIds = const {},
  });

  WishlistState updateState({bool? multi_select_value, int? filter, Set<int>? selectedBookIds}) {
    return WishlistState(
      multi_select: multi_select_value ?? multi_select,
      filter: filter ?? this.filter,
      selectedBookIds: selectedBookIds ?? this.selectedBookIds,
    );
  }

  WishlistState setFilter({int? f}) {
    return WishlistState(
      multi_select: multi_select,
      filter: f,
      selectedBookIds: selectedBookIds,
    );
  }

 
}

class WishlistNotifier extends Notifier<WishlistState> {
  @override
  WishlistState build() => WishlistState();

  void toggleMultiSelect() {
    state = state.updateState(multi_select_value: !state.multi_select);
  }

  void setFilter(int? id) {
    state = state.setFilter(f: id);
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

final WishlistStateProvider = NotifierProvider<WishlistNotifier, WishlistState>(
  WishlistNotifier.new,
);
