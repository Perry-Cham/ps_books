
import 'package:flutter/material.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ps_books/readers/epubReader.dart';
import 'dart:io';
import 'dart:convert';
import '../readers/pdfReader.dart';
import 'package:katbook_epub_reader/src/models/reading_position.dart';

import '../helpers/pickBooks.dart';
import '../helpers/utils.dart';



class Reader extends StatefulWidget {
  const Reader({
    super.key,
    required this.type,
    required this.path,
    required this.id,
    this.page,
    this.position,
  });
  final String path;
  final String type;
  final int id;
  final int? page;
  final position;

  @override
  State<Reader> createState() => ReaderState();
}

class ReaderState extends State<Reader> {
  final controller = PdfViewerController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  savePDFProgress() async {
    int Page = controller.pageNumber ?? 1;
    int totalPages = controller.pageCount;
    double progress = Page / totalPages;
    await database.updatePage(widget.id, Page);
    await database.updateProgress(widget.id, progress);
  }

  saveEpubPosition(position) {
    String pos = jsonEncode(position);
    database.updatePositionAndProgress(widget.id, pos);
  }

  saveEpubProgress(progress) {
    database.updateProgress(widget.id, progress);
  }

  ReadingPosition? getPosition() {
    if (widget.position == null) return null;
    var json = jsonDecode(widget.position);
    ReadingPosition pos = ReadingPosition(
      chapterIndex: json['chapterIndex'],
      paragraphIndex: json['paragraphIndex'],
      totalParagraphs: json['totalParagraphs'],
    );
    return pos;
  }

  checkWidget() {
    if (widget.type == 'pdf') {
      return PDF(
        path: widget.path,
        controller: controller,
        page: widget.page ?? 1,
      );
    } else if (widget.type == 'epub') {
      return FutureBuilder(
        future: convertEpubToBytes(path: widget.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return EpubReaderScreen(
              epubBytes: snapshot.data,
              initialPosition: getPosition(),
              onPositionChanged: saveEpubPosition,
              onProgressChanged: saveEpubProgress,
            );
          } else if (widget.type == 'docx' || widget.type == 'pptx') {
            return FutureBuilder(
              future: File(widget.path).readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return MicrosoftViewer(snapshot.data!, false);
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Text("Loading...");
                } else {
                  return Text("An Error has occured");
                }
              },
            );
          } else {
            return Center(child: Text('An error occured'));
          }
        },
      );
    } else {
      return Center(child: Text('Unsupported file'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // your logic here
        if (widget.type == 'pdf') {
          await savePDFProgress();
        }
      },
      canPop: true,
      child: checkWidget(),
    );
  }
}
