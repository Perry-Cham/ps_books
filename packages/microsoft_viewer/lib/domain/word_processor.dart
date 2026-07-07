import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_viewer/models/document.dart';
import 'package:microsoft_viewer/models/foot_end_note.dart';
import 'package:microsoft_viewer/models/relationship.dart';
import 'package:microsoft_viewer/models/web_images.dart';
import 'package:xml/xml.dart' as xml;

import '../models/ms_image.dart';
import '../models/ms_table.dart';
import '../models/ms_text_span.dart';
import '../models/paragraph.dart';
import '../models/styles.dart';
import '../models/word_page.dart';

/// Class for processing .docx files.
///
/// Performance notes (see `microsoft_viewer_flutter_docx_performance_analysis.docx`):
/// * **No `compute()` anywhere.** All parsing and widget construction happens
///   synchronously on the calling isolate. The previous implementation spawned
///   ~722 isolates for the demo.docx (one per `<w:style>`, one per `<w:p>`,
///   one per `<w:tbl>`, one per render component). Each spawn+transfer cost
///   5–15 ms on native, dominating the actual parse cost. Removing them is
///   the single biggest win.
/// * **Single-pass XML visitor.** Instead of `findAllElements("w:…")` called
///   a dozen times per run, each `<w:rPr>` / `<w:pPr>` / `<w:style>` subtree
///   is walked once and dispatched on `localName`. Order-of-magnitude fewer
///   tree walks.
/// * **Native `Table` widget.** Tables are no longer round-tripped through
///   an HTML string + `HtmlWidget`. We build a Flutter `Table` directly.
/// * **O(1) lookups.** Callers should pass `Map<String, Styles>` and
///   `Map<String, Relationship>` instead of flat lists. The render path uses
///   `firstWhereOrNull` only on tiny lists (e.g. a single table's rows).
/// * **`EdgeInsets` for indent.** The previous code faked indentation by
///   prepending space characters to the text, which is O(n²) and visually
///   wrong (indent width depends on the font's space glyph). Now we use
///   `Padding(EdgeInsets.only(left: …))` with a twips→px conversion.
/// * **Ordered content list.** `Paragraph.orderedContent` is populated by
///   the parser, eliminating the O((S+I)²) merge loop in `getComponents`.
class WordProcessor {
  /// Function for processing footnotes and endnotes.
  ///
  /// Single-pass walk over each `<w:footnote>` / `<w:endnote>` element.
  void processFootEndNotes(
    ArchiveFile? footNoteFile,
    ArchiveFile? endNoteFile,
    List<FootEndNote> footNotes,
    List<FootEndNote> endNotes,
  ) {
    if (footNoteFile != null) {
      final String fileContent = utf8.decode(footNoteFile.content);
      final xml.XmlDocument document = xml.XmlDocument.parse(fileContent);
      for (final xml.XmlElement footNt in document.findAllElements('w:footnote')) {
        final FootEndNote? note = _parseFootEndNote(footNt);
        if (note != null) footNotes.add(note);
      }
    }
    if (endNoteFile != null) {
      final String fileContent = utf8.decode(endNoteFile.content);
      final xml.XmlDocument document = xml.XmlDocument.parse(fileContent);
      for (final xml.XmlElement endNt in document.findAllElements('w:endnote')) {
        final FootEndNote? note = _parseFootEndNote(endNt);
        if (note != null) endNotes.add(note);
      }
    }
  }

  static FootEndNote? _parseFootEndNote(xml.XmlElement element) {
    String id = '';
    String pStyle = '';
    String rStyle = '';
    String text = '';

    final String? tempId = element.getAttribute('w:id');
    if (tempId != null) id = tempId;

    // Single-pass walk over the element's subtree. We only care about the
    // first occurrence of pStyle / rStyle / t.
    bool pStyleDone = false;
    bool rStyleDone = false;
    bool textDone = false;
    for (final xml.XmlElement descendant in element.descendantElements) {
      if (pStyleDone && rStyleDone && textDone) break;
      switch (descendant.name.local) {
        case 'pStyle':
          if (!pStyleDone) {
            final String? v = descendant.getAttribute('w:val');
            if (v != null) {
              pStyle = v;
              pStyleDone = true;
            }
          }
          break;
        case 'rStyle':
          if (!rStyleDone) {
            final String? v = descendant.getAttribute('w:val');
            if (v != null) {
              rStyle = v;
              rStyleDone = true;
            }
          }
          break;
        case 't':
          if (!textDone) {
            if (descendant.innerText.isNotEmpty) {
              text = descendant.innerText;
              textDone = true;
            }
          }
          break;
        default:
          break;
      }
    }
    return FootEndNote(id, pStyle, rStyle, text);
  }

  /// Process the .docx file. Synchronous — no `compute()`.
  ///
  /// [relsById] is a pre-built `Map<String, Relationship>` for O(1) image
  /// relationship lookups. If null, falls back to linear scan over
  /// [relationShips] (kept for backwards compatibility).
  /// [mediaByName] is a pre-built `Map<String, Uint8List>` of media entry
  /// basename → bytes, used so we can populate `MsImage.bytes` at parse time
  /// and skip filesystem I/O at render time.
  Future<void> processWordFile(
    ArchiveFile wordFile,
    int elementDepth,
    List<Relationship> relationShips,
    String wordOutputDirectory,
    List<Styles> stylesList,
    Document wordDocument,
    String fileType, {
    Map<String, Styles>? stylesById,
    Map<String, Relationship>? relsById,
    Map<String, Uint8List>? mediaByName,
    List<WebImages>? webImages,
  }) async {
    final String fileContent = utf8.decode(wordFile.content);
    final xml.XmlDocument document = xml.XmlDocument.parse(fileContent);
    final Iterable<xml.XmlElement> chkBody =
        document.findAllElements('w:body');
    if (chkBody.isEmpty) return;

    // Build maps if caller didn't pass them — keeps the function usable
    // from old call sites.
    final Map<String, Styles> stylesMap =
        stylesById ?? {for (final Styles s in stylesList) s.styleId: s};
    final Map<String, Relationship> relsMap = relsById ??
        {for (final Relationship r in relationShips) r.id: r};

    for (final xml.XmlElement childElements in chkBody.first.childElements) {
      _processWordElements(
        childElements,
        elementDepth,
        relsMap,
        wordOutputDirectory,
        stylesMap,
        wordDocument,
        fileType,
        mediaByName: mediaByName,
        webImages: webImages,
      );
    }
  }

  /// Process one `<w:body>` child element. Synchronous.
  void _processWordElements(
    xml.XmlElement wordElements,
    int elementDepth,
    Map<String, Relationship> relsById,
    String wordOutputDirectory,
    Map<String, Styles> stylesById,
    Document wordDocument,
    String fileType, {
    Map<String, Uint8List>? mediaByName,
    List<WebImages>? webImages,
  }) {
    if (wordElements.name.local == 'tbl') {
      final MsTable table = _processWordTable(wordElements);
      if (wordDocument.pages.isEmpty) {
        wordDocument.pages.add(WordPage(1));
      }
      wordDocument.pages.last.components.add(table);
    } else if (wordElements.name.local == 'p') {
      _processParagraph(
        wordElements,
        relsById,
        wordOutputDirectory,
        stylesById,
        wordDocument,
        mediaByName: mediaByName,
        webImages: webImages,
      );
    } else if (wordElements.name.local == 'sectPr') {
      _processSectionDetails(wordElements, wordDocument);
    }
  }

