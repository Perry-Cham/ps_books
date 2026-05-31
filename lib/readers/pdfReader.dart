import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ps_books/services/settings/reader-preferences.dart';

class PDF extends ConsumerStatefulWidget {
  const PDF({
    super.key,
    required this.path,
    required this.controller,
    required this.page,
  });

  final String path;
  final PdfViewerController controller;
  final int page;

  @override
  ConsumerState<PDF> createState() => _PDFState();
}

class _PDFState extends ConsumerState<PDF> with SingleTickerProviderStateMixin {
  List<PdfOutlineNode> outline = [];
  double? initialZoom;

  // Immersive Mode Layout Animation Properties
  bool _isImmersiveMode = false;
  late AnimationController _uiAnimationController;
  late Animation<Offset> _topBarOffset;
  late Animation<Offset> _bottomBarOffset;

  @override
  void initState() {
    super.initState();

    _uiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _topBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2), // Slides the AppBar up out of frame
    ).animate(CurvedAnimation(parent: _uiAnimationController, curve: Curves.easeInOut));

    _bottomBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5), // Slides the page counter down out of frame
    ).animate(CurvedAnimation(parent: _uiAnimationController, curve: Curves.easeInOut));

    // Listen to scroll actions to automatically hide UI bars on mobile screens
    widget.controller.addListener(_handleScroll);

    // Fetch User Zoom Preferences
    ref.read(pdfPrefsProvider.future).then((prefs) {
      setState(() {
        initialZoom = prefs.zoom;
      });
    }).catchError((_) {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    _uiAnimationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
    if (isMobile && !_isImmersiveMode && widget.controller.isReady) {
      _toggleImmersiveMode(true);
    }
  }

  void _toggleImmersiveMode(bool targetState) {
    setState(() {
      _isImmersiveMode = targetState;
      if (_isImmersiveMode) {
        _uiAnimationController.forward();
      } else {
        _uiAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: Drawer(
        child: ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            if (outline.isEmpty) {
              return const Center(child: Text('No outline available'));
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Table of Contents',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                ...outline.map((node) => PdfOutlineNodeWidget(
                  node: node,
                  controller: widget.controller,
                  level: 0,
                )),
              ],
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
                onGeneralTap: (_,_,_) {
                  if (isMobile) {
                    _toggleImmersiveMode(!_isImmersiveMode);
                    return true;
                  }
                  return false;
                },
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
                    widget.controller.setZoom(widget.controller.centerPosition, initialZoom!);
                  }
                  setState(() {});
                },
              ),
            ),
          ),

          // 2. Slidable Custom AppBar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _topBarOffset,
              child: AppBar(
                title: const Text("Reader"),
                actions: [
                  IconButton(
                    onPressed: () {
                      double currZoom = widget.controller.currentZoom;
                      widget.controller.setZoom(
                        widget.controller.centerPosition,
                        (currZoom < 2.8) ? (currZoom + 0.1) : 2.8,
                      );
                    },
                    icon: const Icon(Icons.zoom_in),
                  ),
                  IconButton(
                    onPressed: () {
                      double currZoom = widget.controller.currentZoom;
                      widget.controller.setZoom(
                        widget.controller.centerPosition,
                        (currZoom > 1.0) ? (currZoom - 0.1) : 1.0,
                      );
                    },
                    icon: const Icon(Icons.zoom_out),
                  ),
                  if (!isMobile)
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'Reading Mode',
                      onPressed: () => _toggleImmersiveMode(true),
                    ),
                  IconButton(
                    onPressed: () {
                      if (widget.controller.isReady) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Bottom Page Entry Controller
          if (widget.controller.isReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _bottomBarOffset,
                child: SafeArea(
                  child: Center(
                    child: PageNumberDisplay(pdfController: widget.controller),
                  ),
                ),
              ),
            ),

          // 4. Desktop Escape Hatch Floating Return Button
          if (!isMobile && _isImmersiveMode)
            Positioned(
              top: 20,
              right: 20,
              child: FadeTransition(
                opacity: _uiAnimationController,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    onPressed: () => _toggleImmersiveMode(false),
                    child: const Icon(Icons.fullscreen_exit, color: Colors.black87),
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
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(
                    const Duration(milliseconds: 600),
                        () {
                      final page = int.tryParse(value);
                      if (page == null) return;
                      widget.pdfController.goToPage(
                        pageNumber: page.clamp(1, widget.pdfController.pageCount),
                      );
                    },
                  );
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
                  text: 'Do you want to navigate to the following location?\n\n',
                ),
                TextSpan(
                  text: url.toString(),
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
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