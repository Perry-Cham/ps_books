import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import 'package:pdfrx/pdfrx.dart';

import '../helpers/pickBooks.dart';
import '../helpers/utils.dart';
import '../readers/comic_reader.dart';
import '../readers/pdfReader.dart';
import '../dbs/database.dart';
import '../readers/epubReader.dart';
import '../readers/fb2_reader.dart';
import '../readers/microsoft_reader.dart';
import '../readers/mobiReader.dart';
import '../readers/pptReader.dart';
import '../services/DB%20services/bookToDb.dart';
import '../state/pomodoro_timer.dart';
import '../state/reader_state.dart';

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

  final GlobalKey<EpubReaderScreenState> _epubReaderKey = GlobalKey();
  final GlobalKey<FB2ReaderState> _fb2ReaderKey = GlobalKey();

  bool get _isReflowable => widget.type == 'epub' || widget.type == 'fb2';
  bool get _isFb2 => widget.type == 'fb2';
  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  String get _title {
    try {
      return widget.path.split(Platform.pathSeparator).last;
    } catch (_) {
      return 'Reader';
    }
  }

  @override
  void dispose() {
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
              key: _epubReaderKey,
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
        key: _fb2ReaderKey,
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
    } else if (widget.type == 'mobi' || widget.type == 'azw3') {
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

  void _showSettings() {
    String currentScrollMode = 'scroll';
    String currentTheme = 'light';
    double currentFontSize = 16;

    if (widget.type == 'epub') {
      final epubState = _epubReaderKey.currentState;
      if (epubState != null) {
        final readerState = epubState.readerKey.currentState;
        if (readerState != null) {
          currentScrollMode = readerState.readingMode == ReadingMode.page ? 'page' : 'scroll';
          if (readerState.currentTheme == ReaderTheme.dark) {
            currentTheme = 'dark';
          } else if (readerState.currentTheme == ReaderTheme.sepia) {
            currentTheme = 'sepia';
          }
          currentFontSize = readerState.fontSize;
        }
      }
    } else if (widget.type == 'fb2') {
      final fb2State = _fb2ReaderKey.currentState;
      if (fb2State != null) {
        currentTheme = fb2State.darkMode ? 'dark' : 'light';
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reader Settings',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: _isReflowable ? 1.0 : 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Font Size'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _isReflowable
                                  ? () {
                                      _changeFontSize(-2);
                                      currentFontSize -= 2;
                                      setModalState(() {});
                                    }
                                  : null,
                            ),
                            Text('${currentFontSize.round()}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _isReflowable
                                  ? () {
                                      _changeFontSize(2);
                                      currentFontSize += 2;
                                      setModalState(() {});
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _isReflowable ? 1.0 : 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Scroll Mode'),
                        DropdownButton<String>(
                          value: _isFb2 ? 'scroll' : currentScrollMode,
                          items: [
                            const DropdownMenuItem(
                              value: 'scroll',
                              child: Text('Scroll'),
                            ),
                            if (_isFb2)
                              const DropdownMenuItem<String>(
                                value: 'page',
                                enabled: false,
                                child: Text(
                                  'Page',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              const DropdownMenuItem(
                                value: 'page',
                                child: Text('Page'),
                              ),
                          ],
                          onChanged: _isReflowable && !_isFb2
                              ? (val) {
                                  if (val != null) {
                                    _setScrollMode(val);
                                    currentScrollMode = val;
                                    setModalState(() {});
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _isReflowable ? 1.0 : 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Theme'),
                        DropdownButton<String>(
                          value: currentTheme,
                          items: [
                            const DropdownMenuItem(
                              value: 'light',
                              child: Text('Light'),
                            ),
                            const DropdownMenuItem(
                              value: 'dark',
                              child: Text('Dark'),
                            ),
                            if (widget.type == 'epub')
                              const DropdownMenuItem(
                                value: 'sepia',
                                child: Text('Sepia'),
                              ),
                          ],
                          onChanged: _isReflowable
                              ? (val) {
                                  if (val != null) {
                                    _setTheme(val);
                                    currentTheme = val;
                                    setModalState(() {});
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changeFontSize(double delta) {
    if (widget.type == 'epub') {
      final epubState = _epubReaderKey.currentState;
      if (epubState != null) {
        final readerState = epubState.readerKey.currentState;
        if (readerState != null) {
          readerState.setFontSize(readerState.fontSize + delta);
        }
      }
    }
  }

  void _setScrollMode(String mode) {
    if (widget.type == 'epub') {
      final epubState = _epubReaderKey.currentState;
      if (epubState != null) {
        epubState.readerKey.currentState?.setReadingMode(
          mode == 'page' ? ReadingMode.page : ReadingMode.scroll,
        );
      }
    }
  }

  void _setTheme(String theme) {
    if (widget.type == 'epub') {
      final epubState = _epubReaderKey.currentState;
      if (epubState != null) {
        final readerState = epubState.readerKey.currentState;
        if (readerState != null) {
          if (theme == 'dark') {
            readerState.setTheme(ReaderTheme.dark);
          } else if (theme == 'sepia') {
            readerState.setTheme(ReaderTheme.sepia);
          } else {
            readerState.setTheme(ReaderTheme.light);
          }
        }
      }
    } else if (widget.type == 'fb2') {
      final fb2State = _fb2ReaderKey.currentState;
      if (fb2State != null) {
        fb2State.setDarkMode(theme == 'dark');
      }
    }
  }

  void _showBookmarks() {
    if (widget.type == 'epub') {
      _showEpubBookmarks();
    } else if (widget.type == 'fb2') {
      _showFb2Bookmarks();
    } else if (widget.type == 'pdf') {
      _showPdfBookmarks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bookmarks available')),
      );
    }
  }

  void _showEpubBookmarks() {
    final epubState = _epubReaderKey.currentState;
    final readerState = epubState?.readerKey.currentState;
    final chapters = epubState?.controller.tableOfContents ?? [];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookmarks',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (chapters.isEmpty)
                const Text('No bookmarks available')
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (ctx, index) {
                      final chapter = chapters[index];
                      return ListTile(
                        title: Text(chapter.title),
                        onTap: () {
                          Navigator.pop(ctx);
                          readerState?.jumpToChapter(chapter);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFb2Bookmarks() {
    final fb2State = _fb2ReaderKey.currentState;
    final chapters = fb2State?.chapterEntries ?? [];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookmarks',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (chapters.isEmpty)
                const Text('No bookmarks available')
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (ctx, index) {
                      final chapter = chapters[index];
                      final isActive = chapter.id == (fb2State?.currentChapter ?? -1);
                      return ListTile(
                        selected: isActive,
                        title: Text(chapter.title),
                        onTap: () {
                          Navigator.pop(ctx);
                          fb2State?.scrollToChapterById(chapter.id);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPdfBookmarks() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookmarks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Use the drawer to navigate PDF bookmarks'),
            ],
          ),
        );
      },
    );
  }

  void _showBookSelector() {
    final readerState = ref.read(readerStateProvider);
    if (readerState.secondBookId != null) {
      ref.read(readerStateProvider.notifier).clearSecondBook();
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a Book',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: StreamBuilder<List<Book>>(
                  stream: BookToDb().watchAllBooks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final books = snapshot.data!;
                    if (books.isEmpty) {
                      return const Center(
                          child: Text('No books in library'));
                    }
                    return ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (ctx, index) {
                        final book = books[index];
                        return ListTile(
                          leading: book.coverPath != null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: Image.file(
                                    File(book.coverPath!),
                                    width: 40,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.book),
                                  ),
                                )
                              : const Icon(Icons.book),
                          title: Text(book.name),
                          subtitle: book.author != null
                              ? Text(book.author!)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            ref
                                .read(readerStateProvider.notifier)
                                .setSecondBook(book.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  truncateTitle(int maxChars, String title){
    if(title.length > maxChars){
      return "${title.substring(0, maxChars - 1)}...";
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.type == 'pdf') {
          await savePDFProgress();
        }
        await _database.setCurrentlyReading(widget.id);
        ref.read(readerStateProvider.notifier).setIsReadingFalse();
      },
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showBookmarks,
            tooltip: 'Bookmarks',
          ),
          title: Text(truncateTitle(10, _title)),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                final state = ref.read(readerStateProvider);
                return [
                  if (!_isMobile)
                    PopupMenuItem(
                      onTap: () {
                        if (state.showAiChat) {
                          ref
                              .read(readerStateProvider.notifier)
                              .setShowAiChatFalse();
                        } else {
                          ref
                              .read(readerStateProvider.notifier)
                              .setShowAiChatTrue();
                        }
                      },
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            state.showAiChat
                                ? Icons.close
                                : Icons.chat_bubble_outline,
                          ),
                          Text(
                            state.showAiChat
                                ? 'Close AI Chat'
                                : 'AI Chat',
                          ),
                        ],
                      ),
                    ),
                  if (!_isMobile)
                    PopupMenuItem(
                      onTap: _showBookSelector,
                      child: Row(
                        spacing: 5,
                        children: [
                          const Icon(Icons.library_books),
                          Text(
                            state.secondBookId != null
                                ? 'Close Reader'
                                : 'Add Reader',
                          ),
                        ],
                      ),
                    ),
                ];
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Builder(builder: (context) {
          final readerState = ref.watch(readerStateProvider);
          final showAi = readerState.showAiChat;
          final secondBookId = readerState.secondBookId;

          return Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      flex: showAi
                          ? 6
                          : (secondBookId != null
                              ? 5
                              : 1),
                      child: Column(
                        children: [
                          Expanded(child: checkWidget()),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    if (showAi && !_isMobile)
                      Expanded(
                        flex: 4,
                        child: _AiChatPanel(
                          onClose: () => ref
                              .read(readerStateProvider.notifier)
                              .setShowAiChatFalse(),
                        ),
                      ),
                    if (secondBookId != null && !_isMobile)
                      Expanded(
                        flex: 5,
                        child: _SecondBookReader(
                          bookId: secondBookId,
                          onClose: () => ref
                              .read(readerStateProvider.notifier)
                              .clearSecondBook(),
                        ),
                      ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 20,
                left: 20,
                child: FloatingDesktopClockOverlay(),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class FloatingDesktopClockOverlay extends ConsumerWidget {
  const FloatingDesktopClockOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (isMobile) return const SizedBox.shrink();

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

    final pomodoroState = ref.watch(pomodoroProvider);
    final timerNotifier = ref.read(pomodoroProvider.notifier);

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
                    ref
                        .read(readerStateProvider.notifier)
                        .setShowPomodoroFalse();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "$minutes:$seconds",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFeatures: [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
            Text(
              "Cycle ${pomodoroState.currentCycle} of ${pomodoroState.cycles}",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const Divider(height: 12, thickness: 0.5),
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

const _aiBaseUrl = String.fromEnvironment(
  'BASE-URL',
  defaultValue: 'http://localhost:8000',
);
final _aiEndpoint = "/api/ai/chat";

class _AiChatPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _AiChatPanel({required this.onClose});

  @override
  State<_AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<_AiChatPanel> {
  final _chatController = InMemoryChatController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    try {
      final dio = AuthDio.instance;
      final response = await dio.post(
        "$_aiBaseUrl$_aiEndpoint",
        data: {"prompt": text},
      );
      final reply = response.data['text'] as String?;
      if (reply != null && reply.isNotEmpty) {
        _chatController.insertMessage(
          TextMessage(
            id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
            authorId: 'ai',
            createdAt: DateTime.now().toUtc(),
            text: reply,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
      _chatController.insertMessage(
        TextMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          authorId: 'ai',
          createdAt: DateTime.now().toUtc(),
          text: "Error: Failed to fetch response from AI backend.",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Text(
                'AI Chat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: Chat(
            chatController: _chatController,
            currentUserId: 'user1',
            onMessageSend: (text) {
              _chatController.insertMessage(
                TextMessage(
                  id: '${Random().nextInt(1000) + 1}',
                  authorId: 'user1',
                  createdAt: DateTime.now().toUtc(),
                  text: text,
                ),
              );
              _sendMessage(text);
            },
            resolveUser: (UserID id) async {
              if (id == 'ai') {
                return User(id: id, name: 'AI Assistant');
              }
              return User(id: id, name: 'John Doe');
            },
          ),
        ),
      ],
    );
  }
}

class _SecondBookReader extends StatefulWidget {
  final int bookId;
  final VoidCallback onClose;
  const _SecondBookReader({
    required this.bookId,
    required this.onClose,
  });

  @override
  State<_SecondBookReader> createState() => _SecondBookReaderState();
}

class _SecondBookReaderState extends State<_SecondBookReader> {
  final pdfController = PdfViewerController();
  Book? _book;
  bool _loading = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final book = await BookToDb().getBookById(widget.bookId);
    setState(() {
      _book = book;
      _loading = false;
    });
  }

  Future<void> _close() async {
    if (_book != null && _book!.extension == 'pdf') {
      final page = pdfController.pageNumber;
      final totalPages = pdfController.pageCount;
      if (page != null && totalPages > 0) {
        final progress = page / totalPages;
        await BookToDb().updatePage(_book!.id, page);
        await BookToDb().updateProgress(_book!.id, progress);
      }
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_book == null) {
      return const Center(child: Text('Book not found'));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          _buildReader(),
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Material(
                elevation: _isHovering ? 4 : 0,
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _close,
                  tooltip: 'Close reader',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReader() {
    final type = _book!.extension;

    if (type == 'pdf') {
      return PDF(
        path: _book!.path,
        controller: pdfController,
        page: _book!.page ?? 1,
      );
    } else if (type == 'epub') {
      return FutureBuilder(
        future: convertEpubToBytes(path: _book!.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            ReadingPosition? pos;
            if (_book!.cfi != null) {
              try {
                final json = jsonDecode(_book!.cfi!);
                pos = ReadingPosition(
                  chapterIndex: json['chapterIndex'],
                  paragraphIndex: json['paragraphIndex'],
                  totalParagraphs: json['totalParagraphs'],
                );
              } catch (_) {}
            }
            return EpubReaderScreen(
              epubBytes: snapshot.data,
              initialPosition: pos,
            );
          } else {
            return const Center(child: Text('An error occured'));
          }
        },
      );
    } else if (type == 'fb2') {
      int? pos;
      if (_book!.cfi != null) {
        try {
          pos = jsonDecode(_book!.cfi!) as int?;
        } catch (_) {}
      }
      return FB2Reader(
        filePath: _book!.path,
        initialPosition: pos,
      );
    } else if (type == 'docx') {
      return FutureBuilder(
        future: File(_book!.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MicrosoftReader(fileBytes: snapshot.data!);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          return const Text("An Error has occured");
        },
      );
    } else if (type == 'cbz' ||
        type == 'cbt' ||
        type == 'cbw' ||
        type == 'cbr') {
      return FutureBuilder(
        future: File(_book!.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ComicReaderPage(
              fileBytes: snapshot.data!,
              filename:
                  _book!.path.split(Platform.pathSeparator).last,
              initialPage: (_book!.page ?? 1) - 1,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text("An Error has occured"));
        },
      );
    } else if (type == 'mobi' || type == 'azw3') {
      return FutureBuilder(
        future: File(_book!.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MobireaderPage(
              bytes: snapshot.data!,
              id: _book!.id,
              position: _book!.cfi,
            );
          } else {
            return const Center(child: Text('An error occurred'));
          }
        },
      );
    } else if (type == 'pptx') {
      return FutureBuilder(
        future: File(_book!.path).readAsBytes(),
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
      return const Center(child: Text('Unsupported file'));
    }
  }
}