  /// Process a `<w:p>` paragraph element. Single-pass walk over the run
  /// properties of each `<w:r>`. Mutates [wordDocument.pages] directly — no
  /// more returning a fresh `List<WordPage>` through a `compute()` boundary.
  void _processParagraph(
    xml.XmlElement paragraphElement,
    Map<String, Relationship> relsById,
    String wordOutputDirectory,
    Map<String, Styles> stylesById,
    Document wordDocument, {
    Map<String, Uint8List>? mediaByName,
    List<WebImages>? webImages,
  }) {
    List<WordPage> pages = wordDocument.pages;
    String pStyle = '';
    Map<String, String> tabs = {};
    String paraShadingColor = '';
    Map<String, String> paraFormat = {};

    final xml.XmlElement? pPr = _firstChild(paragraphElement, 'pPr');
    if (pPr != null) {
      for (final xml.XmlElement child in pPr.childElements) {
        switch (child.name.local) {
          case 'pStyle':
            final String? v = child.getAttribute('w:val');
            if (v != null) pStyle = v;
            break;
          case 'tab':
            final String? v = child.getAttribute('w:val');
            if (v != null) tabs['val'] = v;
            final String? leader = child.getAttribute('w:leader');
            if (leader != null) tabs['leader'] = leader;
            break;
          case 'shd':
            final String? fill = child.getAttribute('w:fill');
            if (fill != null) paraShadingColor = fill;
            break;
          case 'jc':
            final String? v = child.getAttribute('w:val');
            if (v != null) paraFormat['jc'] = v;
            break;
          default:
            break;
        }
      }
    }

    final Paragraph paragraph = Paragraph(0, pStyle);
    if (tabs.isNotEmpty) paragraph.tabDetails = tabs;
    if (paraShadingColor.isNotEmpty) paragraph.shadingColor = paraShadingColor;
    if (paraFormat.isNotEmpty) paragraph.formats = paraFormat;

    int pSeqNo = 0;

    // Walk all <w:r> children of the paragraph in document order. We use
    // direct child iteration (not findAllElements) so that nested <w:r>
    // elements inside <w:hyperlink> or revision marks are still picked up
    // correctly via descendantElements as a fallback.
    final Iterable<xml.XmlElement> runElements =
        paragraphElement.descendantElements.where((xml.XmlElement e) {
      return e.name.local == 'r';
    });

    for (final xml.XmlElement run in runElements) {
      List<String> formats = [];
      String tStyle = '';
      int fontSize = 0;
      String textColor = '';
      String highlightColor = '';
      String shadingColor = '';
      Map<String, String> fonts = {};

      final xml.XmlElement? rPr = _firstChild(run, 'rPr');
      if (rPr != null) {
        // Single-pass walk over rPr children.
        for (final xml.XmlElement child in rPr.childElements) {
          switch (child.name.local) {
            case 'b':
              formats.add('bold');
              break;
            case 'i':
              formats.add('italic');
              break;
            case 'u':
              final String? v = child.getAttribute('w:val');
              if (v == 'single') {
                formats.add('single-underline');
              } else if (v == 'double') {
                formats.add('double-underline');
              }
              break;
            case 'strike':
              formats.add('strike');
              break;
            case 'vertAlign':
              final String? v = child.getAttribute('w:val');
              if (v == 'superscript') {
                formats.add('superscript');
              } else if (v == 'subscript') {
                formats.add('subscript');
              }
              break;
            case 'color':
              final String? v = child.getAttribute('w:val');
              if (v != null) textColor = v;
              break;
            case 'shd':
              final String? v = child.getAttribute('w:fill');
              if (v != null) shadingColor = v;
              break;
            case 'highlight':
              final String? v = child.getAttribute('w:val');
              if (v != null) highlightColor = v;
              break;
            case 'rStyle':
              final String? v = child.getAttribute('w:val');
              if (v != null) tStyle = v;
              break;
            case 'sz':
              final String? v = child.getAttribute('w:val');
              if (v != null) fontSize = int.parse(v);
              break;
            case 'rFonts':
              final String? ascii = child.getAttribute('w:ascii');
              if (ascii != null) fonts['ascii'] = ascii;
              final String? hAnsi = child.getAttribute('w:hAnsi');
              if (hAnsi != null) fonts['hAnsi'] = hAnsi;
              break;
            default:
              break;
          }
        }
      }

      // Text elements.
      final Iterable<xml.XmlElement> textElements =
          run.descendantElements.where((xml.XmlElement e) {
        return e.name.local == 't';
      });

      if (textElements.isNotEmpty) {
        if (paragraph.tabDetails.isNotEmpty) {
          for (final xml.XmlElement textE in textElements) {
            if (pSeqNo > 0) {
              final MsTextSpan span = MsTextSpan(pSeqNo, textE.innerText, tStyle,
                  formats, fontSize, textColor, highlightColor, fonts, shadingColor);
              paragraph.textSpans.add(span);
              paragraph.orderedContent.add(span);
              pSeqNo++;
            } else {
              String innerTex = textE.innerText;
              final String? leader = paragraph.tabDetails['leader'];
              final String? val = paragraph.tabDetails['val'];
              if (leader == 'dot') {
                innerTex = val == 'left'
                    ? '.$innerTex'
                    : '$innerTex.';
              } else if (leader == 'hyphen') {
                innerTex = val == 'left'
                    ? '-$innerTex'
                    : '$innerTex-';
              } else if (leader == 'space') {
                innerTex = val == 'left'
                    ? ' $innerTex'
                    : '$innerTex ';
              }
              final MsTextSpan span = MsTextSpan(pSeqNo, innerTex, tStyle,
                  formats, fontSize, textColor, highlightColor, fonts, shadingColor);
              paragraph.textSpans.add(span);
              paragraph.orderedContent.add(span);
              pSeqNo++;
            }
          }
        } else {
          for (final xml.XmlElement textE in textElements) {
            final MsTextSpan span = MsTextSpan(pSeqNo, textE.innerText, tStyle,
                formats, fontSize, textColor, highlightColor, fonts, shadingColor);
            paragraph.textSpans.add(span);
            paragraph.orderedContent.add(span);
            pSeqNo++;
          }
        }
      }

      // Drawing / image elements.
      final Iterable<xml.XmlElement> drawingElements =
          run.descendantElements.where((xml.XmlElement e) {
        return e.name.local == 'drawing';
      });
      if (drawingElements.isNotEmpty) {
        for (final xml.XmlElement draw in drawingElements) {
          final xml.XmlElement? imageBlip =
              _firstDescendant(draw, 'blip');
          if (imageBlip == null) continue;
          final String? imageRid = imageBlip.getAttribute('r:embed');
          if (imageRid == null) continue;
          final Relationship? imageRelation = relsById[imageRid];
          if (imageRelation == null) continue;
          final String imageName = imageRelation.target.split('/').last;

          String imagePath;
          if (kIsWeb) {
            imagePath = imageName;
          } else {
            imagePath = '$wordOutputDirectory/$imageName';
          }

          String imageType = '';
          int imgCX = 0;
          int imgCY = 0;
          final xml.XmlElement? imageInline = _firstDescendant(draw, 'inline');
          final xml.XmlElement? imageAnchor = _firstDescendant(draw, 'anchor');
          if (imageInline != null) {
            imageType = 'inline';
            final xml.XmlElement? extent = _firstDescendant(imageInline, 'extent');
            if (extent != null) {
              final String? cx = extent.getAttribute('cx');
              if (cx != null) imgCX = int.parse(cx);
              final String? cy = extent.getAttribute('cy');
              if (cy != null) imgCY = int.parse(cy);
            }
          } else if (imageAnchor != null) {
            imageType = 'anchor';
            final xml.XmlElement? extent = _firstDescendant(imageAnchor, 'extent');
            if (extent != null) {
              final String? cx = extent.getAttribute('cx');
              if (cx != null) imgCX = int.parse(cx);
              final String? cy = extent.getAttribute('cy');
              if (cy != null) imgCY = int.parse(cy);
            }
          }

          // Populate bytes at parse time so the renderer can use Image.memory.
          Uint8List? bytes;
          if (mediaByName != null) {
            bytes = mediaByName[imageName];
          } else if (webImages != null) {
            final WebImages? match = webImages
                .firstWhereOrNull((WebImages w) => w.name == imageName);
            if (match != null) bytes = match.bytes;
          }

          final MsImage img = MsImage(pSeqNo, imagePath, imageType, imgCX, imgCY,
              bytes: bytes);
          paragraph.images.add(img);
          paragraph.orderedContent.add(img);
          pSeqNo++;
        }
      }

      // Footnote / endnote references.
      final Iterable<xml.XmlElement> chkFootNotes =
          run.descendantElements.where((xml.XmlElement e) {
        return e.name.local == 'footnoteReference';
      });
      for (final xml.XmlElement footNt in chkFootNotes) {
        final String? footNtId = footNt.getAttribute('w:id');
        if (footNtId == null) continue;
        int noteId = 0;
        if (wordDocument.pages.isNotEmpty) {
          noteId = wordDocument.pages.last.footNotes.length +
              wordDocument.pages.last.endNotes.length;
        }
        final MsTextSpan span = MsTextSpan(pSeqNo, (noteId + 1).toString(),
            tStyle, formats, fontSize, textColor, highlightColor, fonts, shadingColor);
        paragraph.textSpans.add(span);
        paragraph.orderedContent.add(span);
        pSeqNo++;
        final Map<String, String> footNoteDetails = {
          'id': footNtId,
          'refNo': (noteId + 1).toString(),
          'style': tStyle,
        };
        if (pages.isEmpty) {
          pages.add(WordPage(pages.length + 1));
        }
        pages.last.footNotes.add(footNoteDetails);
      }

      final Iterable<xml.XmlElement> chkEndNotes =
          run.descendantElements.where((xml.XmlElement e) {
        return e.name.local == 'endnoteReference';
      });
      for (final xml.XmlElement endNt in chkEndNotes) {
        final String? endNtId = endNt.getAttribute('w:id');
        if (endNtId == null) continue;
        final int endNoteNo =
            wordDocument.pages.last.endNotes.length +
                wordDocument.pages.last.footNotes.length +
                1;
        final MsTextSpan span = MsTextSpan(pSeqNo, endNoteNo.toString(),
            tStyle, formats, fontSize, textColor, highlightColor, fonts, shadingColor);
        paragraph.textSpans.add(span);
        paragraph.orderedContent.add(span);
        pSeqNo++;
        final Map<String, String> endNoteDetails = {
          'id': endNtId,
          'refNo': endNoteNo.toString(),
          'style': tStyle,
        };
        if (pages.isEmpty) {
          pages.add(WordPage(pages.length + 1));
        }
        pages.last.endNotes.add(endNoteDetails);
      }
    }

    // Page break?
    bool newPage = false;
    if (pStyle.isNotEmpty) {
      final Styles? style = stylesById[pStyle];
      if (style != null && style.pageBreakBefore == true) {
        newPage = true;
      }
    }
    if (newPage || pages.isEmpty) {
      pages.add(WordPage(pages.length + 1));
    }
    pages.last.components.add(paragraph);
    // Keep wordDocument.pages in sync (it's the same list reference, but be
    // defensive in case the caller handed us a fresh list).
    wordDocument.pages = pages;
  }

