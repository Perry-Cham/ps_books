import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microsoft_viewer/domain/common_processor.dart';
import 'package:microsoft_viewer/domain/presentation_processor.dart';
import 'package:microsoft_viewer/domain/spreadsheet_processor.dart';
import 'package:microsoft_viewer/domain/word_processor.dart';
import 'package:microsoft_viewer/models/document.dart';
import 'package:microsoft_viewer/models/font_details.dart';
import 'package:microsoft_viewer/models/foot_end_note.dart';
import 'package:microsoft_viewer/models/presentation.dart';
import 'package:microsoft_viewer/models/relationship.dart';
import 'package:microsoft_viewer/models/spreadsheet.dart';
import 'package:microsoft_viewer/models/ss_color_schemes.dart';
import 'package:microsoft_viewer/models/ss_style.dart';
import 'package:microsoft_viewer/models/styles.dart';
import 'package:microsoft_viewer/models/web_images.dart';
import 'package:microsoft_viewer/utils/odttf.dart';
import 'package:microsoft_viewer/widget/progress_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'models/shared_string.dart';

/// The main entry widget. Takes a `List<int>` of file bytes and renders the
/// document (Word / Excel / PowerPoint) inside a scrollable, zoomable view.
///
/// Performance notes (see `microsoft_viewer_flutter_docx_performance_analysis.docx`):
/// * **No disk extraction for word media.** The archive stays in memory;
///   images render via `Image.memory(bytes)`. This removes Stage 6 (eager
///   disk writes for every `word/media/*` entry) from the pipeline.
/// * **No per-element `compute()`.** All parsing is synchronous on the main
///   isolate — see `WordProcessor` and `CommonProcessor`.
/// * **Parallel font loading** via `Future.wait`, replacing the serial
///   `await` loop that previously took 60–300 ms for the demo.docx.
/// * **`Map`-based lookups.** `stylesById` / `relsById` / `archiveByName`
///   are built once at the start of `parseAndShowData` and passed to every
///   downstream consumer, eliminating O(S) and O(N) linear scans in hot
///   paths.
/// * **`ListView.builder` for the document body.** Replaces
///   `SingleChildScrollView + Column`, which previously laid out every
///   paragraph on the first frame. Now only visible paragraphs are built
///   and laid out.
/// * **ODTTF no longer mutates archive bytes in place.** Re-parsing the
///   same archive no longer corrupts fonts.
class MicrosoftViewer extends StatefulWidget {
  /// Bytes of the file.
  final List<int> fileBytes;

  /// Is widget fixed height.
  final bool fixedHeight;

  /// Scaling value.
  final double scale;

  /// Width.
  final double? width;

  /// Height.
  final double? height;

