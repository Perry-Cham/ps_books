import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/state/global_settings.dart';

import '../dbs/database.dart';
import '../reader_utils/destinations_sheet.dart';
import '../reader_utils/immersive_mode.dart';
import '../reader_utils/reader_destination.dart';
import '../reader_utils/theme.dart';
import '../routes/ai_chat.dart';
import '../tools/notes/notes.dart' as note;
import '../services/dbServices/bookToDb.dart';
import '../state/pomodoro_timer.dart';
import '../state/reader_state.dart';
import 'reader.dart';

/// The scaffold that hosts one or two [Reader] widgets plus an optional
/// [AiChatPanel].
///
/// Owns:
///   * The AppBar (with destinations / settings / AI-chat / second-reader /
///     immersive-mode controls). The slimmed [Reader] widget renders NO
///     chrome of its own.
///   * The split-screen layout: a primary [Reader] always fills the main
///     column; on desktop, a secondary [Reader] OR an [AiChatPanel] can be
///     shown beside it (mutually exclusive — enforced by [ReaderStateNotifier]).
///   * The [ImmersiveModeController] — broadcasts immersive-mode state to
///     itself (AppBar slide animation) and to each [Reader] (page-count
///     overlay slide animation).
///   * The destinations dispatch — the AppBar hamburger button calls
///     [showDestinationsSheet] with a loader backed by the primary
///     [Reader]'s [DestinationCapable] interface.
///
/// Mobile vs desktop:
///   * On mobile (Android/iOS), the AI-chat / second-reader popup items do
///     NOT appear in the AppBar overflow (per the user's spec).
///   * On mobile, immersive mode is engaged automatically when the shell
///     opens; the user exits by tapping the centre of the screen.
///   * On desktop, immersive mode is engaged by an AppBar button; the user
///     exits by tapping the floating "hatch" FAB.
class ReaderShell extends ConsumerStatefulWidget {
  const ReaderShell({
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
  final String? position;

  @override
  ConsumerState<ReaderShell> createState() => _ReaderShellState();
}

class _ReaderShellState extends ConsumerState<ReaderShell>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ReaderWidgetState> _primaryReaderKey = GlobalKey();
  final GlobalKey<ReaderWidgetState> _secondaryReaderKey = GlobalKey();

  ReaderTheme _readerTheme = ReaderTheme.light;

  late final ImmersiveModeController _immersiveController;
  late final AnimationController _appBarSlideController;
  late final Animation<Offset> _appBarSlide;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final BookToDb _db = BookToDb();

  @override
  void initState() {
    super.initState();
    _immersiveController = ImmersiveModeController();
    _appBarSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _appBarSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
        .animate(
          CurvedAnimation(
            parent: _appBarSlideController,
            curve: Curves.easeInOut,
          ),
        );
    _immersiveController.addListener(_onImmersiveChanged);

    // Auto-engage immersive mode on mobile when the reader opens.
    if (isMobilePlatform) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _immersiveController.enter();
      });
    }
  }

  void _onImmersiveChanged() {
    final isImmersive = _immersiveController.value;
    if (isImmersive) {
      _appBarSlideController.forward();
    } else {
      _appBarSlideController.reverse();
    }
    // setState so the centre-tap overlay, hatch FAB, and the body's
    // AnimatedPadding all react to immersive-mode toggles.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _immersiveController.removeListener(_onImmersiveChanged);
    _immersiveController.dispose();
    _appBarSlideController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get _title {
    try {
      return widget.path.split(Platform.pathSeparator).last;
    } catch (_) {
      return 'Reader';
    }
  }

  String _truncateTitle(int maxChars, String title) {
    if (title.length > maxChars) {
      return '${title.substring(0, maxChars)}...';
    }
    return title;
  }

  // ---------------------------------------------------------------------------
  // AppBar actions
  // ---------------------------------------------------------------------------

  Future<void> _showDestinations() async {
    final state = _primaryReaderKey.currentState;
    if (state == null) return;
    await showDestinationsSheet(
      context: context,
      loader: state.getDestinations,
      onSelected: (d) {
        unawaited(state.goToDestination(d));
      },
    );
  }

  void _showSettings() {
    _primaryReaderKey.currentState?.showSettings();
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
              Text('Select a Book', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: StreamBuilder<List<Book>>(
                  stream: _db.watchAllBooks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final books = snapshot.data!;
                    if (books.isEmpty) {
                      return const Center(child: Text('No books in library'));
                    }
                    return ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (ctx, index) {
                        final book = books[index];
                        return ListTile(
                          leading: book.coverPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
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

  Widget _buildAppBar() {
    final chromeColor = _readerTheme == ReaderTheme.dark
        ? Theme.of(context).colorScheme.surface
        : ReaderThemeData.fromTheme(_readerTheme).appBarColor;
    return Material(
      color: chromeColor,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: AppBar(
          // Hamburger → destinations sheet (the document's outline / TOC /
          // chapter list, exposed via the Reader's DestinationCapable impl).
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            tooltip: 'Bookmarks',
          ),
          title: Text(_truncateTitle(20, _title)),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                final state = ref.read(readerStateProvider);
                return [
                  // AI Chat / Add Reader are desktop-only per the user's spec.
                  if (!isMobilePlatform)
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
                        spacing: 8,
                        children: [
                          Icon(
                            state.showAiChat
                                ? Icons.close
                                : Icons.chat_bubble_outline,
                          ),
                          Text(state.showAiChat ? 'Close AI Chat' : 'AI Chat'),
                        ],
                      ),
                    ),
                  if (!isMobilePlatform)
                    PopupMenuItem(
                      onTap: () {
                        ref
                            .read(readerStateProvider.notifier)
                            .setShowNotesTrue();
                      },
                      child: Row(spacing: 8, children: [Text("Open Notes")]),
                    ),
                  if (!isMobilePlatform)
                    PopupMenuItem(
                      onTap: _showBookSelector,
                      child: Row(
                        spacing: 8,
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
                  // Immersive mode toggle — visible on all platforms, but on
                  // mobile the user will typically rely on the auto-engage +
                  // centre-tap-to-exit flow. Provided here as a manual override.
                  PopupMenuItem(
                    onTap: () => _immersiveController.toggle(),
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(
                          _immersiveController.value
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                        ),
                        Text(
                          _immersiveController.value
                              ? 'Exit Immersive'
                              : 'Immersive Mode',
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
              tooltip: 'Reader Settings',
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(readerStateProvider.notifier).setShowAiChatFalse();
                ref.read(readerStateProvider.notifier).clearSecondBook();
              },
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final readerState = ref.watch(readerStateProvider);
    final showAi = readerState.showAiChat;
    final secondBookId = readerState.secondBookId;
    final showNotes = readerState.showNotes;
    print(_readerTheme);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Top padding leaves room for the AppBar. When immersive mode is
        // engaged, the padding shrinks to just the status-bar safe area so
        // the reader content fills the freed space. AnimatedPadding keeps
        // the transition in sync with the AppBar's SlideTransition.
        final statusBar = MediaQuery.of(context).padding.top;
        final isImmersive = _immersiveController.value;
        final topPad = isImmersive ? statusBar : statusBar + kToolbarHeight;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(top: topPad),
          child: Row(
            children: [
              Expanded(
                flex: showAi ? 6 : (secondBookId != null ? 5 : 1),
                child: Reader(
                  key: _primaryReaderKey,
                  type: widget.type,
                  path: widget.path,
                  id: widget.id,
                  page: widget.page,
                  position: widget.position,
                  immersiveController: _immersiveController,
                  onThemeChanged: (theme) {
                    if (mounted) setState(() => _readerTheme = theme);
                  },
                ),
              ),
              if (showAi && !isMobilePlatform)
                Expanded(
                  flex: 4,
                  child: AiChatPanel(
                    onClose: () => ref
                        .read(readerStateProvider.notifier)
                        .setShowAiChatFalse(),
                  ),
                )
              else if (secondBookId != null && !isMobilePlatform)
                Expanded(
                  flex: 5,
                  child: _SecondaryReaderHost(
                    key: ValueKey(secondBookId),
                    bookId: secondBookId,
                    secondaryKey: _secondaryReaderKey,
                    immersiveController: _immersiveController,
                    onClose: () => ref
                        .read(readerStateProvider.notifier)
                        .clearSecondBook(),
                  ),
                )
              else if (showNotes && !isMobilePlatform)
                Expanded(flex: 3, child: note.Notes()),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scaffold = PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // Best-effort persist of the primary reader's PDF progress on pop.
        // Other engines save continuously via callbacks.
        await _primaryReaderKey.currentState?.saveProgress();
        await _secondaryReaderKey.currentState?.saveProgress();
        await _db.setCurrentlyReading(widget.id);
        ref.read(readerStateProvider.notifier).setIsReadingFalse();
      },
      canPop: true,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _BookmarksDrawer(readerKey: _primaryReaderKey),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // 1. Body Row: primary reader + optional AI chat OR second reader.
              Positioned.fill(child: _buildBody()),

              // 2. AppBar — slides up out of view in immersive mode.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _appBarSlide,
                  child: _buildAppBar(),
                ),
              ),

              // 3. Mobile centre-tap-to-exit overlay (only when immersive).
              if (isMobilePlatform && _immersiveController.value)
                Positioned.fill(
                  child: _CenterTapExitOverlay(
                    onTap: _immersiveController.exit,
                  ),
                ),

              // 4. Desktop "hatch" FAB — exits immersive mode on tap.
              if (!isMobilePlatform && _immersiveController.value)
                Positioned(
                  top: 20,
                  right: 20,
                  child: _ImmersiveHatchButton(
                    onTap: _immersiveController.exit,
                  ),
                ),

              // 5. Pomodoro overlay (desktop-only, unchanged from original).
              const Positioned(
                bottom: 20,
                left: 20,
                child: FloatingDesktopClockOverlay(),
              ),
            ],
          ),
        ),
      ),
    );

    final globalTheme = ref.watch(settingsProvider);

    globalTheme.when(
      data: (data) {
        final chromeTheme = _readerTheme == ReaderTheme.dark
            ? null
            : _buildChromeTheme(context);

        if (data.appTheme.name == "dark") {
          setState(() {
            _readerTheme = ReaderTheme.dark;
          });
          print(_readerTheme);

          return chromeTheme != null
              ? Theme(data: chromeTheme, child: scaffold)
              : scaffold;
        } else {
          setState(() {
            _readerTheme = ReaderTheme.dark;
          });
          print(_readerTheme);
          return chromeTheme != null
              ? Theme(data: chromeTheme, child: scaffold)
              : scaffold;
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (e, h) {
        return scaffold;
      },
    );

    return scaffold;
  }

  ThemeData _buildChromeTheme(BuildContext context) {
    final data = ReaderThemeData.fromTheme(_readerTheme);
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: data.backgroundColor,
      colorScheme: base.colorScheme.copyWith(surface: data.appBarColor),
      cardColor: data.appBarColor,
      popupMenuTheme: PopupMenuThemeData(color: data.appBarColor),
    );
  }
}

// -----------------------------------------------------------------------------
// Secondary reader host — async-loads the Book row then renders a secondary
// Reader. Replaces the old _SecondBookReader class.
// -----------------------------------------------------------------------------

class _SecondaryReaderHost extends StatefulWidget {
  const _SecondaryReaderHost({
    super.key,
    required this.bookId,
    required this.secondaryKey,
    required this.immersiveController,
    required this.onClose,
  });

  final int bookId;
  final GlobalKey<ReaderWidgetState> secondaryKey;
  final ValueListenable<bool> immersiveController;
  final VoidCallback onClose;

  @override
  State<_SecondaryReaderHost> createState() => _SecondaryReaderHostState();
}

class _SecondaryReaderHostState extends State<_SecondaryReaderHost> {
  Book? _book;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final book = await BookToDb().getBookById(widget.bookId);
    if (mounted) {
      setState(() {
        _book = book;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_book == null) {
      return const Center(child: Text('Book not found'));
    }
    return Reader(
      key: widget.secondaryKey,
      type: _book!.extension,
      path: _book!.path,
      id: _book!.id,
      page: _book!.page,
      position: _book!.cfi,
      isSecondary: true,
      immersiveController: widget.immersiveController,
      onCloseSecondary: widget.onClose,
    );
  }
}

// -----------------------------------------------------------------------------
// Mobile centre-tap-to-exit overlay
// -----------------------------------------------------------------------------

/// A transparent overlay that covers the centre third of the screen and
/// exits immersive mode on tap. Other areas of the screen pass through to
/// the reader engines (which handle page-turn taps on left/right edges).
///
/// The overlay is only rendered when immersive mode is engaged on mobile.
class _CenterTapExitOverlay extends StatelessWidget {
  const _CenterTapExitOverlay({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thirdWidth = width / 3;
        return Stack(
          children: [
            Positioned(
              left: thirdWidth,
              width: thirdWidth,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                // opaque so the centre-tap is captured and does NOT also
                // propagate to the engine below (which would turn the page).
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: const SizedBox.expand(
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 32,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Desktop "hatch" FAB
// -----------------------------------------------------------------------------

class _ImmersiveHatchButton extends StatelessWidget {
  const _ImmersiveHatchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: FloatingActionButton.small(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        onPressed: onTap,
        tooltip: 'Exit immersive mode',
        child: const Icon(Icons.fullscreen_exit, color: Colors.black87),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Floating Pomodoro overlay (moved verbatim from the old reader.dart)
// -----------------------------------------------------------------------------

class FloatingDesktopClockOverlay extends ConsumerWidget {
  const FloatingDesktopClockOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobilePlatform) return const SizedBox.shrink();

    final showTimer = ref.watch(
      readerStateProvider.select((s) => s.showPomodoroTimer),
    );
    final isTimerRunning = ref.watch(
      pomodoroProvider.select((s) => s.isRunning),
    );

    if (!showTimer && !isTimerRunning) return const SizedBox.shrink();

    if (!showTimer) {
      return IconButton.filled(
        onPressed: () {
          ref.read(readerStateProvider.notifier).setShowPomodoroTrue();
        },
        icon: const Icon(Icons.av_timer),
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
    final phaseLabel = isWorkPhase ? 'Focus Cycle' : 'Break Time';
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
                    color: phaseColor.withValues(alpha: 0.12),
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
              '$minutes:$seconds',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              'Cycle ${pomodoroState.currentCycle} of ${pomodoroState.cycles}',
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

//BOOKMARKS DRAWER
class _BookmarksDrawer extends StatefulWidget {
  const _BookmarksDrawer({required this.readerKey});
  final GlobalKey<ReaderWidgetState> readerKey;

  @override
  State<_BookmarksDrawer> createState() => _BookmarksDrawerState();
}

class _BookmarksDrawerState extends State<_BookmarksDrawer> {
  Future<List<ReaderDestination>>? _future;
  late final Future<List<ReaderDestination>>? getDestinations;
  late final Future<void> Function(ReaderDestination destination)?
  onDestinationSelected;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDestinations = widget.readerKey.currentState?.getDestinations();
    onDestinationSelected = widget.readerKey.currentState?.goToDestination;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch every time the drawer is rebuilt (i.e. opened).
    _future = getDestinations ?? Future.value(const []);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<ReaderDestination>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load: ${snapshot.error}'),
              ),
            );
          }
          final destinations = snapshot.data ?? const [];
          if (destinations.isEmpty) {
            return const Center(child: Text('No Bookmarks'));
          }
          return DestinationTree(
            destinations: destinations,
            onSelected: onDestinationSelected ?? (_) {},
          );
        },
      ),
    );
  }
}
