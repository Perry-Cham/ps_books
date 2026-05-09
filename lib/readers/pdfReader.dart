import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ps_books/services/reader-preferences.dart';

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

class _PDFState extends ConsumerState<PDF> {
  List<PdfOutlineNode> outline = [];
  double? initialZoom;

  @override
  void initState() {
    super.initState();
    ref.read(pdfPrefsProvider.future).then((prefs) {
      setState(() {
        initialZoom = prefs.zoom;
      });
    }).catchError((_) {
      // Load failed, initialZoom remains null, use default zoom
    });
  }

  // Recursive function to handle nested chapters
  List<Widget> _buildOutlineItems(
    List<PdfOutlineNode> nodes,
    BuildContext context, {
    int level = 2,
  }) {
    List<Widget> items = [];
    for (var node in nodes) {
      items.add(
        ListTile(
          title: Text(node.title),
          // Indent sub-chapters slightly
          contentPadding: EdgeInsets.only(left: 8.0 * level),
          onTap: () {
            // Navigate to the destination page
            if (node.dest != null) {
              widget.controller.goToDest(node.dest!);
              Navigator.pop(context); // Close the drawer
            }
          },
        ),
      );
      // Recursively add children if they exist
      if (node.children.isNotEmpty) {
        items.addAll(
          _buildOutlineItems(node.children, context, level: level * 2),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Reader"),
        actions: [
          IconButton(
            onPressed: () {
              double currZoom = widget.controller.currentZoom;
              if (currZoom < 2.8) {
                widget.controller.setZoom(
                  widget.controller.centerPosition,
                  (currZoom + 10 / 100),
                );
              } else {
                widget.controller.setZoom(
                  widget.controller.centerPosition,
                  2.8,
                );
              }
            },
            icon: Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () {
              double currZoom = widget.controller.currentZoom;
              if (currZoom > 1.0) {
                widget.controller.setZoom(
                  widget.controller.centerPosition,
                  (currZoom - 10 / 100),
                );
              } else {
                widget.controller.setZoom(
                  widget.controller.centerPosition,
                  1.0,
                );
              }
            },
            icon: Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              if (widget.controller.isReady) {
                Navigator.pop(context);
              } else {
                return;
              }
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      drawer: Drawer(
        child: ValueListenableBuilder(
          // The controller notifies when the document is loaded
          valueListenable: widget.controller,
          builder: (context, value, child) {
            if (outline.isEmpty) {
              return const Center(child: Text('No outline available'));
            }

            return ListView(
              children: [
                const DrawerHeader(child: Text('Table of Contents')),
                ..._buildOutlineItems(outline, context),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          PdfViewer.file(
            widget.path,
            controller: widget.controller,
            initialPageNumber: widget.page,
            params: PdfViewerParams(
              linkHandlerParams: PdfLinkHandlerParams(
                onLinkTap: (link) async {
                  // handle URL or Dest
                  if (link.url != null) {
                    // FIXME: Don't open the link without prompting user to do so or validating the link destination
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
                setState(() {}); // trigger rebuild now that controller is ready
              },
            ),
          ),
          if (widget.controller.isReady)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: pageNumberDisplay(pdfController: widget.controller),
            ),
        ],
      ),
    );
  }
}

class pageNumberDisplay extends StatefulWidget {
  const pageNumberDisplay({super.key, required this.pdfController});
  final PdfViewerController pdfController;
  @override
  State<pageNumberDisplay> createState() => _pageNumberDisplayState();
}

class _pageNumberDisplayState extends State<pageNumberDisplay> {
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
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  dynamic _updatePage() {
    textController.text = widget.pdfController.pageNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: TextFormField(
                controller: textController,
                onChanged: (value) {
                  _debounceTimer?.cancel();

                  // start a new timer — only fires if user stops typing for 600ms
                  _debounceTimer = Timer(
                    const Duration(milliseconds: 1000),
                    () {
                      final page = int.tryParse(value);
                      if (page == null) return;

                      if (page > widget.pdfController.pageCount) {
                        widget.pdfController.goToPage(
                          pageNumber: widget.pdfController.pageCount,
                        );
                      } else if (page < 1) {
                        widget.pdfController.goToPage(pageNumber: 1);
                      } else {
                        widget.pdfController.goToPage(pageNumber: page);
                      }
                    },
                  );
                },
              ),
            ),
            Text(
              "of ${widget.pdfController.isReady ? widget.pdfController.pageCount : "loading..."}",
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
                  text: 'Do you want to navigate to the following location?\n',
                ),
                TextSpan(
                  text: url.toString(),
                  style: const TextStyle(color: Colors.blue),
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