  /// Process a `<w:tbl>` table element. Single-pass walk over the table's
  /// properties and rows. Synchronous — no `compute()`.
  MsTable _processWordTable(xml.XmlElement tableElement) {
    String tblStyle = '';
    String rightFromText = '';
    String bottomFromText = '';
    String vertAnchor = '';
    String tblpY = '';
    String tblWidth = '';
    String tblWType = '';
    String tblLook = '';
    int seqNo = 0;

    final xml.XmlElement? tblPr = _firstChild(tableElement, 'tblPr');
    if (tblPr != null) {
      for (final xml.XmlElement child in tblPr.childElements) {
        switch (child.name.local) {
          case 'tblStyle':
            final String? v = child.getAttribute('w:val');
            if (v != null) tblStyle = v;
            break;
          case 'tblpPr':
            final String? rft = child.getAttribute('w:rightFromText');
            if (rft != null) rightFromText = rft;
            final String? bft = child.getAttribute('w:bottomFromText');
            if (bft != null) bottomFromText = bft;
            final String? va = child.getAttribute('w:vertAnchor');
            if (va != null) vertAnchor = va;
            final String? y = child.getAttribute('w:tblpY');
            if (y != null) tblpY = y;
            break;
          case 'tblW':
            final String? w = child.getAttribute('w:w');
            if (w != null) tblWidth = w;
            final String? t = child.getAttribute('w:type');
            if (t != null) tblWType = t;
            break;
          case 'tblLook':
            final String? l = child.getAttribute('w:val');
            if (l != null) tblLook = l;
            break;
          default:
            break;
        }
      }
    }

    final MsTable table = MsTable(seqNo, tblStyle, rightFromText,
        bottomFromText, vertAnchor, tblpY, tblWidth, tblWType, tblLook);
    seqNo++;

    // Walk <w:tr> rows. Use direct children of tbl to avoid picking up
    // nested-table rows.
    for (final xml.XmlElement row in tableElement.childElements) {
      if (row.name.local != 'tr') continue;
      bool isFirstRow = false;
      bool isLastRow = false;
      bool isFirstCol = false;
      bool isLastCol = false;

      final xml.XmlElement? trPr = _firstChild(row, 'trPr');
      if (trPr != null) {
        final xml.XmlElement? cnf = _firstChild(trPr, 'cnfStyle');
        if (cnf != null) {
          final String? cnfStyleVal = cnf.getAttribute('w:val');
          if (cnfStyleVal != null && cnfStyleVal.length >= 4) {
            isFirstRow = cnfStyleVal[0] == '1';
            isLastRow = cnfStyleVal[1] == '1';
            isFirstCol = cnfStyleVal[2] == '1';
            isLastCol = cnfStyleVal[3] == '1';
          }
        }
      }

      final MsTableRow tableRow =
          MsTableRow(isFirstRow, isLastRow, isFirstCol, isLastCol);

      int? gridSpan;
      // gridSpan can appear in <w:trPr> or per-cell <w:tcPr>. The original
      // code looked at row-level; we keep the same behaviour.
      if (trPr != null) {
        final xml.XmlElement? gs = _firstChild(trPr, 'gridSpan');
        if (gs != null) {
          final String? v = gs.getAttribute('w:val');
          if (v != null) gridSpan = int.parse(v);
        }
      }
      tableRow.gridSpan = gridSpan;

      final List<xml.XmlElement> cells = row.childElements
          .where((xml.XmlElement e) => e.name.local == 'tc')
          .toList();
      if (table.colNums < cells.length) {
        table.colNums = cells.length;
      }

      for (final xml.XmlElement cell in cells) {
        int cellWidth = 0;
        final xml.XmlElement? tcPr = _firstChild(cell, 'tcPr');
        if (tcPr != null) {
          final xml.XmlElement? tcW = _firstChild(tcPr, 'tcW');
          if (tcW != null) {
            final String? w = tcW.getAttribute('w:w');
            if (w != null) cellWidth = int.parse(w);
          }
        }
        // Concatenate all <w:t> descendants of the cell.
        final StringBuffer colText = StringBuffer();
        for (final xml.XmlElement t in cell.descendantElements) {
          if (t.name.local == 't') {
            colText.write(t.innerText);
          }
        }
        tableRow.cells.add(MsTableCell(colText.toString(), cellWidth));
      }
      table.rows.add(tableRow);
    }
    return table;
  }

