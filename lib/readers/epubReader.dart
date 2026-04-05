import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import 'package:katbook_epub_reader/src/models/reading_position.dart';


class EpubReaderScreen extends StatefulWidget {
  /// EPUB bytes to load (priority 1)
  final Uint8List? epubBytes;
  
  /// URL of the EPUB to download (priority 2)
  final String? url;
  
  /// Path of the EPUB asset to load (priority 3)
  final String? assetPath;
  
  /// Callback called when the user closes the reader
  final VoidCallback? onClose;
  
  /// Initial reader theme
  final ReaderTheme initialTheme;
  
  /// Initial font size
  final double initialFontSize;
  
  /// Width percentage of the screen for content
  final double contentWidthPercent;
  
  /// Show the app bar
  final bool showAppBar;
  
  /// Callback when the position changes
  final void Function(ReadingPosition position)? onPositionChanged;
  
  /// Callback when progress changes
  final void Function(double progress)? onProgressChanged;
  
  /// Callback when the chapter changes
  final void Function(ChapterNode chapter)? onChapterChanged;

  /// Initial locale of the reader
  final Locale? locale;

  /// Callback when the language changes
  final void Function(Locale locale)? onLocaleChanged;

  /// Show the language selection button
  final bool showLanguageButton;

  /// Show the theme selection button
  final bool showThemeButton;

  //Initial Reader Position
  final ReadingPosition? initialPosition;

  const EpubReaderScreen({
    super.key,
    this.epubBytes,
    this.url,
    this.assetPath,
    this.onClose,
    this.initialTheme = ReaderTheme.light,
    this.initialPosition,
    this.initialFontSize = 16.0,
    this.contentWidthPercent = 0.70,
    this.showAppBar = true,
    this.onPositionChanged,
    this.onProgressChanged,
    this.onChapterChanged,
    this.locale,
    this.onLocaleChanged,
    this.showLanguageButton = true,
    this.showThemeButton = true,
  }) : assert(
         epubBytes != null || url != null || assetPath != null,
         'At least one of epubBytes, url, or assetPath must be provided',
       );

  @override
  State<EpubReaderScreen> createState() => EpubReaderScreenState();
}

class EpubReaderScreenState extends State<EpubReaderScreen> {
  final KatbookEpubController _controller = KatbookEpubController();
  final GlobalKey<KatbookEpubReaderState> _readerKey =
      GlobalKey<KatbookEpubReaderState>();
  bool _isLoading = true;
  String? _error;

  /// Accès public au controller pour des opérations avancées
  KatbookEpubController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _loadEpub();
    print(widget.initialPosition);
  }

  Future<void> _loadEpub() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Uint8List? bytes;

      // Priorité 1: bytes directs
      if (widget.epubBytes != null) {
        bytes = widget.epubBytes;
        debugPrint('📂 Loading EPUB from bytes (${bytes!.length} bytes)');
      }
      // Priorité 2: URL
      else if (widget.url != null) {
        debugPrint('📥 Downloading EPUB from: ${widget.url}');
        final response = await http.get(Uri.parse(widget.url!));

        if (response.statusCode != 200) {
          throw Exception('Failed to download: HTTP ${response.statusCode}');
        }

        bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          throw Exception('Downloaded file is empty');
        }
        debugPrint('✅ Downloaded ${bytes.length} bytes');
      }
      // Priorité 3: asset
      else if (widget.assetPath != null) {
        debugPrint('📂 Loading EPUB from assets: ${widget.assetPath}');
        final byteData = await rootBundle.load(widget.assetPath!);
        bytes = byteData.buffer.asUint8List();
      }

      if (bytes == null) {
        throw Exception('No EPUB source provided');
      }

      final success = await _controller.openBook(bytes);
      if (!success) {
        throw Exception(_controller.loadingError ?? 'Failed to parse EPUB');
      }

      debugPrint('✅ EPUB loaded: ${_controller.title}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Recharger l'EPUB
  Future<void> reload() => _loadEpub();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text('Loading...'),
                leading: widget.onClose != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      )
                    : null,
              )
            : null,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading EPUB...'),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text('Error'),
                leading: widget.onClose != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      )
                    : null,
              )
            : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error loading EPUB',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadEpub,
                  child: const Text('Try Again'),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onClose,
                    child: const Text('Go Back'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Show the EPUB reader
    return KatbookEpubReader(
      key: _readerKey,
      controller: _controller,
      initialPosition: widget.initialPosition,

      // Theme and font settings
      initialTheme: widget.initialTheme,
      initialFontSize: widget.initialFontSize,

      // Layout settings
      contentWidthPercent: widget.contentWidthPercent,
      showAppBar: widget.showAppBar,

      // Language settings
      locale: widget.locale,
      showLanguageButton: widget.showLanguageButton,
      showThemeButton: widget.showThemeButton,

      // Callbacks for tracking
      onPositionChanged: widget.onPositionChanged ?? (position) {
        debugPrint(
          '📖 Position: Chapter ${position.chapterIndex}, '
          'Paragraph ${position.paragraphIndex}/${position.totalParagraphs}, '
          'Progress: ${position.progressPercent.toStringAsFixed(1)}%',
        );
      },
      onProgressChanged: widget.onProgressChanged ?? (progress) {
        debugPrint('📊 Progress: ${(progress * 100).toStringAsFixed(1)}%');
      },
      onChapterChanged: widget.onChapterChanged ?? (chapter) {
        debugPrint('📑 Chapter: ${chapter.title} (Depth: ${chapter.depth})');
      },
      onLocaleChanged: widget.onLocaleChanged ?? (locale) {
        debugPrint('🌐 Language changed to: ${locale.languageCode}');
      },
    );
  }
}