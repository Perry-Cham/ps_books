import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PDF extends StatelessWidget{
  const PDF({super.key, required this.path, required this.controller});

  final String path;
  final PdfViewerController controller;
 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Reader")),
      body: PdfViewer.file(
        path,
        controller:controller,
        params: PdfViewerParams(
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