  /// Public accessor for the (now synchronous) table processor, kept for
  /// backwards compatibility with old call sites.
  MsTable processWordTable(ProcessWordTableParams params) =>
      _processWordTable(params.tableElement);

  /// Build a flat list of renderable items (one per component / footnote /
  /// endnote across all pages). Each item is a [WordRenderItem] record.
  ///
  /// The renderer then turns each item into a widget lazily inside a
  /// `ListView.builder`'s `itemBuilder`, so only visible items are built.
  List<WordRenderItem> buildRenderItems(Document wordDocument) {
    final List<WordRenderItem> items = <WordRenderItem>[];
    for (int p = 0; p < wordDocument.pages.length; p++) {
      final WordPage page = wordDocument.pages[p];
      if (p > 0) {
        items.add(WordRenderItem.pageBreak(p));
      }
      for (int c = 0; c < page.components.length; c++) {
        items.add(WordRenderItem.component(p, c, page.components[c]));
      }
      for (final Map<String, String> footNt in page.footNotes) {
        items.add(WordRenderItem.footnote(p, footNt));
      }
      for (final Map<String, String> endNt in page.endNotes) {
        items.add(WordRenderItem.endnote(p, endNt));
      }
    }
    return items;
  }

  /// Build the widget for one [WordRenderItem]. Called lazily from the
  /// `ListView.builder`'s `itemBuilder`.
  Widget buildItemWidget(
    WordRenderItem item,
    Document wordDocument,
    Map<String, Styles> stylesById,
    List<FootEndNote> footNotes,
    List<FootEndNote> endNotes,
    List<WebImages> webImages,
  ) {
    switch (item.kind) {
      case WordRenderItemKind.pageBreak:
        final double h = wordDocument.pageSize.height > 0
            ? wordDocument.pageSize.height
            : 0.0;
        return SizedBox(height: h);
      case WordRenderItemKind.footnote:
        final Map<String, String> fn = item.footNote!;
        final FootEndNote? note = footNotes.firstWhereOrNull(
            (FootEndNote n) => n.id == fn['id']);
        if (note == null) return const SizedBox.shrink();
        return _buildFootEndNote(note, stylesById, fn['refNo'] ?? '');
      case WordRenderItemKind.endnote:
        final Map<String, String> en = item.endNote!;
        final FootEndNote? note = endNotes.firstWhereOrNull(
            (FootEndNote n) => n.id == en['id']);
        if (note == null) return const SizedBox.shrink();
        return _buildFootEndNote(note, stylesById, en['refNo'] ?? '');
      case WordRenderItemKind.component:
        final List<Widget> widgets = _getComponents(
          item.component!,
          stylesById,
          wordDocument,
          webImages,
        );
        if (widgets.isEmpty) return const SizedBox.shrink();
        if (widgets.length == 1) return widgets.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        );
    }
  }

  /// Process section details. Single-pass walk over `<w:pgSz>` and
  /// `<w:pgMar>` children.
  void _processSectionDetails(
      xml.XmlElement sectionElement, Document wordDocument) {
    final xml.XmlElement? pgSz = _firstChild(sectionElement, 'pgSz');
    if (pgSz != null) {
      double tmpWidth = 0;
      double tmpHeight = 0;
      final String? w = pgSz.getAttribute('w:w');
      if (w != null) tmpWidth = (int.parse(w) / 1440) * 38;
      final String? h = pgSz.getAttribute('w:h');
      if (h != null) tmpHeight = (int.parse(h) / 1440) * 38;
      wordDocument.pageSize = Size(tmpWidth, tmpHeight);
    }
    final xml.XmlElement? pgMar = _firstChild(sectionElement, 'pgMar');
    if (pgMar != null) {
      final Map<String, double> tempMar = {};
      final String? tMar = pgMar.getAttribute('w:top');
      if (tMar != null) tempMar['topMar'] = (int.parse(tMar) / 1440) * 38;
      final String? bMar = pgMar.getAttribute('w:bottom');
      if (bMar != null) tempMar['bottomMar'] = (int.parse(bMar) / 1440) * 38;
      final String? rMar = pgMar.getAttribute('w:right');
      if (rMar != null) tempMar['rightMar'] = (int.parse(rMar) / 1440) * 38;
      final String? lMar = pgMar.getAttribute('w:left');
      if (lMar != null) tempMar['leftMar'] = (int.parse(lMar) / 1440) * 38;
      final String? hMar = pgMar.getAttribute('w:header');
      if (hMar != null) tempMar['headerMar'] = (int.parse(hMar) / 1440) * 38;
      final String? fMar = pgMar.getAttribute('w:footer');
      if (fMar != null) tempMar['footerMar'] = (int.parse(fMar) / 1440) * 38;
      final String? gMar = pgMar.getAttribute('w:gutter');
      if (gMar != null) tempMar['w:gutter'] = (int.parse(gMar) / 1440) * 38;
      wordDocument.pageMargin = tempMar;
    }
  }

  /// Public wrapper retained for backwards compatibility.
  void processSectionDetails(xml.XmlElement sectionElement, Document wordDocument) =>
      _processSectionDetails(sectionElement, wordDocument);

  /// Build a text span from an [MsTextSpan]. O(1) style lookup via
  /// [stylesById] (falls back to linear scan if a list is passed).
  static InlineSpan getTextSpan(MsTextSpan textSpan, dynamic stylesList) {
    final Map<String, Styles>? stylesById =
        stylesList is Map<String, Styles> ? stylesList : null;
    TextStyle textStyle = const TextStyle(inherit: false);
    String tempSpanText = textSpan.text;

    if (textSpan.fontSize != 0) {
      textStyle = textStyle.copyWith(fontSize: textSpan.fontSize.toDouble() / 2);
    }
    if (textSpan.formats.contains('italic')) {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
    }
    if (textSpan.formats.contains('bold')) {
      textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    }
    if (textSpan.formats.contains('single-underline')) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }
    if (textSpan.formats.contains('double-underline')) {
      textStyle = textStyle.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.double);
    }
    if (textSpan.formats.contains('strike')) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (textSpan.textColor.isNotEmpty && textSpan.textColor != 'auto') {
      final Color selectedColor =
          Color(int.parse('FF${textSpan.textColor}', radix: 16));
      textStyle = textStyle.copyWith(color: selectedColor);
    }
    if (textSpan.fonts.isNotEmpty) {
      textStyle = textStyle.copyWith(fontFamily: textSpan.fonts['ascii']);
    }
    if (textSpan.highlightColor.isNotEmpty) {
      textStyle =
          textStyle.copyWith(backgroundColor: getColorFromName(textSpan.highlightColor));
    }
    if (textSpan.shadingColor.isNotEmpty) {
      final Color shadingColor =
          Color(int.parse('FF${textSpan.shadingColor}', radix: 16));
      textStyle = textStyle.copyWith(backgroundColor: shadingColor);
    }

    if (textSpan.style.isNotEmpty) {
      final Styles? textStyles = stylesById != null
          ? stylesById[textSpan.style]
          : (stylesList as List<Styles>).firstWhereOrNull(
              (Styles style) => style.styleId == textSpan.style);
      if (textStyles != null) {
        if (textStyles.fontSize != 0) {
          textStyle =
              textStyle.copyWith(fontSize: textStyles.fontSize.toDouble() / 2);
        }
        if (textStyles.formats.contains('italic')) {
          textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
        }
        if (textStyles.formats.contains('bold')) {
          textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
        }
        if (textStyles.formats.contains('single-underline')) {
          textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
        }
        if (textStyles.formats.contains('double-underline')) {
          textStyle = textStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.double);
        }
        if (textStyles.formats.contains('strike')) {
          textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
        }
        if (textStyles.formats.contains('subscript')) {
          textSpan.formats.add('subscript');
        }
        if (textStyles.formats.contains('superscript')) {
          textSpan.formats.add('superscript');
        }
        if (textStyles.textColor != null && textStyles.textColor != 'auto') {
          final Color selectedColor =
              Color(int.parse('FF${textStyles.textColor!}', radix: 16));
          textStyle = textStyle.copyWith(color: selectedColor);
        } else {
          textStyle = textStyle.copyWith(color: Colors.black);
        }
        if (textStyles.fonts.isNotEmpty) {
          textStyle = textStyle.copyWith(fontFamily: textStyles.fonts['ascii']);
        }
      }
    }
    if (textSpan.formats.contains('subscript') ||
        textSpan.formats.contains('superscript')) {
      final double fontSize = textStyle.fontSize ?? 22;
      textStyle =
          textStyle.copyWith(fontSize: fontSize / 3).copyWith(color: Colors.grey);
      if (textSpan.formats.contains('subscript')) {
        return WidgetSpan(
          child: Transform.translate(
            offset: const Offset(0.0, 1.0),
            child: Text(tempSpanText, style: textStyle),
          ),
        );
      } else {
        return WidgetSpan(
          child: Transform.translate(
            offset: const Offset(0.0, -3.0),
            child: Text(tempSpanText, style: textStyle),
          ),
        );
      }
    } else {
      return TextSpan(text: tempSpanText, style: textStyle);
    }
  }

  /// Build a RichText widget for a paragraph. Uses [EdgeInsets] for indent
  /// instead of fake space characters. O(1) style lookup via [stylesById].
  static List<Widget> getRichText(
    Paragraph paragraph,
    List<InlineSpan> paragraphWidget,
    dynamic stylesList,
    Document wordDocument,
  ) {
    final Map<String, Styles>? stylesById =
        stylesList is Map<String, Styles> ? stylesList : null;
    TextStyle textStyle = const TextStyle();
    String jc = '';
    double firstLineIndentPx = 0;
    double leftIndentPx = 0;
    List<Widget> pageWidgets = [];
    int spaceBefore = 0;
    int spaceAfter = 0;
    Map<String, String> paraBorder = {};

    if (paragraph.style.isNotEmpty) {
      final Styles? paraStyles = stylesById != null
          ? stylesById[paragraph.style]
          : (stylesList as List<Styles>).firstWhereOrNull(
              (Styles style) => style.styleId == paragraph.style);
      if (paraStyles != null) {
        if (paraStyles.fontSize != 0) {
          textStyle =
              textStyle.copyWith(fontSize: paraStyles.fontSize.toDouble() / 2);
        }
        if (paraStyles.formats.contains('italic')) {
          textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
        }
        if (paraStyles.formats.contains('bold')) {
          textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
        }
        if (paraStyles.formats.contains('single-underline')) {
          textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
        }
        if (paraStyles.formats.contains('double-underline')) {
          textStyle = textStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.double);
        }
        if (paraStyles.formats.contains('strike')) {
          textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
        }
        if (paraStyles.formats.contains('subscript')) {
          textStyle =
              textStyle.copyWith(fontFeatures: const [FontFeature.subscripts()]);
        }
        if (paraStyles.textColor != null && paraStyles.textColor != 'auto') {
          final Color selectedColor =
              Color(int.parse('FF${paraStyles.textColor!}', radix: 16));
          textStyle = textStyle.copyWith(color: selectedColor);
        } else {
          textStyle = textStyle.copyWith(color: Colors.black);
        }
        if (paraStyles.fonts.isNotEmpty) {
          textStyle = textStyle.copyWith(fontFamily: paraStyles.fonts['ascii']);
        }
        if (paraStyles.jc != null && paraStyles.jc!.isNotEmpty) {
          jc = paraStyles.jc!;
        }

        // Indent: convert twips to pixels using the document's 1440→38
        // scale factor (same as page margins). Use EdgeInsets downstream.
        if (paraStyles.firstLineInd != 0) {
          firstLineIndentPx =
              (paraStyles.firstLineInd / 1440) * 38;
        }
        if (paraStyles.leftInd != 0) {
          leftIndentPx = (paraStyles.leftInd / 1440) * 38;
        }
        if (paraStyles.spacingBefore != 0) {
          spaceBefore = paraStyles.spacingBefore;
        }
        if (paraStyles.spacingAfter != 0) {
          spaceAfter = paraStyles.spacingAfter;
        }
        if (paraStyles.styleId == 'ListParagraph') {
          // Bullet glyph via prefix span instead of padding so it stays
          // glued to the first line.
          paragraphWidget.insert(
              0, const TextSpan(text: '\u2022 '));
        }
        if (paraStyles.paraGraphBorder.isNotEmpty) {
          paraBorder = paraStyles.paraGraphBorder;
        }
        if (paraStyles.jc != null && paraStyles.jc!.isNotEmpty) {
          jc = paraStyles.jc!;
        }
      }
    } else {
      textStyle = textStyle.copyWith(color: Colors.black);
    }
    if (paragraph.style.isEmpty) {
      if (wordDocument.defaultFontSize != 0) {
        textStyle =
            textStyle.copyWith(fontSize: wordDocument.defaultFontSize / 2);
      }
    }
    if (paragraph.shadingColor != null && paragraph.shadingColor != 'auto') {
      final Color paraBgColor =
          Color(int.parse('FF${paragraph.shadingColor!}', radix: 16));
      textStyle = textStyle.copyWith(backgroundColor: paraBgColor);
    }
    if (paragraph.formats != null && paragraph.formats!.isNotEmpty) {
      if (paragraph.formats!['jc'] != null) {
        jc = paragraph.formats!['jc']!;
      }
    }

    final RichText richText = RichText(
      softWrap: true,
      text: TextSpan(text: '', style: textStyle, children: paragraphWidget),
      textAlign: jc == 'right'
          ? TextAlign.end
          : jc == 'center'
              ? TextAlign.center
              : TextAlign.start,
    );

    if (spaceBefore != 0) {
      pageWidgets.add(SizedBox(height: spaceBefore.toDouble() / 10));
    }

    // Apply indent via Padding instead of leading space characters.
    Widget alignmentWidget = Padding(
      padding: EdgeInsets.only(
        left: leftIndentPx + firstLineIndentPx,
      ),
      child: richText,
    );
    if (jc == 'center') {
      alignmentWidget = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [richText],
      );
    } else if (jc == 'right') {
      alignmentWidget = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Expanded(child: richText)],
      );
    }
    if (paraBorder.isNotEmpty) {
      pageWidgets.add(borderContainer(paraBorder, alignmentWidget));
    } else {
      pageWidgets.add(alignmentWidget);
    }
    if (spaceAfter != 0) {
      pageWidgets.add(SizedBox(height: spaceAfter.toDouble() / 10));
    }
    return pageWidgets;
  }

  /// Wrap [child] in a border Container per [borderDetails].
  static Container borderContainer(Map<String, String> borderDetails, Widget child) {
    BorderSide topBorder = const BorderSide(width: 0);
    BorderSide leftBorder = const BorderSide(width: 0);
    BorderSide bottomBorder = const BorderSide(width: 0);
    BorderSide rightBorder = const BorderSide(width: 0);
    if (borderDetails.isNotEmpty) {
      if (borderDetails['top-val'] != null) {
        topBorder = topBorder.copyWith(style: BorderStyle.solid);
      }
      if (borderDetails['top-sz'] != null) {
        topBorder = topBorder.copyWith(
            width: double.parse(borderDetails['top-sz'].toString()) / 2);
      }
      if (borderDetails['top-color'] != null &&
          borderDetails['top-color'] != 'auto') {
        topBorder = topBorder.copyWith(
            color: Color(int.parse('FF${borderDetails['top-color']}', radix: 16)));
      }

      if (borderDetails['left-val'] != null) {
        leftBorder = leftBorder.copyWith(style: BorderStyle.solid);
      }
      if (borderDetails['left-sz'] != null) {
        leftBorder = leftBorder.copyWith(
            width: double.parse(borderDetails['left-sz'].toString()) / 2);
      }
      if (borderDetails['left-color'] != null) {
        leftBorder = leftBorder.copyWith(
            color: Color(int.parse('FF${borderDetails['left-color']}', radix: 16)));
      }

      if (borderDetails['bottom-val'] != null) {
        bottomBorder = bottomBorder.copyWith(style: BorderStyle.solid);
      }
      if (borderDetails['bottom-sz'] != null) {
        bottomBorder = bottomBorder.copyWith(
            width: double.parse(borderDetails['bottom-sz'].toString()) / 2);
      }
      if (borderDetails['bottom-color'] != null &&
          borderDetails['bottom-color'] != 'auto') {
        bottomBorder = bottomBorder.copyWith(
            color: Color(int.parse('FF${borderDetails['bottom-color']}', radix: 16)));
      }

      if (borderDetails['right-val'] != null) {
        rightBorder = rightBorder.copyWith(style: BorderStyle.solid);
      }
      if (borderDetails['right-sz'] != null) {
        rightBorder = rightBorder.copyWith(
            width: double.parse(borderDetails['right-sz'].toString()) / 2);
      }
      if (borderDetails['right-color'] != null &&
          borderDetails['right-color'] != 'auto') {
        rightBorder = rightBorder.copyWith(
            color: Color(int.parse('FF${borderDetails['right-color']}', radix: 16)));
      }
    }
    return Container(
      decoration: BoxDecoration(
          border: Border(
        top: topBorder.width != 0 ? topBorder : BorderSide.none,
        right: rightBorder.width != 0 ? rightBorder : BorderSide.none,
        bottom: bottomBorder.width != 0 ? bottomBorder : BorderSide.none,
        left: leftBorder.width != 0 ? leftBorder : BorderSide.none,
      )),
      child: child,
    );
  }

  /// Get a color from a name. Limited palette — kept for compatibility.
  static Color getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  /// Build a native Flutter [Table] widget for an [MsTable]. Replaces the
  /// old HTML-string + HtmlWidget path which had three problems:
  ///  1. O(n²) string concatenation in the cell loop.
  ///  2. A second parse pass through the HTML string.
  ///  3. No virtualization within the table.
  static Widget _buildNativeTable(
      MsTable msTable, Map<String, Styles> stylesById) {
    // Resolve table-level border from the table style (if any).
    BorderSide borderSide(String? sz, String? color, String? val) {
      if (val == null || val == 'nil') return BorderSide.none;
      double width = 0.5;
      if (sz != null) {
        width = double.parse(sz) / 8; // eighths of a point → px approx
      }
      Color c = Colors.black;
      if (color != null && color != 'auto') {
        c = Color(int.parse('FF$color', radix: 16));
      }
      return BorderSide(width: width, color: c, style: BorderStyle.solid);
    }

    BorderSide? topBorder;
    BorderSide? leftBorder;
    BorderSide? bottomBorder;
    BorderSide? rightBorder;

    if (msTable.tblStyle.isNotEmpty) {
      final Styles? tableStyles = stylesById[msTable.tblStyle];
      if (tableStyles != null && tableStyles.tableBorder.isNotEmpty) {
        final Map<String, String> b = tableStyles.tableBorder;
        topBorder = borderSide(b['top-sz'], b['top-color'], b['top-va']);
        leftBorder = borderSide(b['left-sz'], b['left-color'], b['left-va']);
        bottomBorder =
            borderSide(b['bottom-sz'], b['bottom-color'], b['bottom-va']);
        rightBorder =
            borderSide(b['right-sz'], b['right-color'], b['right-va']);
      }
    }

    // Resolve per-row / per-cell styling from the table style's rowColStyles.
    RowColStyles? firstRowStyle;
    RowColStyles? lastRowStyle;
    if (msTable.tblStyle.isNotEmpty) {
      final Styles? tableStyles = stylesById[msTable.tblStyle];
      if (tableStyles != null) {
        for (final RowColStyles r in tableStyles.rowColStyles) {
          if (r.applicableTo == 'firstRow') firstRowStyle = r;
          if (r.applicableTo == 'lastRow') lastRowStyle = r;
        }
      }
    }

    final List<TableRow> rows = msTable.rows.map((MsTableRow row) {
      BoxDecoration? cellDecoration;
      TextStyle? cellTextStyle;

      RowColStyles? applicableStyle;
      if (row.isFirstRow && firstRowStyle != null) {
        applicableStyle = firstRowStyle;
      } else if (row.isLastRow && lastRowStyle != null) {
        applicableStyle = lastRowStyle;
      }
      if (applicableStyle != null) {
        if (applicableStyle.shadingColor != null) {
          cellDecoration = BoxDecoration(
            color: Color(
                int.parse('FF${applicableStyle.shadingColor}', radix: 16)),
          );
        }
        if (applicableStyle.textColor != null) {
          cellTextStyle = TextStyle(
            color: Color(int.parse('FF${applicableStyle.textColor}', radix: 16)),
            fontWeight: applicableStyle.formats.contains('bold')
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: applicableStyle.fontSize != 0
                ? applicableStyle.fontSize.toDouble() / 2
                : null,
          );
        }
      }

      final List<Widget> cells = row.cells.map((MsTableCell cell) {
        return TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            decoration: cellDecoration,
            padding: const EdgeInsets.all(5),
            child: Text(
              cell.cellText,
              style: cellTextStyle ?? const TextStyle(),
            ),
          ),
        );
      }).toList();

      return TableRow(children: cells);
    }).toList();

    return Table(
      defaultColumnWidth: const FlexColumnWidth(),
      border: TableBorder(
        top: topBorder ?? BorderSide.none,
        left: leftBorder ?? BorderSide.none,
        bottom: bottomBorder ?? BorderSide.none,
        right: rightBorder ?? BorderSide.none,
        horizontalInside: BorderSide(color: Colors.grey.shade400, width: 0.5),
        verticalInside: BorderSide(color: Colors.grey.shade400, width: 0.5),
      ),
      children: rows,
    );
  }

  /// Build a footnote / endnote RichText widget.
  RichText _buildFootEndNote(
      FootEndNote footEndNote, Map<String, Styles> stylesById, String refNo) {
    TextStyle textStyle = const TextStyle(inherit: false);
    String tempSpanText = '$refNo ${footEndNote.text}';
    bool superScript = false;
    bool subScript = false;
    if (footEndNote.pStyle.isNotEmpty) {
      final Styles? textStyles = stylesById[footEndNote.pStyle];
      if (textStyles != null) {
        if (textStyles.fontSize != 0) {
          textStyle =
              textStyle.copyWith(fontSize: textStyles.fontSize.toDouble() / 2);
        }
        if (textStyles.formats.contains('italic')) {
          textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
        }
        if (textStyles.formats.contains('bold')) {
          textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
        }
        if (textStyles.formats.contains('single-underline')) {
          textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
        }
        if (textStyles.formats.contains('double-underline')) {
          textStyle = textStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.double);
        }
        if (textStyles.formats.contains('strike')) {
          textStyle =
              textStyle.copyWith(decoration: TextDecoration.lineThrough);
        }
        if (textStyles.formats.contains('subscript')) {
          subScript = true;
        }
        if (textStyles.formats.contains('superscript')) {
          superScript = true;
        }
        if (textStyles.textColor != null && textStyles.textColor != 'auto') {
          final Color selectedColor =
              Color(int.parse('FF${textStyles.textColor!}', radix: 16));
          textStyle = textStyle.copyWith(color: selectedColor);
        } else {
          textStyle = textStyle.copyWith(color: Colors.black);
        }
        if (textStyles.fonts.isNotEmpty) {
          textStyle = textStyle.copyWith(fontFamily: textStyles.fonts['ascii']);
        }
      }
    }
    if (subScript || superScript) {
      final double fontSize = textStyle.fontSize ?? 22;
      textStyle =
          textStyle.copyWith(fontSize: fontSize / 3).copyWith(color: Colors.grey);
      if (subScript) {
        return RichText(
            text: WidgetSpan(
          child: Transform.translate(
            offset: const Offset(0.0, 1.0),
            child: Text(tempSpanText, style: textStyle),
          ),
        ));
      } else {
        return RichText(
            text: WidgetSpan(
          child: Transform.translate(
            offset: const Offset(0.0, -3.0),
            child: Text(tempSpanText, style: textStyle),
          ),
        ));
      }
    } else {
      return RichText(text: TextSpan(text: tempSpanText, style: textStyle));
    }
  }

  /// Public wrapper for backwards compat.
  RichText getFootEndNote(
          FootEndNote footEndNote, List<Styles> stylesList, String refNo) =>
      _buildFootEndNote(
          footEndNote,
          {for (final Styles s in stylesList) s.styleId: s},
          refNo);

  /// Build the widget list for a single component (paragraph or table).
  /// Synchronous, no `compute()`. Uses [Paragraph.orderedContent] for O(S+I)
  /// span/image merge instead of O((S+I)²) firstWhereOrNull scans.
  static List<Widget> _getComponents(
    dynamic component,
    Map<String, Styles> stylesById,
    Document wordDocument,
    List<WebImages> webImages,
  ) {
    final List<Widget> pageWidgets = <Widget>[];
    if (component.runtimeType.toString() == 'Paragraph') {
      final Paragraph paragraph = component as Paragraph;
      final List<InlineSpan> paragraphWidget = <InlineSpan>[];

      // Prefer the orderedContent list (O(S+I)). Fall back to the legacy
      // pSeqNo merge if the parser didn't populate it.
      if (paragraph.orderedContent.isNotEmpty) {
        for (final dynamic item in paragraph.orderedContent) {
          if (item is MsTextSpan) {
            paragraphWidget.add(getTextSpan(item, stylesById));
          } else if (item is MsImage) {
            final InlineSpan? span = _imageToSpan(item, webImages);
            if (span != null) paragraphWidget.add(span);
          }
        }
      } else {
        // Legacy merge: build a Map keyed by pSeqNo to avoid O(n²) scans.
        final Map<int, MsTextSpan> spanBySeq = {
          for (final MsTextSpan s in paragraph.textSpans) s.pSeqNo: s,
        };
        final Map<int, MsImage> imgBySeq = {
          for (final MsImage i in paragraph.images) i.pSeqNo: i,
        };
        final int maxSeq = paragraph.textSpans.length +
            paragraph.images.length;
        for (int k = 0; k < maxSeq; k++) {
          final MsTextSpan? ts = spanBySeq[k];
          final MsImage? im = imgBySeq[k];
          if (ts != null) {
            paragraphWidget.add(getTextSpan(ts, stylesById));
          }
          if (im != null) {
            final InlineSpan? span = _imageToSpan(im, webImages);
            if (span != null) paragraphWidget.add(span);
          }
        }
      }
      pageWidgets.addAll(
          getRichText(paragraph, paragraphWidget, stylesById, wordDocument));
    } else if (component.runtimeType.toString() == 'MsTable') {
      final MsTable msTable = component as MsTable;
      pageWidgets.add(_buildNativeTable(msTable, stylesById));
    }
    return pageWidgets;
  }

  /// Build an `InlineSpan` for an image. Uses `Image.memory(bytes)` when
  /// `MsImage.bytes` is populated (the new in-memory path); falls back to
  /// `Image.file(path)` only when running on non-web AND bytes is null.
  static InlineSpan? _imageToSpan(MsImage image, List<WebImages> webImages) {
    final double width = image.cx / 12700;
    final double height = image.cy / 12700;
    if (image.bytes != null) {
      return WidgetSpan(
        child: Image.memory(
          image.bytes!,
          width: width,
          height: height,
        ),
      );
    }
    if (kIsWeb) {
      final WebImages? webImage = webImages.firstWhereOrNull(
          (WebImages img) => img.name == image.imagePath);
      if (webImage == null) return null;
      return WidgetSpan(
        child: Image.memory(
          webImage.bytes,
          width: width,
          height: height,
        ),
      );
    }
    // Legacy on-disk fallback (only used if caller didn't populate bytes).
    // ignore: avoid_unused_import_parameters
    return WidgetSpan(
      child: Image.file(
        File(image.imagePath),
        width: width,
        height: height,
        errorBuilder: (_, Object __, StackTrace? ___) =>
            const SizedBox.shrink(),
      ),
    );
  }

  /// Public, backwards-compatible wrapper around the old `getComponents`
  /// signature. Internally dispatches to the new synchronous `_getComponents`.
  static List<Widget> getComponents(GetComponentsParams params) {
    final Map<String, Styles> stylesById = params.stylesList is Map<String, Styles>
        ? params.stylesList as Map<String, Styles>
        : {for (final Styles s in params.stylesList as List<Styles>) s.styleId: s};
    return _getComponents(
        params.component, stylesById, params.wordDocument, params.webImages);
  }

  /// Helper: first direct child of [parent] with the given local name, or
  /// null. Single-pass walk over `childElements`.
  static xml.XmlElement? _firstChild(
      xml.XmlElement parent, String localName) {
    for (final xml.XmlElement c in parent.childElements) {
      if (c.name.local == localName) return c;
    }
    return null;
  }

  /// Helper: first descendant of [parent] with the given local name, or null.
  static xml.XmlElement? _firstDescendant(
      xml.XmlElement parent, String localName) {
    for (final xml.XmlElement d in parent.descendantElements) {
      if (d.name.local == localName) return d;
    }
    return null;
  }

  /// Old async `displayWordFile` API, retained for backwards compat. Builds
  /// all widgets eagerly — prefer [buildRenderItems] + [buildItemWidget] for
  /// virtualized rendering.
  Future<List<Widget>> displayWordFile(
    String fileType,
    Document wordDocument,
    List<Styles> stylesList,
    List<FootEndNote> footNotes,
    List<FootEndNote> endNotes,
    List<WebImages> webImages, {
    Map<String, Styles>? stylesById,
  }) async {
    final Map<String, Styles> stylesMap = stylesById ??
        {for (final Styles s in stylesList) s.styleId: s};
    final List<Widget> tempList = <Widget>[];
    if (fileType != 'word') return tempList;

    for (int i = 0; i < wordDocument.pages.length; i++) {
      final List<Widget> pageWidgets = <Widget>[];
      for (int j = 0; j < wordDocument.pages[i].components.length; j++) {
        pageWidgets.addAll(_getComponents(
          wordDocument.pages[i].components[j],
          stylesMap,
          wordDocument,
          webImages,
        ));
      }
      if (wordDocument.pages[i].footNotes.isNotEmpty) {
        for (final Map<String, String> footNt in wordDocument.pages[i].footNotes) {
          final FootEndNote? chkFootNot = footNotes.firstWhereOrNull(
              (FootEndNote ftNt) => ftNt.id == footNt['id']);
          if (chkFootNot != null) {
            pageWidgets
                .add(_buildFootEndNote(chkFootNot, stylesMap, footNt['refNo']!));
          }
        }
      }
      if (wordDocument.pages[i].endNotes.isNotEmpty) {
        for (final Map<String, String> endNt in wordDocument.pages[i].endNotes) {
          final FootEndNote? chkEndNt = endNotes.firstWhereOrNull(
              (FootEndNote edNt) => edNt.id == endNt['id']);
          if (chkEndNt != null) {
            pageWidgets
                .add(_buildFootEndNote(chkEndNt, stylesMap, endNt['refNo']!));
          }
        }
      }
      tempList.add(Container(
        color: Colors.white,
        constraints: BoxConstraints(
            minHeight: wordDocument.pageSize.height,
            minWidth: wordDocument.pageSize.width),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.only(
              left: wordDocument.pageMargin['leftMar'] ?? 0,
              right: wordDocument.pageMargin['rightMar'] ?? 0,
              top: wordDocument.pageMargin['topMar'] ?? 0,
              bottom: wordDocument.pageMargin['bottomMar'] ?? 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pageWidgets,
          ),
        ),
      ));
    }
    return tempList;
  }
}

