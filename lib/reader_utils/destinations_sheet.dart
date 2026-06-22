import 'package:flutter/material.dart';

import 'reader_destination.dart';

/// A unified bottom sheet that renders a list of [ReaderDestination]s.
///
/// Each engine converts its native "bookmarks" (PDF outline, EPUB TOC,
/// MOBI TOC, FB2 chapter list, …) to `List<ReaderDestination>` and passes
/// them to [showDestinationsSheet]. When the user taps an entry, the sheet
/// invokes [onSelected] with that destination — the shell then forwards it
/// to the originating engine's `goToDestination`.
///
/// The sheet supports both flat lists (FB2 chapters) and nested trees (PDF
/// outline, EPUB TOC with sub-chapters). Nesting is rendered via expandable
/// `ExpansionTile`-style rows with indentation per [ReaderDestination.level].
Future<void> showDestinationsSheet({
  required BuildContext context,
  required Future<List<ReaderDestination>> Function() loader,
  required ValueChanged<ReaderDestination> onSelected,
  String title = 'Bookmarks',
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return FutureBuilder<List<ReaderDestination>>(
            future: loader(),
            builder: (dataContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SheetScaffold(
                  title: title,
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _SheetScaffold(
                  title: title,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load: ${snapshot.error}'),
                    ),
                  ),
                );
              }
              final destinations = snapshot.data ?? const <ReaderDestination>[];
              if (destinations.isEmpty) {
                return _SheetScaffold(
                  title: title,
                  body: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No bookmarks available for this document.'),
                    ),
                  ),
                );
              }
              return _SheetScaffold(
                title: title,
                body: _DestinationTree(
                  destinations: destinations,
                  controller: scrollController,
                  onSelected: (d) {
                    Navigator.of(dataContext).pop();
                    onSelected(d);
                  },
                ),
              );
            },
          );
        },
      );
    },
  );
}

/// Private scaffold that gives the sheet a sticky header + scrollable body.
class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.body});
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: body),
      ],
    );
  }
}

/// Recursive renderer for a list of [ReaderDestination]s.
///
/// Uses a single [ListView] with a flattened representation so that
/// expand/collapse state is local to each tile and the scroll controller
/// drives the whole sheet uniformly.
class _DestinationTree extends StatefulWidget {
  const _DestinationTree({
    required this.destinations,
    required this.controller,
    required this.onSelected,
  });

  final List<ReaderDestination> destinations;
  final ScrollController controller;
  final ValueChanged<ReaderDestination> onSelected;

  @override
  State<_DestinationTree> createState() => _DestinationTreeState();
}

class _DestinationTreeState extends State<_DestinationTree> {
  /// Set of locators whose subtree is currently expanded.
  final Set<String> _expanded = {};

  List<_FlatEntry> _flattened = const [];

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant _DestinationTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations != widget.destinations) _rebuild();
  }

  void _rebuild() {
    final out = <_FlatEntry>[];
    void walk(ReaderDestination d, int depth) {
      out.add(_FlatEntry(d, depth));
      if (d.children.isNotEmpty && _expanded.contains(d.locator)) {
        for (final c in d.children) {
          walk(c, depth + 1);
        }
      }
    }

    for (final d in widget.destinations) {
      walk(d, 0);
    }
    if (mounted) setState(() => _flattened = out);
  }

  void _toggle(ReaderDestination d) {
    setState(() {
      if (_expanded.contains(d.locator)) {
        _expanded.remove(d.locator);
      } else {
        _expanded.add(d.locator);
      }
      _rebuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      controller: widget.controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _flattened.length,
      itemBuilder: (_, i) {
        final entry = _flattened[i];
        final d = entry.destination;
        final hasChildren = d.children.isNotEmpty;
        final isExpanded = _expanded.contains(d.locator);
        return InkWell(
          onTap: () => widget.onSelected(d),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0 + entry.depth * 16, 12, 16, 12),
            child: Row(
              children: [
                if (hasChildren)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                    ),
                    onPressed: () => _toggle(d),
                    tooltip: isExpanded ? 'Collapse' : 'Expand',
                  )
                else
                  const SizedBox(width: 28),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    d.label,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FlatEntry {
  const _FlatEntry(this.destination, this.depth);
  final ReaderDestination destination;
  final int depth;
}
