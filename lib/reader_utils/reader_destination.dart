import 'package:flutter/foundation.dart';

/// A lingua-franca model representing a navigable destination inside a book.
///
/// Each reader engine (EPUB, PDF, MOBI, FB2, …) converts its own native
/// representation of "bookmarks" / "outline" / "table of contents" / "chapter
/// list" into a list of [ReaderDestination]s. The [ReaderShell] then renders
/// them in a single unified bottom sheet and, when the user taps one, calls
/// the originating engine's [DestinationCapable.goToDestination].
///
/// The [locator] is an opaque, engine-specific string. It is the engine's
/// responsibility to round-trip it losslessly. Examples:
///   - EPUB (katbook): a CFI string from `ChapterNode`
///   - PDF  (pdfrx):   a page number encoded as a string, or a `PdfDest`
///                     serialised via its `toString()` (engine decides)
///   - MOBI (foliate): a CFI string from `view.lastLocation.cfi` / TOC href
///   - FB2:            the chapter id encoded as a string
///
/// The [children] field allows engines that have a nested outline (PDF, EPUB)
/// to express the tree directly; flat lists (FB2 chapters) just leave it
/// empty.
@immutable
class ReaderDestination {
  const ReaderDestination({
    required this.label,
    required this.locator,
    this.level = 0,
    this.children = const [],
  });

  /// Human-readable title shown in the destinations sheet.
  final String label;

  /// Engine-specific opaque locator string. Round-tripped back to the same
  /// engine via [DestinationCapable.goToDestination].
  final String locator;

  /// Nesting depth (0 = top-level). Used by the renderer for indentation
  /// when the engine does not pre-flatten the tree.
  final int level;

  /// Sub-destinations, if any. Empty for flat lists.
  final List<ReaderDestination> children;

  ReaderDestination copyWith({
    String? label,
    String? locator,
    int? level,
    List<ReaderDestination>? children,
  }) =>
      ReaderDestination(
        label: label ?? this.label,
        locator: locator ?? this.locator,
        level: level ?? this.level,
        children: children ?? this.children,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderDestination &&
          other.label == label &&
          other.locator == locator &&
          other.level == level &&
          listEquals(other.children, children));

  @override
  int get hashCode => Object.hash(label, locator, level, Object.hashAll(children));

  @override
  String toString() =>
      'ReaderDestination(label: $label, locator: $locator, level: $level, '
      'children: ${children.length})';
}

/// Contract every reader engine implements so the [ReaderShell] can request
/// the document's destinations and navigate to one.
///
/// Engines expose this via their `State` class (looked up through a
/// `GlobalKey` held by the shell). The shell never inspects the [locator]
/// string; it just hands it back to the engine.
///
/// Implementations MUST be cheap to call repeatedly — the shell may call
/// [getDestinations] every time the user opens the destinations sheet.
abstract class DestinationCapable {
  /// Returns the document's navigable destinations as a flat-or-tree list of
  /// [ReaderDestination]s. Returns an empty list if the document has no
  /// outline / TOC / chapter list.
  Future<List<ReaderDestination>> getDestinations();

  /// Navigates the reader to [destination]. The [destination.locator] is the
  /// same string the engine produced in [getDestinations].
  Future<void> goToDestination(ReaderDestination destination);
}

/// Look up the [DestinationCapable] interface on a `State` via its
/// `GlobalKey`. Returns `null` if the key is not mounted or the state does
/// not implement the interface.
DestinationCapable? destinationCapableOf(GlobalKey<State<StatefulWidget>>? key) {
  final state = key?.currentState;
  if (state is DestinationCapable) return state;
  return null;
}
