import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart' hide ReaderTheme;
import 'package:katbook_epub_reader/src/models/reader_theme.dart' as katbook;
import 'package:pdfrx/pdfrx.dart';

import '../helpers/utils.dart';
import '../readers/comic_reader.dart';
import '../readers/epubReader.dart';
import '../readers/fb2_reader.dart';
import '../readers/microsoft_reader.dart';
import '../readers/mobiReader.dart';
import '../readers/pdfReader.dart';
import '../readers/pptReader.dart';
import '../reader_utils/reader_destination.dart';
import '../reader_utils/reader_utils.dart' as progress;
import '../reader_utils/theme.dart';

/// Pure reader widget — renders a single book inside its parent
/// [ReaderShell]. Has NO AppBar, NO Scaffold, NO split-screen logic.
///
/// The shell owns the AppBar (with destinations / settings / AI chat /
/// second-reader / immersive-mode controls) and instantiates this widget
/// for both the primary book and — when the user picks a second book —
/// the secondary book (with [isSecondary] = true).
///
/// Implements [DestinationCapable] by delegating to the underlying engine's
/// state (EPUB/FB2/PDF/MOBI), looked up via the per-engine [GlobalKey]s.
class Reader extends ConsumerStatefulWidget {
  const Reader({
    super.key,
    required this.type,
    required this.path,
    required this.id,
    this.page,
    this.position,
    this.isSecondary = false,
    this.immersiveController,
    this.onCloseSecondary,
    this.onThemeChanged,
  });

  final String path;
  final String type;
  final int id;
  final int? page;

  /// Saved position — JSON-encoded `ReadingPosition` for EPUB, JSON-encoded
  /// `int` for FB2, CFI string for MOBI. Typed (was `dynamic` before).
  final String? position;

  /// When `true`, this widget is the second reader hosted inside the shell's
  /// split column. Renders a hover-revealed close button (calling
  /// [onCloseSecondary]) and does NOT render any chrome of its own.
  final bool isSecondary;

  /// Optional immersive-mode notifier — passed down to the PDF engine so its
  /// page-count overlay can slide out of view in sync with the shell's AppBar.
  final ValueListenable<bool>? immersiveController;

  /// Called when the user taps the hover-revealed close button on a secondary
  /// reader. The shell wires this to `clearSecondBook()`.
  final VoidCallback? onCloseSecondary;

  /// Called when the user changes the reader theme. The shell uses this to
  /// update the colour of the AppBar, drawer, and popup menus.
  final void Function(ReaderTheme theme)? onThemeChanged;

  @override
  ConsumerState<Reader> createState() => ReaderWidgetState();
}

