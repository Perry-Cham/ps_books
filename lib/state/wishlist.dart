import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistState {
  bool multi_select;
  int? filter;
  List<int> selectedBookIds;
  WishlistState({
    this.multi_select = false,
    this.filter,
    this.selectedBookIds = const [],
  });

  WishlistState updateState({bool? multi_select_value}) {
    return WishlistState(
      multi_select: multi_select_value ?? multi_select,
      filter: filter,
      selectedBookIds: selectedBookIds,
    );
  }

  WishlistState setFilter({int? f}) {
    return WishlistState(
      multi_select: multi_select,
      filter: f,
      selectedBookIds: selectedBookIds,
    );
  }

  WishlistState updateSelected(List<int> newSelected) {
    return WishlistState(
      multi_select: multi_select,
      filter: filter,
      selectedBookIds: newSelected,
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

final WishlistStateProvider = NotifierProvider<WishlistNotifier, WishlistState>(
  WishlistNotifier.new,
);
