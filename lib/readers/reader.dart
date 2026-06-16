import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ps_books/readers/epubReader.dart';
import 'package:ps_books/readers/fb2_reader.dart';
import 'package:ps_books/readers/microsoft_reader.dart';
import 'package:ps_books/readers/mobiReader.dart';
import 'package:ps_books/readers/pptReader.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/state/reader_state.dart';
import 'dart:io';
import 'dart:convert';
import '../readers/pdfReader.dart';
import '../readers/comic_reader.dart';
import 'package:katbook_epub_reader/src/models/reading_position.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:ps_books/state/pomodoro_timer.dart';

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
  final showDesktopPomodoroProvider = true;

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

  void saveEpubProgress(double progress) {
    _database.updateProgress(widget.id, progress);
  }

  void saveComicPage(double page) {
    _database.updatePage(widget.id, page.toInt() + 1);
  }

  void saveComicProgress(double progress) {
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
    } else if (widget.type == 'docx') {
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
        widget.type == 'cbw' || widget.type == 'cbr') {
      return FutureBuilder(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ComicReaderPage(
              fileBytes: snapshot.data!,
              filename: widget.path.split(Platform.pathSeparator).last,
              onPageChanged: saveComicPage,
              onProgressChanged: saveComicProgress,
              initialPage: (widget.page ?? 1) - 1,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("An Error has occured"));
          }
        },
      );
    } else if (widget.type == 'mobi') {
      return FutureBuilder(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MobireaderPage(
              bytes: snapshot.data!,
              id: widget.id,
              position: widget.position,
            );
          } else {
            return const Center(child: Text('An error occurred'));
          }
        },
      );
    } else if (widget.type == 'pptx') {
      return FutureBuilder(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return PptReader(bytes: snapshot.data!);
          } else {
            return const Center(child: Text('An error occurred'));
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
        ref.read(readerStateProvider.notifier).setIsReadingFalse();
      },
      canPop: true,
      child: Stack(
        children: [
          Positioned.fill(child: checkWidget()),
          const Positioned(
            bottom: 20,
            left: 20,
            child: FloatingDesktopClockOverlay(),
          ),
        ],
      ),
    );
  }
}

/// An isolated ConsumerWidget handling the non-invasive Pomodoro timer panel.
/// Listens exclusively to updates from pomodoroProvider and ReaderStateProvider
/// to shield your underlying book engines from unnecessary rendering passes.
class FloatingDesktopClockOverlay extends ConsumerWidget {
  const FloatingDesktopClockOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Target Condition Check: Only render on non-mobile devices (Desktop/Web configurations)
    final isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (isMobile) return const SizedBox.shrink();

    // 2. Target Condition Check: Safe layout dismiss rule when Reader shifts into full Immersive Mode
    final showTimer = ref.watch(
      readerStateProvider.select((s) => s.showPomodoroTimer),
    );
    final isTimerRunning = ref.watch(
      pomodoroProvider.select((s) => s.isRunning),
    );

    if (!showTimer && !isTimerRunning) return SizedBox.shrink();

    if (!showTimer) {
      return IconButton.filled(
        onPressed: () {
          ref.read(readerStateProvider.notifier).setShowPomodoroTrue();
        },
        icon: Icon(Icons.av_timer),
      );
    }

    // 4. Track layout changes on Pomodoro State metrics
    final pomodoroState = ref.watch(pomodoroProvider);
    final timerNotifier = ref.read(pomodoroProvider.notifier);

    // Render nothing if there is no running timer configuration initialized
    if (pomodoroState.cycles == 0) return const SizedBox.shrink();

    final minutes = (pomodoroState.secondsRemaining ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (pomodoroState.secondsRemaining % 60).toString().padLeft(
      2,
      '0',
    );

    final isWorkPhase = pomodoroState.phase == PomodoroPhase.work;
    final phaseLabel = isWorkPhase ? "Focus Cycle" : "Break Time";
    final phaseColor = isWorkPhase ? Colors.deepOrangeAccent : Colors.green;

    return Card(
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Controls header layer bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: phaseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    phaseLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: phaseColor,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () {
                    // Turn layout element off globally
                    ref
                        .read(readerStateProvider.notifier)
                        .setShowPomodoroFalse();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Time Engine Strings Output Panel
            Text(
              "$minutes:$seconds",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFeatures: [
                  FontFeature.tabularFigures(),
                ], // Fixed tabular figures resolve digit jumping jitter
              ),
            ),

            Text(
              "Cycle ${pomodoroState.currentCycle} of ${pomodoroState.cycles}",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const Divider(height: 12, thickness: 0.5),

            // Media control triggers action grid map
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.stop_circle_rounded,
                    size: 28,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    ref.read(pomodoroProvider.notifier).reset();
                    ref
                        .read(readerStateProvider.notifier)
                        .setShowPomodoroFalse();
                  },
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    pomodoroState.isRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 28,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    if (pomodoroState.isRunning) {
                      timerNotifier.pause();
                    } else {
                      timerNotifier.resume();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
