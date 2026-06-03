import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ps_books/readers/epubReader.dart';
import 'package:ps_books/readers/fb2_reader.dart';
import 'package:ps_books/readers/microsoft_reader.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/reader_state.dart';
import 'dart:io';
import 'dart:convert';
import '../readers/pdfReader.dart';
import '../readers/comic_reader.dart';
import 'package:katbook_epub_reader/src/models/reading_position.dart';

import '../helpers/pickBooks.dart';
import '../helpers/utils.dart';

class Reader extends ConsumerStatefulWidget {
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
  ConsumerState<Reader> createState() => ReaderState();
}

final _database = BookToDb();

class ReaderState extends ConsumerState<Reader> {
  final controller = PdfViewerController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> savePDFProgress() async {
    int Page = controller.pageNumber ?? 1;
    int totalPages = controller.pageCount;
    double progress = Page / totalPages;
    await _database.updatePage(widget.id, Page);
    await _database.updateProgress(widget.id, progress);
  }

  void saveEpubPosition(position) {
    String pos = jsonEncode(position);
    _database.updatePositionAndProgress(widget.id, pos);
  }

  void saveEpubProgress(progress) {
    _database.updateProgress(widget.id, progress);
  }

  void onfb2progresschanged(int position, double progress) {
    String pos = jsonEncode(position);
    _database.updatePositionAndProgress(widget.id, pos);
    _database.updateProgress(widget.id, progress);
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

  int? getFB2Position() {
    if (widget.position == null) return null;
    try {
      return jsonDecode(widget.position) as int?;
    } catch (e) {
      return null;
    }
  }

  Widget checkWidget() {
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
          } else {
            return Center(child: Text('An error occured'));
          }
        },
      );
    } else if (widget.type == 'docx' || widget.type == 'pptx') {
      return FutureBuilder(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MicrosoftReader(fileBytes: snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...");
          } else {
            return Text("An Error has occured");
          }
        },
      );
    } else if (widget.type == 'fb2') {
      return FB2Reader(
        filePath: widget.path,
        onPositionChanged: onfb2progresschanged,
        initialPosition: getFB2Position(),
      );
    } else if (widget.type == 'cbz' ||
        widget.type == 'cbt' ||
        widget.type == 'cbw') {
      return FutureBuilder(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ComicReaderPage(
              fileBytes: snapshot.data!,
              filename: widget.path.split(Platform.pathSeparator).last,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("An Error has occured"));
          }
        },
      );
    } else {
      print(widget.type);
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
        await _database.setCurrentlyReading(widget.id);
        ref.read(ReaderStateProvider.notifier).setIsReadingFalse();
      },
      canPop: true,
      child: checkWidget(),
    );
  }
}
