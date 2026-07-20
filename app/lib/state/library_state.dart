import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/models/library_item.dart';
import 'package:ps_books/dbs/database.dart';

BookToDb bookService = BookToDb();

enum SortOrder { dateAddedAsc, dateAddedDesc, nameAsc, nameDesc }
typedef LibrarySelectionId = ({int id, bool isSeries});

class LibraryState {
  bool multi_select;
  int? filter;
  Set<LibrarySelectionId> selectedBookIds;
  SortOrder sort;

  LibraryState({
    this.multi_select = false,
    this.filter,
    this.selectedBookIds = const {},
    this.sort = SortOrder.dateAddedDesc,
  });

  LibraryState updateState({
    bool? multi_select_value,
    int? filter,
    Set<LibrarySelectionId>? selectedBookIds,
    SortOrder? sort,
  }) {
    return LibraryState(
      multi_select: multi_select_value ?? multi_select,
      filter: filter,
      selectedBookIds: selectedBookIds ?? this.selectedBookIds,
      sort: sort ?? this.sort,
    );
  }
}

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() => LibraryState();

  void toggleMultiSelect() {
    state = state.updateState(multi_select_value: !state.multi_select);
  }

  void setSelectTrue() {
    state = state.updateState(multi_select_value: true);
  }

  void setSelectFalse() {
    state = state.updateState(multi_select_value: false);
  }

  void setFilter(int? id) {
    state = state.updateState(filter: id);
  }

  void setSort(SortOrder sort) {
    state = state.updateState(sort: sort);
  }

  void addSelected(LibrarySelectionId item) {
    state = state.updateState(selectedBookIds: {...state.selectedBookIds, item});
  }

  void removeSelected(LibrarySelectionId item) {
    final updatedSelection = Set<LibrarySelectionId>.from(state.selectedBookIds)..remove(item);
    if (updatedSelection.isEmpty) {
      state = state.updateState(
        selectedBookIds: updatedSelection,
        multi_select_value: false,
      );
      return;
    }
    state = state.updateState(selectedBookIds: updatedSelection);
  }

  void clearSelected() {
    state = state.updateState(selectedBookIds: {});
  }
}

final LibraryStateProvider =
    NotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);

final libraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  final filter = ref.watch(LibraryStateProvider.select((s) => s.filter));
  final sort = ref.watch(LibraryStateProvider.select((s) => s.sort));

  final booksStream = bookService.watchAllBooks();
  final seriesStream = bookService.watchAllSeries();

  return CombineLatestStream.combine2(
    booksStream,
    seriesStream,
    (List<Book> books, List<Sery> series) {
      var items = <LibraryItem>[
        ...books
            .where((b) => !b.isSeries)
            .map((b) => LibraryItem.fromBook(b)),
        ...series.map((s) {
          final seriesBooks =
              books.where((b) => b.series == s.id && !b.isSeries).toList();
          final coverPath = seriesBooks.isNotEmpty
              ? (seriesBooks.first.coverPath ?? s.cover)
              : s.cover;
          return LibraryItem.fromSeries(s, coverPath: coverPath);
        }),
      ];

      if (filter != null) {
        items = items.where((t) => t.collection == filter).toList();
      }

      switch (sort) {
        case SortOrder.dateAddedAsc:
          items.sort((a, b) =>
              (a.dateAdded ?? DateTime(0)).compareTo(b.dateAdded ?? DateTime(0)));
          break;
        case SortOrder.dateAddedDesc:
          items.sort((a, b) =>
              (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));
          break;
        case SortOrder.nameAsc:
          items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOrder.nameDesc:
          items.sort((a, b) => b.name.compareTo(a.name));
          break;
      }

      return items;
    },
  );
});