/// One renderable item in the flattened word document. Produced by
/// [WordProcessor.buildRenderItems] and consumed by
/// [WordProcessor.buildItemWidget] inside a `ListView.builder`.
class WordRenderItem {
  final WordRenderItemKind kind;
  final int pageIndex;
  final int? componentIndex;
  final dynamic component;
  final Map<String, String>? footNote;
  final Map<String, String>? endNote;

  const WordRenderItem._({
    required this.kind,
    required this.pageIndex,
    this.componentIndex,
    this.component,
    this.footNote,
    this.endNote,
  });

  factory WordRenderItem.component(int pageIndex, int componentIndex, dynamic component) =>
      WordRenderItem._(
        kind: WordRenderItemKind.component,
        pageIndex: pageIndex,
        componentIndex: componentIndex,
        component: component,
      );

  factory WordRenderItem.pageBreak(int pageIndex) => WordRenderItem._(
        kind: WordRenderItemKind.pageBreak,
        pageIndex: pageIndex,
      );

  factory WordRenderItem.footnote(int pageIndex, Map<String, String> footNote) =>
      WordRenderItem._(
        kind: WordRenderItemKind.footnote,
        pageIndex: pageIndex,
        footNote: footNote,
      );

  factory WordRenderItem.endnote(int pageIndex, Map<String, String> endNote) =>
      WordRenderItem._(
        kind: WordRenderItemKind.endnote,
        pageIndex: pageIndex,
        endNote: endNote,
      );
}

enum WordRenderItemKind { component, pageBreak, footnote, endnote }

/// To pass the parameters (legacy, retained for backwards compat).
class ProcessParagraphParams {
  xml.XmlElement paragraphElement;
  List<Relationship> relationShips;
  String wordOutputDirectory;
  List<Styles> stylesList;
  Document wordDocument;

  ProcessParagraphParams(this.paragraphElement, this.relationShips,
      this.wordOutputDirectory, this.stylesList, this.wordDocument);
}

/// To pass component parameters (legacy, retained for backwards compat).
class GetComponentsParams {
  dynamic component;
  // ignore: prefer_typing_uninitialized_parameters
  dynamic stylesList;
  List<Widget> pageWidgets;
  Document wordDocument;
  List<WebImages> webImages;

  GetComponentsParams(this.component, this.stylesList, this.pageWidgets,
      this.wordDocument, this.webImages);
}

/// To pass table parameters (legacy, retained for backwards compat).
class ProcessWordTableParams {
  xml.XmlElement tableElement;
  ProcessWordTableParams(this.tableElement);
}
