import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PDF extends StatelessWidget {
  PDF({
    super.key,
    required this.path,
    required this.controller,
    required this.page,
  });

  final String path;
  final PdfViewerController controller;
  final int page;
  List<PdfOutlineNode> outline = [];

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
              controller.goToDest(node.dest!);
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
        bottom: controller.isReady
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: pageNumberDisplay(pdfController: controller),
              )
            : null,
        actions: [
          IconButton(
            onPressed: () {
              //   print(controller.currentZoom);
              //  controller.zoomUp();
              double currZoom = controller.currentZoom;
              if (currZoom < 2.8) {
                controller.setZoom(
                  controller.centerPosition,
                  (currZoom + 10 / 100),
                );
              } else {
                controller.setZoom(controller.centerPosition, 2.8);
              }
            },
            icon: Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () {
              double currZoom = controller.currentZoom;
              if (currZoom > 1.0) {
                controller.setZoom(
                  controller.centerPosition,
                  (currZoom - 10 / 100),
                );
              } else {
                controller.setZoom(controller.centerPosition, 1.0);
              }
            },
            icon: Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              if (controller.isReady) {
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
          valueListenable: controller,
          builder: (context, value, child) {
            if (outline == null || outline.isEmpty) {
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
      body: PdfViewer.file(
        path,
        controller: controller,
        params: PdfViewerParams(
          onDocumentLoadFinished: (documentRef, loadSucceeded) {
            if (page > 1) {
              controller.goToPage(pageNumber: page);
            }
          },
          onViewerReady: (document, controller) async {
            outline = await document.loadOutline();
          },
          pageOverlaysBuilder: (context, pageRect, page) {
            return [
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  page.pageNumber.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ];
          },
        ),
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
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = (1).toString();
    if (widget.pdfController.isReady) {
      textController.text = (widget.pdfController?.pageNumber).toString();
      widget.pdfController.addListener(_updatePage());
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
    return Padding(
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
                if (int.parse(value) > widget.pdfController.pageCount)
                  widget.pdfController.goToPage(
                    pageNumber: widget.pdfController.pageCount,
                  );
                if (int.parse(value) < 1)
                  widget.pdfController.goToPage(pageNumber: 1);
                widget.pdfController.goToPage(pageNumber: int.parse(value));
              },
            ),
          ),
          Text(
            "of ${widget.pdfController.isReady ? widget.pdfController?.pageCount : "loading..."}",
          ),
        ],
      ),
    );
  }
}
