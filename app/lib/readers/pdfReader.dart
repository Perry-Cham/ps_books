import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ps_books/reader_utils/reader_destination.dart';
import 'package:ps_books/services/settings/reader-preferences.dart';
import 'package:synchronized/extension.dart';

class PDF extends ConsumerStatefulWidget {
  const PDF({
    super.key,
    required this.path,
    required this.controller,
    required this.page,
    this.immersiveController,
  });

  final String path;
  final PdfViewerController controller;
  final int page;

  /// Optional immersive-mode notifier owned by the [ReaderShell].
  ///
  /// When provided, the page-count overlay slides out of view whenever
  /// this notifier's value is `true`. When `null`, the overlay is always
  /// visible (no immersive mode).
  final ValueListenable<bool>? immersiveController;

  @override
  ConsumerState<PDF> createState() => _PDFState();
}

class _PDFState extends ConsumerState<PDF>
    with TickerProviderStateMixin
    implements DestinationCapable {
  List<PdfOutlineNode> outline = [];
  double? initialZoom;

  /// Drawer tab controller (search tab retained as a secondary access path;
  /// the primary TOC is now exposed via [getDestinations] to the shell).
  late TabController drawerTabController;

  /// Animation controller that drives the slide-in/out of the page-count
  /// overlay. Driven by [widget.immersiveController] when provided.
  late final AnimationController _overlaySlideController;
  late final Animation<Offset> _overlaySlide;

  @override
  void initState() {
    super.initState();

    drawerTabController = TabController(length: 2, vsync: this);

    _overlaySlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _overlaySlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(CurvedAnimation(
      parent: _overlaySlideController,
      curve: Curves.easeInOut,
    ));

    widget.immersiveController?.addListener(_onImmersiveChanged);
    // Apply the initial value synchronously.
    if (widget.immersiveController?.value == true) {
      _overlaySlideController.value = 1.0;
    }

    // Fetch User Zoom Preferences
    ref
        .read(pdfPrefsProvider.future)
        .then((prefs) {
          setState(() {
            initialZoom = prefs.zoom;
          });
        })
        .catchError((_) {});
  }

  void _onImmersiveChanged() {
    final isImmersive = widget.immersiveController?.value ?? false;
    if (isImmersive) {
      _overlaySlideController.forward();
    } else {
      _overlaySlideController.reverse();
    }
  }

  @override
  void dispose() {
    widget.immersiveController?.removeListener(_onImmersiveChanged);
    _overlaySlideController.dispose();
    drawerTabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DestinationCapable — lingua franca for the reader shell
  // ---------------------------------------------------------------------------

  /// Maps the pdfrx outline tree to [ReaderDestination]s.
  ///
  /// The locator is a slash-separated path of child indices (e.g. `"0/2/1"`),
  /// which [goToDestination] walks to recover the same `PdfOutlineNode`
  /// instance and call `controller.goToDest(node.dest)`.
  @override
  Future<List<ReaderDestination>> getDestinations() async {
    return outline.asMap().entries.map((entry) {
      return _nodeToDestination(entry.value, '${entry.key}');
    }).toList();
  }

  static ReaderDestination _nodeToDestination(PdfOutlineNode node, String path) {
    final dest = node.dest;
    final s = {
      'pageNumber': dest?.pageNumber,
      'command':dest?.command.name,
      'params':dest?.params
    };
    final data = jsonEncode(s);
    return ReaderDestination(
      label: node.title,
      locator: data,
      level: path.split('/').length - 1,
      children: node.children.asMap().entries.map((e) {
        return _nodeToDestination(e.value, '$path/${e.key}');
      }).toList(),
    );
  }

  @override
  Future<void> goToDestination(ReaderDestination destination) async {
    final data = jsonDecode(destination.locator);
    final List<double> paramsList = [...data['params']];
    final s = PdfDest(data['pageNumber'], PdfDestCommand.parse(data['command']), paramsList);

      widget.controller.goToDest(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: Drawer(
        child: ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            return SafeArea(
              child:Column(
                children: [
                  TabBar(
                    controller: drawerTabController,
                    tabs: [
                      Tab(icon: Icon(Icons.bookmark)),
                      Tab(icon: Icon(Icons.search)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: drawerTabController,
                      children: [
                        outline.isEmpty
                            ? const Center(child: Text('No outline available'))
                            : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  const DrawerHeader(
                                    decoration: BoxDecoration(color: Colors.blue),
                                    child: Text(
                                      'Table of Contents',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  ...outline.map(
                                    (node) => PdfOutlineNodeWidget(
                                      node: node,
                                      controller: widget.controller,
                                      level: 0,
                                    ),
                                  ),
                                ],
                              ),
                        TextSearchView(textSearcher: PdfTextSearcher(widget.controller))
                      ],
                    ),
                  ),
                ],
              ) ,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // 1. Core PDF Canvas Interface Layer
          Positioned.fill(
            child: PdfViewer.file(
              widget.path,
              controller: widget.controller,
              initialPageNumber: widget.page,
              params: PdfViewerParams(
                // Note: immersive-mode tap-to-exit on mobile is now handled
                // by the ReaderShell's center-tap detector, NOT here.
                onGeneralTap: (_, _, _) => false,
                linkHandlerParams: PdfLinkHandlerParams(
                  onLinkTap: (link) async {
                    if (link.url != null) {
                      final result = await shouldOpenUrl(context, link.url!);
                      if (result) {
                        launchUrl(link.url!);
                      }
                    } else if (link.dest != null) {
                      widget.controller.goToDest(link.dest);
                    }
                  },
                ),
                onViewerReady: (document, controller) async {
                  outline = await document.loadOutline();
                  if (initialZoom != null) {
                    widget.controller.setZoom(
                      widget.controller.centerPosition,
                      initialZoom!,
                    );
                  }
                  setState(() {});
                },
              ),
            ),
          ),

          // 2. Floating Bottom Page Entry Controller — slides out of view
          //    when the shell's immersiveController reports `true`.
          if (widget.controller.isReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _overlaySlide,
                child: SafeArea(
                  child: Center(
                    child: PageNumberDisplay(pdfController: widget.controller),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Recursive Okular-Style Tree Item Component
class PdfOutlineNodeWidget extends StatefulWidget {
  const PdfOutlineNodeWidget({
    super.key,
    required this.node,
    required this.controller,
    required this.level,
  });

  final PdfOutlineNode node;
  final PdfViewerController controller;
  final int level;

  @override
  State<PdfOutlineNodeWidget> createState() => _PdfOutlineNodeNodeWidgetState();
}

class _PdfOutlineNodeNodeWidgetState extends State<PdfOutlineNodeWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Target 1: The Toggle Arrow Button (Only captures interaction if children exist)
            Container(
              width: 40,
              margin: EdgeInsets.only(left: 14.0 * widget.level),
              child: hasChildren
                  ? IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            // Target 2: Text Section Area for Direct Document Navigation
            Expanded(
              child: ListTile(
                title: Text(
                  widget.node.title,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                dense: true,
                onTap: () {
                  if (widget.node.dest != null) {
                    widget.controller.goToDest(widget.node.dest!);
                    Navigator.pop(context); // Safe dismiss drawer context
                  }
                },
              ),
            ),
          ],
        ),

        // Recursive loop checking for child outlines
        if (hasChildren && _isExpanded)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.node.children.map((childNode) {
              return PdfOutlineNodeWidget(
                node: childNode,
                controller: widget.controller,
                level: widget.level + 1,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class PageNumberDisplay extends StatefulWidget {
  const PageNumberDisplay({super.key, required this.pdfController});

  final PdfViewerController pdfController;

  @override
  State<PageNumberDisplay> createState() => _PageNumberDisplayState();
}

class _PageNumberDisplayState extends State<PageNumberDisplay> {
  late final TextEditingController textController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = (widget.pdfController.pageNumber).toString();
    if (widget.pdfController.isReady) {
      widget.pdfController.addListener(_updatePage);
    }
  }

  @override
  void dispose() {
    // FIXED: Unbind listener reference on lifecycle destruction to stop memory leak loops
    widget.pdfController.removeListener(_updatePage);
    _debounceTimer?.cancel();
    textController.dispose();
    super.dispose();
  }

  void _updatePage() {
    if (mounted) {
      textController.text = widget.pdfController.pageNumber.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 45,
              child: TextFormField(
                controller: textController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 600), () {
                    final page = int.tryParse(value);
                    if (page == null) return;
                    widget.pdfController.goToPage(
                      pageNumber: page.clamp(1, widget.pdfController.pageCount),
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "of ${widget.pdfController.isReady ? widget.pdfController.pageCount : "..."}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> shouldOpenUrl(BuildContext context, Uri url) async {
  final result = await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Navigate to URL?'),
        content: SelectionArea(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text:
                      'Do you want to navigate to the following location?\n\n',
                ),
                TextSpan(
                  text: url.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

//
// Simple Text Search View
//
class TextSearchView extends StatefulWidget {
  const TextSearchView({required this.textSearcher, super.key});

  final PdfTextSearcher textSearcher;

  @override
  State<TextSearchView> createState() => _TextSearchViewState();
}

class _TextSearchViewState extends State<TextSearchView> {
  final focusNode = FocusNode();
  final searchTextController = TextEditingController();
  late final pageTextStore = PdfPageTextCache(
    textSearcher: widget.textSearcher,
  );
  final scrollController = ScrollController();

  @override
  void initState() {
    widget.textSearcher.addListener(_searchResultUpdated);
    searchTextController.addListener(_searchTextUpdated);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    widget.textSearcher.removeListener(_searchResultUpdated);
    searchTextController.removeListener(_searchTextUpdated);
    searchTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _searchTextUpdated() {
    widget.textSearcher.startTextSearch(searchTextController.text);
  }

  int? _currentSearchSession;
  final _matchIndexToListIndex = <int>[];
  final _listIndexToMatchIndex = <int>[];

  void _searchResultUpdated() {
    if (_currentSearchSession != widget.textSearcher.searchSession) {
      _currentSearchSession = widget.textSearcher.searchSession;
      _matchIndexToListIndex.clear();
      _listIndexToMatchIndex.clear();
    }
    for (
      int i = _matchIndexToListIndex.length;
      i < widget.textSearcher.matches.length;
      i++
    ) {
      if (i == 0 ||
          widget.textSearcher.matches[i - 1].pageNumber !=
              widget.textSearcher.matches[i].pageNumber) {
        _listIndexToMatchIndex.add(
          -widget.textSearcher.matches[i].pageNumber,
        ); // negative index to indicate page header
      }
      _matchIndexToListIndex.add(_listIndexToMatchIndex.length);
      _listIndexToMatchIndex.add(i);
    }

    if (mounted) setState(() {});
  }

  static const double itemHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.textSearcher.isSearching
            ? LinearProgressIndicator(
                value: widget.textSearcher.searchProgress,
                minHeight: 4,
              )
            : const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    autofocus: true,
                    focusNode: focusNode,
                    controller: searchTextController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(right: 50),
                    ),
                    textInputAction: TextInputAction.search,
                    // onSubmitted: (value) {
                    //   // just focus back to the text field
                    //   focusNode.requestFocus();
                    // },
                  ),
                  if (widget.textSearcher.hasMatches)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${widget.textSearcher.currentIndex! + 1} / ${widget.textSearcher.matches.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed:
                  (widget.textSearcher.currentIndex ?? 0) <
                      widget.textSearcher.matches.length
                  ? () async {
                      await widget.textSearcher.goToNextMatch();
                      _conditionScrollPosition();
                    }
                  : null,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 20,
            ),
            IconButton(
              onPressed: (widget.textSearcher.currentIndex ?? 0) > 0
                  ? () async {
                      await widget.textSearcher.goToPrevMatch();
                      _conditionScrollPosition();
                    }
                  : null,
              icon: const Icon(Icons.arrow_upward),
              iconSize: 20,
            ),
            IconButton(
              onPressed: searchTextController.text.isNotEmpty
                  ? () {
                      searchTextController.text = '';
                      widget.textSearcher.resetTextSearch();
                      focusNode.requestFocus();
                    }
                  : null,
              icon: const Icon(Icons.close),
              iconSize: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            key: Key(searchTextController.text),
            controller: scrollController,
            itemCount: _listIndexToMatchIndex.length,
            itemBuilder: (context, index) {
              final matchIndex = _listIndexToMatchIndex[index];
              if (matchIndex >= 0 &&
                  matchIndex < widget.textSearcher.matches.length) {
                final match = widget.textSearcher.matches[matchIndex];
                return SearchResultTile(
                  key: ValueKey(index),
                  match: match,
                  onTap: () async {
                    await widget.textSearcher.goToMatchOfIndex(matchIndex);
                    if (mounted) setState(() {});
                  },
                  pageTextStore: pageTextStore,
                  height: itemHeight,
                  isCurrent: matchIndex == widget.textSearcher.currentIndex,
                );
              } else {
                return Container(
                  height: itemHeight,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Page ${-matchIndex}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _conditionScrollPosition() {
    final pos = scrollController.position;
    final newPos =
        itemHeight * _matchIndexToListIndex[widget.textSearcher.currentIndex!];
    if (newPos + itemHeight > pos.pixels + pos.viewportDimension) {
      scrollController.animateTo(
        newPos + itemHeight - pos.viewportDimension,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    } else if (newPos < pos.pixels) {
      scrollController.animateTo(
        newPos,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    }

    if (mounted) setState(() {});
  }
}

class SearchResultTile extends StatefulWidget {
  const SearchResultTile({
    required this.match,
    required this.onTap,
    required this.pageTextStore,
    required this.height,
    required this.isCurrent,
    super.key,
  });

  final PdfPageTextRange match;
  final void Function() onTap;
  final PdfPageTextCache pageTextStore;
  final double height;
  final bool isCurrent;

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  PdfPageText? pageText;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _release() {
    if (pageText != null) {
      widget.pageTextStore.releaseText(pageText!.pageNumber);
    }
  }

  Future<void> _load() async {
    _release();
    pageText = await widget.pageTextStore.loadText(widget.match.pageNumber);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(createTextSpanForMatch(pageText, widget.match));

    return SizedBox(
      height: widget.height,
      child: Material(
        color: widget.isCurrent
            ? DefaultSelectionStyle.of(context).selectionColor!
            : null,
        child: InkWell(
          onTap: () => widget.onTap(),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: text,
          ),
        ),
      ),
    );
  }

  TextSpan createTextSpanForMatch(
    PdfPageText? pageText,
    PdfPageTextRange match, {
    TextStyle? style,
  }) {
    style ??= const TextStyle(fontSize: 14);
    if (pageText == null) {
      return TextSpan(text: match.text, style: style);
    }
    final fullText = pageText.fullText;
    int first = 0;
    for (int i = match.start - 1; i >= 0;) {
      if (fullText[i] == '\n') {
        first = i + 1;
        break;
      }
      i--;
    }
    int last = fullText.length;
    for (int i = match.end; i < fullText.length; i++) {
      if (fullText[i] == '\n') {
        last = i;
        break;
      }
    }

    final header = fullText.substring(first, match.start);
    final body = fullText.substring(match.start, match.end);
    final footer = fullText.substring(match.end, last);

    return TextSpan(
      children: [
        TextSpan(text: header),
        TextSpan(
          text: body,
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
        TextSpan(text: footer),
      ],
      style: style,
    );
  }
}

/// A helper class to cache loaded page texts.
class PdfPageTextCache {
  final PdfTextSearcher textSearcher;

  PdfPageTextCache({required this.textSearcher});

  final _pageTextRefs = <int, _PdfPageTextRefCount>{};

  /// load the text of the given page number.
  Future<PdfPageText> loadText(int pageNumber) async {
    final ref = _pageTextRefs[pageNumber];
    if (ref != null) {
      ref.refCount++;
      return ref.pageText;
    }
    return await synchronized(() async {
      var ref = _pageTextRefs[pageNumber];
      if (ref == null) {
        final pageText = await textSearcher.loadText(pageNumber: pageNumber);
        ref = _pageTextRefs[pageNumber] = _PdfPageTextRefCount(pageText!);
      }
      ref.refCount++;
      return ref.pageText;
    });
  }

  /// Release the text of the given page number.
  void releaseText(int pageNumber) {
    final ref = _pageTextRefs[pageNumber]!;
    ref.refCount--;
    if (ref.refCount == 0) {
      _pageTextRefs.remove(pageNumber);
    }
  }
}

class _PdfPageTextRefCount {
  _PdfPageTextRefCount(this.pageText);

  final PdfPageText pageText;
  int refCount = 0;
}
