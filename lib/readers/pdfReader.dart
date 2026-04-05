import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PDF extends StatelessWidget{
  const PDF({super.key, required this.path, required this.controller, required this.page});

  final String path;
  final PdfViewerController controller;
  final int page;
 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Reader")),
      body: PdfViewer.file(
        path,
        controller:controller,
        params: PdfViewerParams(
          onDocumentLoadFinished: (documentRef, loadSucceeded) {
            if(page > 1){
              controller.goToPage(pageNumber: page);
            }
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