class ReaderWidgetState extends ConsumerState<Reader>
    implements DestinationCapable {
  final PdfViewerController controller = PdfViewerController();

  /// Per-engine keys used to look up the engine's [DestinationCapable] state.
  final GlobalKey<EpubReaderScreenState> _epubReaderKey = GlobalKey();
  final GlobalKey<FB2ReaderState> _fb2ReaderKey = GlobalKey();
  // PDF state class is private to its file, so we use the generic
  // `State<StatefulWidget>` key type and rely on `is DestinationCapable`.
  final GlobalKey<State<StatefulWidget>> _pdfKey = GlobalKey();
  final GlobalKey<MobireaderPageState> _mobiReaderKey = GlobalKey();

  bool _isHovering = false;

  ReaderTheme _currentReaderTheme = ReaderTheme.light;

  bool get _isReflowable => widget.type == 'epub' || widget.type == 'fb2';
  bool get _isFb2 => widget.type == 'fb2';

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

  // ---------------------------------------------------------------------------
  // Progress persistence — thin wrappers around reader_utils functions.
  // ---------------------------------------------------------------------------

  Future<void> savePDFProgress() async {
    await progress.savePdfProgress(
      bookId: widget.id,
      page: controller.pageNumber,
      totalPages: controller.pageCount,
    );
  }

  void saveEpubPosition(ReadingPosition position) {
    final pos = progress.encodePositionJson(position.toJson());
    progress.saveEpubPosition(bookId: widget.id, positionJson: pos);
  }

  void saveEpubProgress(double progressFraction) {
    progress.saveEpubProgress(bookId: widget.id, progress: progressFraction);
  }

  void saveComicPage(double page) {
    progress.saveComicPage(bookId: widget.id, page: page);
  }

  void saveComicProgress(double progressFraction) {
    progress.saveComicProgress(bookId: widget.id, progress: progressFraction);
  }

  void onfb2progresschanged(int positionIdx, double progressFraction) {
    progress.saveFb2Progress(
      bookId: widget.id,
      position: positionIdx,
      progress: progressFraction,
    );
  }

  /// Best-effort save for any engine that hasn't been saving via callbacks
  /// during reading. Currently only PDF needs this (pdfrx has no
  /// page-change callback wired in this codebase).
  Future<void> saveProgress() async {
    if (widget.type == 'pdf') {
      await savePDFProgress();
    }
  }

  // ---------------------------------------------------------------------------
  // Position restore helpers
  // ---------------------------------------------------------------------------

  ReadingPosition? getPosition() {
    if (widget.position == null) return null;
    try {
      final json = jsonDecode(widget.position!) as Map<String, dynamic>;
      return ReadingPosition(
        chapterIndex: json['chapterIndex'] as int? ?? 0,
        paragraphIndex: json['paragraphIndex'] as int? ?? 0,
        totalParagraphs: json['totalParagraphs'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  int? getFB2Position() => progress.decodeFb2Position(widget.position);

  // ---------------------------------------------------------------------------
  // DestinationCapable — delegates to the current engine's state.
  // ---------------------------------------------------------------------------

  @override
  Future<List<ReaderDestination>> getDestinations() async {
    final capable = _currentEngineDestinationCapable;
    if (capable == null) return const <ReaderDestination>[];
    return capable.getDestinations();
  }

  @override
  Future<void> goToDestination(ReaderDestination destination) async {
    final capable = _currentEngineDestinationCapable;
    if (capable == null) return;
    await capable.goToDestination(destination);
  }

  DestinationCapable? get _currentEngineDestinationCapable {
    switch (widget.type) {
      case 'epub':
        final s = _epubReaderKey.currentState;
        return s is DestinationCapable ? s : null;
      case 'fb2':
        final s = _fb2ReaderKey.currentState;
        return s is DestinationCapable ? s : null;
      case 'pdf':
        final s = _pdfKey.currentState;
        return s is DestinationCapable ? s as DestinationCapable : null;
      case 'mobi':
      case 'azw3':
        final s = _mobiReaderKey.currentState;
        return s is DestinationCapable ? s as DestinationCapable : null;
      default:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Engine dispatch
  // ---------------------------------------------------------------------------

  Widget checkWidget() {
    if (widget.type == 'pdf') {
      return PDF(
        key: _pdfKey,
        path: widget.path,
        controller: controller,
        page: widget.page ?? 1,
        immersiveController: widget.immersiveController,
      );
    } else if (widget.type == 'epub') {
      return FutureBuilder<Uint8List>(
        future: convertEpubToBytes(path: widget.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return EpubReaderScreen(
              key: _epubReaderKey,
              epubBytes: snapshot.data,
              initialPosition: getPosition(),
              onPositionChanged: saveEpubPosition,
              onProgressChanged: saveEpubProgress,
            );
          } else {
            return const Center(child: Text('An error occured'));
          }
        },
      );
    } else if (widget.type == 'docx') {
      return FutureBuilder<Uint8List>(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MicrosoftReader(fileBytes: snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          } else {
            return const Text("An Error has occured");
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
        widget.type == 'cbw' ||
        widget.type == 'cbr') {
      return FutureBuilder<Uint8List>(
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
      return FutureBuilder<Uint8List>(
        future: File(widget.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MobireaderPage(
              key: _mobiReaderKey,
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
      return FutureBuilder<Uint8List>(
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
      debugPrint('Unsupported file type: ${widget.type}');
      return Center(child: Text('Unsupported file: ${widget.type}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Settings sheet — exposed so the shell's AppBar settings button can call
  // into the reader without owning the engine keys itself.
  // ---------------------------------------------------------------------------

  void showSettings() => _showSettings();

  void _showSettings() {
    String currentScrollMode = 'scroll';
    String currentTheme = _currentReaderTheme == ReaderTheme.dark
        ? 'dark'
        : _currentReaderTheme == ReaderTheme.sepia
        ? 'sepia'
        : 'light';
    double currentFontSize = 16;

    if (widget.type == 'epub') {
      final epubState = _epubReaderKey.currentState;
      if (epubState != null) {
        final readerState = epubState.readerKey.currentState;
        if (readerState != null) {
          currentScrollMode = readerState.readingMode == ReadingMode.page
              ? 'page'
              : 'scroll';
          currentFontSize = readerState.fontSize;
        }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Theme'),
                      DropdownButton<String>(
                        value: currentTheme,
                        items: const [
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                          DropdownMenuItem(
                            value: 'sepia',
                            child: Text('Sepia'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _setTheme(val);
                            currentTheme = val;
                            setModalState(() {});
                          }
                        },
                      ),
                    ],
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
    final readerTheme = theme == 'dark'
        ? ReaderTheme.dark
        : theme == 'sepia'
        ? ReaderTheme.sepia
        : ReaderTheme.light;

    _currentReaderTheme = readerTheme;
    widget.onThemeChanged?.call(readerTheme);

    switch (widget.type) {
      case 'epub':
        final epubState = _epubReaderKey.currentState;
        if (epubState != null) {
          final kt = switch (readerTheme) {
            ReaderTheme.light => katbook.ReaderTheme.light,
            ReaderTheme.sepia => katbook.ReaderTheme.sepia,
            ReaderTheme.dark => katbook.ReaderTheme.dark,
          };
          epubState.readerKey.currentState?.setTheme(kt);
        }
      case 'fb2':
        _fb2ReaderKey.currentState?.setTheme(readerTheme);
      case 'mobi':
      case 'azw3':
        _mobiReaderKey.currentState?.setTheme(readerTheme);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final content = checkWidget();
    if (!widget.isSecondary) return content;

    // Secondary reader: wrap with hover-revealed close button.
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          content,
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Material(
                elevation: _isHovering ? 4 : 0,
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _closeSecondary,
                  tooltip: 'Close reader',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _closeSecondary() async {
    // Persist PDF progress for the secondary reader on close. Other engines
    // have been saving via callbacks throughout the session.
    await saveProgress();

    widget.onCloseSecondary?.call();
  }
}