  /// Constructor.
  const MicrosoftViewer(
    this.fileBytes,
    this.fixedHeight, {
    this.scale = 1.6,
    this.width,
    this.height,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => MicrosoftViewerState();
}

/// Stateful widget of the package.
class MicrosoftViewerState extends State<MicrosoftViewer> {
  ZipDecoder? _zipDecoder;

  /// Word directory — kept for backwards compat but no longer used by the
  /// word renderer (we use in-memory bytes for media now).
  String wordOutputDirectory = '';

  /// Spreadsheet directory.
  String spreadSheetOutputDirectory = '';

  /// Presentation directory.
  String presentationOutputDirectory = '';

  /// To store file type.
  String fileType = '';

  /// To store archive file.
  late Archive archive;

  /// Cached archive lookups — `Map<String, ArchiveFile>` keyed by full
  /// archive-entry name. Built once at the start of `parseAndShowData`.
  /// Replaces the repeated `archive.singleWhere(...)` linear scans that
  /// fire on every font / media / xml lookup.
  Map<String, ArchiveFile> archiveByName = <String, ArchiveFile>{};

  /// List of relationships (kept for the spreadsheet/presentation paths).
  List<Relationship> relationShips = [];

  /// `Map<String, Relationship>` keyed by `id`. Built once after
  /// `getRelationships` for O(1) image-rel lookups.
  Map<String, Relationship> relsById = <String, Relationship>{};

  /// List of strings.
  List<SharedString> sharedStrings = [];

  /// Element depth.
  int elementDepth = 0;

  /// Sequence number.
  int seqNo = 0;

  /// Document object.
  Document wordDocument = Document('empty word document');

  /// Presentation object.
  Presentation presentation = Presentation('empty presentation document');

  /// Spreadsheet object.
  SpreadSheet spreadSheet = SpreadSheet('empty spread sheet');

  /// List of styles (raw, direct definitions only).
  List<Styles> stylesList = [];

  /// `Map<String, Styles>` — raw styleId → Styles. Built once after
  /// `processStylesFile`.
  Map<String, Styles> stylesById = <String, Styles>{};

  /// `Map<String, Styles>` — styleId → fully-resolved style (with
  /// `w:basedOn` inheritance applied). Use this in the render path.
  Map<String, Styles> resolvedStylesById = <String, Styles>{};

  /// List of word widgets — populated eagerly for the legacy
  /// `SingleChildScrollView` callers. The new `ListView.builder` path uses
  /// [renderItems] instead and ignores this list.
  List<Widget> wordWidgets = [];

  /// Flattened render items for the new virtualized `ListView.builder`.
  /// Each item is one paragraph / table / footnote / page-break.
  List<WordRenderItem> renderItems = <WordRenderItem>[];

  /// List of presentation widgets.
  List<Widget> presentationWidgets = [];

  /// List of fonts.
  List<FontDetails> fontList = [];

  /// List of foot notes.
  List<FootEndNote> footNotes = [];

  /// List of endNotes.
  List<FootEndNote> endNotes = [];

  /// List of spreadsheet styles.
  List<SSStyle> spreadSheetStyles = [];

  /// List of spreadsheet widgets.
  List<Widget> spreadSheetWidgets = [];

  /// List of spreadsheet color schemes.
  List<SSColorSchemes> spreadSheetColorSchemes = [];

  /// List of web images. On non-web platforms this is also populated now
  /// (we use it as an in-memory media cache for `Image.memory`).
  List<WebImages> webImages = [];

  /// `Map<String, Uint8List>` — media entry basename → bytes. Built once
  /// at the start of the word parse, used to populate `MsImage.bytes` at
  /// parse time so the renderer can use `Image.memory` directly.
  Map<String, Uint8List> mediaByName = <String, Uint8List>{};

  /// To show progress bar.
  bool showProgressBar = true;

  /// Cached [WordProcessor] instance — `itemBuilder` is called frequently
  /// during scroll, so we avoid re-allocating the processor on every visible
  /// item.
  final WordProcessor _wordProcessor = WordProcessor();

  @override
  void initState() {
    parseAndShowData();
    super.initState();
  }

  /// Main parse-and-show entry point.
  Future<void> parseAndShowData() async {
    _zipDecoder ??= ZipDecoder();
    archive = _zipDecoder!.decodeBytes(widget.fileBytes);

    // Build the archive-name cache (Fix #10) — one O(n) pass over the
    // archive replaces every subsequent `singleWhere` / `where` scan.
    archiveByName = {
      for (final ArchiveFile f in archive) f.name: f,
    };

    // Detect file type via the cache (no more 3× O(n) archive.any scans).
    if (archiveByName.containsKey('word/document.xml')) {
      fileType = 'word';
    } else if (archiveByName.containsKey('xl/workbook.xml')) {
      setState(() => fileType = 'spreadsheet');
    } else if (archiveByName.containsKey('ppt/presentation.xml')) {
      setState(() => fileType = 'presentation');
    }

    if (fileType == 'word') {
      await _parseWordFile();
    } else if (fileType == 'spreadsheet') {
      await _parseSpreadSheetFile();
    } else if (fileType == 'presentation') {
      await _parsePresentationFile();
    }
  }

  /// Word-specific parse pipeline. Implements Fixes #2/#3/#5/#6/#10.
  Future<void> _parseWordFile() async {
    // Stage A — relationships (relsById map).
    final ArchiveFile? relFile = _findArchiveFile((String n) =>
        n.endsWith('document.xml.rels'));
    if (relFile != null) {
      getRelationships(relFile);
      relsById = {
        for (final Relationship r in relationShips) r.id: r,
      };
    }

    // Stage B — in-memory media cache. NO disk extraction.
    // We populate `webImages` (for non-web too) and `mediaByName`. The
    // renderer uses `Image.memory(bytes)` directly, skipping all File I/O.
    webImages = [];
    mediaByName = {};
    for (final ArchiveFile medFile in archive) {
      if (!medFile.name.startsWith('word/media/')) continue;
      final String mediaName = medFile.name.split('/').last;
      final Uint8List bytes = Uint8List.fromList(medFile.content);
      webImages.add(WebImages(mediaName, bytes));
      mediaByName[mediaName] = bytes;
    }

    // Stage C — styles (single-pass, no compute(); stylesById + resolvedStylesById maps).
    final ArchiveFile? stylesFile = _findArchiveFile(
        (String n) => n.endsWith('word/styles.xml'));
    final Map<String, String> defaultValues = <String, String>{};
    if (stylesFile != null) {
      CommonProcessor().processStylesFile(
        stylesFile,
        stylesList,
        defaultValues,
        stylesById: stylesById,
        resolvedStylesById: resolvedStylesById,
      );
      if (defaultValues.isNotEmpty) {
        if (defaultValues['fontSize'] != null) {
          wordDocument.defaultFontSize = int.parse(defaultValues['fontSize']!);
        }
        if (defaultValues['lineSpacing'] != null) {
          wordDocument.defaultLineSpacing =
              int.parse(defaultValues['lineSpacing']!);
        }
      }
    }

    // Stage D — fonts. Parse the font table, then load fonts in PARALLEL
    // (Future.wait) instead of a serial await loop.
    final ArchiveFile? fontTable = _findArchiveFile(
        (String n) => n.endsWith('word/fontTable.xml'));
    if (fontTable != null) {
      final ArchiveFile? fontTableRel = _findArchiveFile(
          (String n) => n.endsWith('_rels/fontTable.xml.rels'));
      if (fontTableRel != null) {
        CommonProcessor().processFonts(fontList, fontTable, fontTableRel);
        await Future.wait(fontList.map((FontDetails f) async {
          final ArchiveFile? fontFile = _findArchiveFile(
              (String n) => n.endsWith(f.fileName));
          if (fontFile == null) return;
          final String fontKey =
              f.fontKey.replaceAll('{', '').replaceAll('}', '');
          await loadFonts(fontFile, f.name, fontKey);
        }));
      }
    }

    // Stage E — foot/endnotes.
    final ArchiveFile? footNoteFile =
        _findArchiveFile((String n) => n.endsWith('footnotes.xml'));
    final ArchiveFile? endNoteFile =
        _findArchiveFile((String n) => n.endsWith('endnotes.xml'));
    _wordProcessor.processFootEndNotes(
        footNoteFile, endNoteFile, footNotes, endNotes);

    // Stage F — document.xml (synchronous, single-pass, no compute()).
    final ArchiveFile? wordFile = archiveByName['word/document.xml'];
    if (wordFile == null) return;
    await _wordProcessor.processWordFile(
      wordFile,
      elementDepth,
      relationShips,
      wordOutputDirectory,
      stylesList,
      wordDocument,
      fileType,
      stylesById: resolvedStylesById, // pass resolved styles for inheritance
      relsById: relsById,
      mediaByName: mediaByName,
      webImages: webImages,
    );

    // Stage G — build the flat render-items list (no widget construction yet;
    // widgets are built lazily inside ListView.builder's itemBuilder).
    renderItems = _wordProcessor.buildRenderItems(wordDocument);

    // Stage H — let the first frame paint with no widgets, then mark ready.
    // Fonts may still be loading in the background; text initially renders in
    // the fallback font and swaps to the embedded font when registration
    // completes (progressive enhancement, like web fonts).
    setState(() {
      showProgressBar = false;
    });
  }

  Future<void> _parseSpreadSheetFile() async {
    // Out of scope for this optimization pass — preserved verbatim from the
    // original implementation.
    await setupDirectory();
    final ArchiveFile? relFile = _findArchiveFile(
        (String n) => n.endsWith('workbook.xml.rels'));
    if (relFile != null) {
      getRelationships(relFile);
    }
    final ArchiveFile? stylesFile = _findArchiveFile(
        (String n) => n.endsWith('xl/styles.xml'));
    if (stylesFile != null) {
      spreadSheetStyles = [];
      SpreadsheetProcessor().processSpreadSheetStyles(
          stylesFile, spreadSheetStyles);
    }
    final Relationship? themRel = relationShips.firstWhereOrNull(
        (Relationship rel) => rel.target.startsWith('theme/theme'));
    if (themRel != null) {
      final ArchiveFile? themeFile = _findArchiveFile(
          (String n) => n.endsWith(themRel.target));
      if (themeFile != null) {
        spreadSheetColorSchemes = [];
        SpreadsheetProcessor().processColorSchemes(
            themeFile, spreadSheetColorSchemes);
      }
    }

    final ArchiveFile? shareStringsFile = _findArchiveFile(
        (String n) => n.endsWith('sharedStrings.xml'));
    if (shareStringsFile != null) {
      getSharedStrings(shareStringsFile);
    }
    final ArchiveFile? workbookFile = _findArchiveFile(
        (String n) => n.endsWith('xl/workbook.xml'));
    if (workbookFile == null) return;
    SpreadsheetProcessor().getSpreadSheetDetails(workbookFile, spreadSheet);
    await SpreadsheetProcessor().readAllSheets(
        spreadSheet, relationShips, archive);
    final List<Widget> tempWidgets = await SpreadsheetProcessor()
        .displaySpreadSheet(spreadSheet, sharedStrings, spreadSheetStyles,
            spreadSheetColorSchemes, width: widget.width ?? 500);
    setState(() {
      spreadSheetWidgets = tempWidgets;
      showProgressBar = false;
    });
  }

  Future<void> _parsePresentationFile() async {
    // Out of scope for this optimization pass — preserved verbatim from the
    // original implementation (only the archive-lookup cache is updated).
    await setupDirectory();
    final ArchiveFile? relFile = _findArchiveFile(
        (String n) => n.endsWith('presentation.xml.rels'));
    if (relFile != null) {
      getRelationships(relFile);
    }
    var mediaFile = archive.where((archiveFile) {
      return archiveFile.name.startsWith('ppt/media/');
    });
    webImages = [];
    for (var medFile in mediaFile) {
      if (kIsWeb) {
        final String mediaName = medFile.name.split('/').last;
        webImages.add(WebImages(mediaName, medFile.content));
      } else {
        extractMedia(medFile, presentationOutputDirectory);
      }
    }
    final ArchiveFile? presentationFile = _findArchiveFile(
        (String n) => n.endsWith('ppt/presentation.xml'));
    if (presentationFile == null) return;
    PresentationProcessor().getPresentationDetails(
        presentationFile, presentation);
    await PresentationProcessor().readAllSlides(
        presentation, relationShips, archive, presentationOutputDirectory);
    final List<Widget> tempWidgets = await PresentationProcessor()
        .displayPresentation(presentation, webImages,
            width: widget.width ?? 500);
    setState(() {
      presentationWidgets = tempWidgets;
      showProgressBar = false;
    });
  }

  /// Helper that uses the [archiveByName] cache (Fix #10). Returns the first
  /// `ArchiveFile` whose name satisfies [test], or null.
  ArchiveFile? _findArchiveFile(bool Function(String) test) {
    for (final MapEntry<String, ArchiveFile> entry in archiveByName.entries) {
      if (test(entry.key)) return entry.value;
    }
    return null;
  }

  /// Function for setting up directory. Only used by the spreadsheet and
  /// presentation paths now — the word path keeps media in memory.
  Future<void> setupDirectory() async {
    if (kIsWeb) {
      return;
    }
    final Directory applicationSupportDirectory =
        await getApplicationSupportDirectory();
    wordOutputDirectory = '${applicationSupportDirectory.path}/word/';
    spreadSheetOutputDirectory = '${applicationSupportDirectory.path}/spreadSheet/';
    presentationOutputDirectory =
        '${applicationSupportDirectory.path}/presentation/';
    // Only set up spreadsheet + presentation directories now; the word
    // renderer no longer touches disk.
    final Directory xlsDir = Directory(spreadSheetOutputDirectory);
    if (xlsDir.existsSync()) {
      xlsDir.deleteSync(recursive: true);
    }
    xlsDir.createSync(recursive: true);
    final Directory pptDir = Directory(presentationOutputDirectory);
    if (pptDir.existsSync()) {
      pptDir.deleteSync(recursive: true);
    }
    pptDir.createSync(recursive: true);
  }

  /// Function for getting relationships.
  void getRelationships(ArchiveFile relFile) {
    final String fileContent = utf8.decode(relFile.content);
    final xml.XmlDocument document = xml.XmlDocument.parse(fileContent);
    final Iterable<xml.XmlElement> relationshipsElement =
        document.findAllElements('Relationship');
    relationShips = [];
    for (final xml.XmlElement rel in relationshipsElement) {
      final String? id = rel.getAttribute('Id');
      if (id != null) {
        relationShips
            .add(Relationship(id, rel.getAttribute('Target').toString()));
      }
    }
  }

  /// Function for getting strings.
  void getSharedStrings(ArchiveFile shareStringsFile) {
    final String fileContent = utf8.decode(shareStringsFile.content);
    final xml.XmlDocument document = xml.XmlDocument.parse(fileContent);
    sharedStrings = [];
    int index = 0;
    document.findAllElements('si').forEach((node) {
      sharedStrings
          .add(SharedString(index, node.getElement('t')?.innerText ?? ''));
      index++;
    });
  }

  /// Function for extracting media files (only used by the presentation path
  /// now; the word path uses in-memory bytes).
  Future<void> extractMedia(ArchiveFile mediaFile, String dirPath) async {
    final String outputFilePath =
        dirPath + mediaFile.name.split('/').last;
    final File outFile = File(outputFilePath);
    await outFile.writeAsBytes(mediaFile.content as List<int>);
  }

  /// Load (and register) one embedded font.
  ///
  /// Uses the new [ODTTF.deobfuscate] which returns a fresh `Uint8List`
  /// instead of mutating the archive's bytes in place. This fixes the
  /// latent bug where re-parsing the same archive twice would corrupt
  /// font bytes (the XOR was applied twice to the same buffer).
  Future<void> loadFonts(
      ArchiveFile fontFile, String fontFamily, String fileName) async {
    final Uint8List raw = fontFile.content is Uint8List
        ? fontFile.content as Uint8List
        : Uint8List.fromList(fontFile.content);
    final Uint8List deobfuscated = ODTTF().deobfuscate(raw, fileName);
    final ByteData byteData = ByteData.view(deobfuscated.buffer);
    final FontLoader fontLoader = FontLoader(fontFamily)
      ..addFont(Future<ByteData>.value(byteData));
    await fontLoader.load();
  }

  @override
  Widget build(BuildContext context) {
    return customWidget(
      LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.1,
              maxScale: 1.6,
              child: Center(
                child: Container(
                  color: Colors.grey,
                  height: widget.height ?? 700,
                  width: widget.width ?? 500,
                  // FIX #2: virtualized scrolling.
                  // - For word: use ListView.builder over [renderItems].
                  //   Only visible items are built and laid out, replacing
                  //   the old SingleChildScrollView+Column that eagerly
                  //   laid out all ~340 components on the first frame.
                  // - For spreadsheet/presentation: keep the old eager
                  //   Column path (those paths are out of scope for this
                  //   optimization pass).
                  child: fileType == 'word'
                      ? _buildWordListView()
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: fileType == 'spreadsheet'
                                ? spreadSheetWidgets
                                : presentationWidgets,
                          ),
                        ),
                ),
              ),
            ),
            if (showProgressBar)
              ProgressIndicatorView(constraints.maxHeight, constraints.maxWidth)
            else
              const SizedBox.shrink(),
          ],
        );
      }),
    );
  }

  /// Build the virtualized word document list. Each item is one paragraph,
  /// table, footnote, endnote, or page-break. Widgets are built lazily
  /// inside `itemBuilder`, so only visible items pay the construction cost.
  Widget _buildWordListView() {
    if (renderItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      // Slightly larger cache extent reduces rebuilds during fast scrolls.
      cacheExtent: 800,
      // Don't keep alive — long documents would otherwise hold every
      // built paragraph widget in memory.
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      padding: const EdgeInsets.all(8),
      itemCount: renderItems.length,
      itemBuilder: (BuildContext context, int index) {
        final WordRenderItem item = renderItems[index];
        final Widget inner = _wordProcessor.buildItemWidget(
          item,
          wordDocument,
          resolvedStylesById,
          footNotes,
          endNotes,
          webImages,
        );

        // Apply page-level styling: white background, page margins for the
        // first component of a page, bottom padding for the last component.
        final bool isFirstOfPage = index == 0 ||
            renderItems[index - 1].kind == WordRenderItemKind.pageBreak;
        final bool isLastOfPage = index == renderItems.length - 1 ||
            (index + 1 < renderItems.length &&
                renderItems[index + 1].kind ==
                    WordRenderItemKind.pageBreak);

        final double left = wordDocument.pageMargin['leftMar'] ?? 0;
        final double right = wordDocument.pageMargin['rightMar'] ?? 0;
        final double top = isFirstOfPage
            ? (wordDocument.pageMargin['topMar'] ?? 0)
            : 0.0;
        final double bottom = isLastOfPage
            ? (wordDocument.pageMargin['bottomMar'] ?? 0)
            : 0.0;

        return Container(
          color: Colors.white,
          constraints: BoxConstraints(
            minWidth: wordDocument.pageSize.width,
          ),
          padding: EdgeInsets.only(
              left: left, right: right, top: top, bottom: bottom),
          child: inner,
        );
      },
    );
  }

  /// Custom widget for showing fixed height.
  Widget customWidget(Widget child) {
    if (!widget.fixedHeight) {
      return Expanded(child: child);
    } else {
      return Column(
        children: <Widget>[
          Expanded(child: child),
        ],
      );
    }
  }
}
