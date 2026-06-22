import 'package:flutter/material.dart';
import 'package:ps_books/helpers/utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'dart:convert';

/// A paragraph (or image) widget tagged with the chapter it belongs to.
class IndexedParagraph {
  final int chapterIndex;
  final Widget content;

  IndexedParagraph({required this.chapterIndex, required this.content});
}

/// A chapter entry for the top-level table of contents.
class ChapterEntry {
  final int id; // index of the section this chapter came from
  final String title;

  ChapterEntry({required this.id, required this.title});
}

/// Represents a binary resource (image) embedded in the FB2 document.
class FB2Binary {
  final String id;
  final String contentType;
  final String base64Data;

  FB2Binary({
    required this.id,
    required this.contentType,
    required this.base64Data,
  });
}

class FB2Reader extends StatefulWidget {
  FB2Reader({
    super.key,
    required this.filePath,
    this.onPositionChanged,
    this.initialPosition,
  });

  final String filePath;
  final void Function(int index, double progress)? onPositionChanged;
  final int? initialPosition;


  @override
  State<FB2Reader> createState() => FB2ReaderState();
}

class FB2ReaderState extends State<FB2Reader> {
  /// Structured chapter data — each Chapter holds indexed paragraphs.
  List<Chapter> chapters = [];

  /// Top-level list of chapter titles for the drawer navigation.
  List<ChapterEntry> chapterList = [];

  /// Flat list of widgets for the ScrollablePositionedList.
  List<Widget> renderable = [];

  /// Flat list of IndexedParagraphs mirroring [renderable] order,
  /// used to map a visible list index back to its chapter.
  List<IndexedParagraph> indexedItems = [];

  /// Binary image resources extracted from the document.
  List<FB2Binary> binaries = [];

  /// The chapter index of the currently visible paragraph.
  int currentChapterIndex = 0;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  double padding = 25.0;
  bool isDarkMode = true;

  // ---------------------------------------------------------------------------
  // Binary helpers
  // ---------------------------------------------------------------------------

  /// Extracts all binary elements from the FB2 document.
  void _collectBinaries(XmlDocument document) {
    final binaryElements = document.findAllElements('binary');
    for (var bin in binaryElements) {
      final id = bin.getAttribute('id') ?? '';
      final contentType = bin.getAttribute('content-type') ?? 'image/jpeg';
      final base64Data = bin.innerText.trim().replaceAll(RegExp(r'\s+'), '');
      if (id.isNotEmpty && base64Data.isNotEmpty) {
        binaries.add(FB2Binary(
          id: id,
          contentType: contentType,
          base64Data: base64Data,
        ));
      }
    }
  }

  /// Looks up a binary by its href (e.g. "#image1.png" -> "image1.png").
  FB2Binary? _findBinary(String href) {
    final id = href.startsWith('#') ? href.substring(1) : href;
    try {
      return binaries.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Element processing helpers
  // ---------------------------------------------------------------------------

  /// Processes an <epigraph> element and its sub-elements.
  Widget _processEpigraph(XmlElement epigraphEl) {
    final List<Widget> children = [];

    for (var child in epigraphEl.children) {
      if (child is! XmlElement) continue;

      switch (child.localName) {
        case 'p':
          final text = _extractLeafText(child);
          if (text.isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
          break;

        case 'poem':
          children.add(_processPoem(child));
          break;

        case 'text-author':
          final author = _extractLeafText(child);
          if (author.isNotEmpty) {
            children.add(
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    author,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            );
          }
          break;

        default:
          // Handle other potential elements inside epigraph if needed
          break;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  /// Processes a <poem> element.
  Widget _processPoem(XmlElement poemEl) {
    final List<Widget> stanzas = [];

    for (var child in poemEl.children) {
      if (child is! XmlElement) continue;

      if (child.localName == 'stanza') {
        final List<Widget> verses = [];
        for (var v in child.findAllElements('v')) {
          verses.add(
            Text(
              v.innerText.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        stanzas.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: verses,
            ),
          ),
        );
      }
    }

    return Column(
      children: stanzas,
    );
  }

  /// Recursively extracts title text from a title element's children.
  List<Widget> _processTitleElement(XmlElement titleEl) {
    final List<Widget> titleWidgets = [];

    for (var child in titleEl.children) {
      if (child is XmlElement) {
        if (child.localName == 'p') {
          final leafText = _extractLeafText(child);
          if (leafText.isNotEmpty) {
            titleWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
                  leafText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
        } else {
          titleWidgets.addAll(_processTitleElement(child));
        }
      } else if (child is XmlText) {
        final text = child.value.trim();
        if (text.isNotEmpty) {
          titleWidgets.add(
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      }
    }

    return titleWidgets;
  }

  /// Extracts the plain-text title string from a title element (for the drawer).
  String _extractTitleText(XmlElement titleEl) {
    return _extractLeafText(titleEl);
  }

  /// Recursively extracts concatenated text content from an element.
  String _extractLeafText(XmlElement element) {
    final buffer = StringBuffer();
    for (var child in element.children) {
      if (child is XmlText) {
        buffer.write(child.value);
      } else if (child is XmlElement) {
        buffer.write(_extractLeafText(child));
      }
    }
    return buffer.toString().trim();
  }

  /// Wraps paragraph text in a styled Text widget.
  Widget _buildParagraphWidget(String textContent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        textContent,
        textAlign: TextAlign.justify,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  /// Builds an Image widget from a matched binary entry.
  Widget _buildImageWidget(FB2Binary binary) {
    final bytes = base64Decode(binary.base64Data);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  void _parseFB2() async {
    final file = File(widget.filePath);
    final fileBytes = await file.readAsBytes();
    final xmlString = await UniversalBookDecoder.decodeBytesToUtf8(fileBytes);
    final document = XmlDocument.parse(xmlString);

    // Step 1: Collect all binary image resources.
    _collectBinaries(document);

    // Step 2: Process each section.
    final sections = document.findAllElements('section');
    int sectionIndex = 0;

    for (var section in sections) {
      final List<Widget> chapterTitleWidgets = [];
      final List<IndexedParagraph> chapterParagraphs = [];
      String chapterTitleText = '';

      // Loop over all direct children of the section.
      for (var child in section.children) {
        if (child is! XmlElement) continue;

        switch (child.localName) {
          case 'title':
            // Build the styled title widgets for rendering.
            chapterTitleWidgets.addAll(_processTitleElement(child));
            // Extract the plain-text title for the drawer.
            final titleStr = _extractTitleText(child);
            if (titleStr.isNotEmpty) {
              chapterTitleText = titleStr;
            }
            break;

          case 'p':
            final textContent = child.innerText.trim();
            if (textContent.isNotEmpty) {
              chapterParagraphs.add(IndexedParagraph(
                chapterIndex: sectionIndex,
                content: _buildParagraphWidget(textContent),
              ));
            }
            break;

          case 'epigraph':
            chapterParagraphs.add(IndexedParagraph(
              chapterIndex: sectionIndex,
              content: _processEpigraph(child),
            ));
            break;

          case 'image':
            final href = child.getAttribute('href',
                    namespace: 'http://www.w3.org/1999/xlink') ??
                child.getAttribute('xlink:href') ??
                child.getAttribute('href') ??
                '';
            if (href.isNotEmpty) {
              final binary = _findBinary(href);
              if (binary != null) {
                chapterParagraphs.add(IndexedParagraph(
                  chapterIndex: sectionIndex,
                  content: _buildImageWidget(binary),
                ));
              }
            }
            break;

          default:
            break;
        }
      }

      // Add to the top-level chapter list for the drawer.
      chapterList.add(ChapterEntry(
        id: sectionIndex,
        title: chapterTitleText.isNotEmpty
            ? chapterTitleText
            : 'Chapter ${sectionIndex + 1}',
      ));

      // Store structured chapter data.
      final chapter = Chapter(
        title: chapterTitleWidgets,
        content: chapterParagraphs,
      );
      chapters.add(chapter);

      sectionIndex++;
    }

    // Step 3: Flatten into renderable list and parallel indexed list.
    _flatten();
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Flatten structured data into flat lists for the scrollable list.
  // ---------------------------------------------------------------------------

  void _flatten() {
    renderable.clear();
    indexedItems.clear();

    for (var chapter in chapters) {
      // Add title widgets — tag them with the chapter's index (from the first
      // paragraph's chapterIndex, or -1 if chapter has no paragraphs).
      final chapterIdx =
          chapter.content.isNotEmpty ? chapter.content.first.chapterIndex : -1;

      for (var titleWidget in chapter.title) {
        renderable.add(titleWidget);
        indexedItems.add(IndexedParagraph(
          chapterIndex: chapterIdx,
          content: titleWidget,
        ));
      }

      // Add paragraph/image widgets.
      for (var paragraph in chapter.content) {
        renderable.add(paragraph.content);
        indexedItems.add(paragraph);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Scroll listener — tracks the topmost visible item and resolves its chapter.
  // ---------------------------------------------------------------------------

  void _onScrollChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the item closest to the top of the viewport.
    final topItem = positions.reduce((a, b) {
      // Among visible items pick the one whose leading edge is smallest
      // but still >= 0, or if all are partially scrolled pick the smallest.
      if (a.itemLeadingEdge.abs() < b.itemLeadingEdge.abs()) return a;
      return b;
    });

    final index = topItem.index;
    if (index < 0 || index >= indexedItems.length) return;

    final chapterIdx = indexedItems[index].chapterIndex;
    if (chapterIdx != currentChapterIndex) {
      setState(() {
        currentChapterIndex = chapterIdx;
      });
    }

    if (widget.onPositionChanged != null) {
      double progress = index / (indexedItems.length > 0 ? indexedItems.length : 1);
      widget.onPositionChanged!(index, progress);
    }
  }

  // ---------------------------------------------------------------------------
  // Scroll-to-chapter: called when the user taps a chapter in the drawer.
  // ---------------------------------------------------------------------------

  void _scrollToChapter(int chapterIndex) {
    // Find the first renderable item that belongs to this chapter.
    final targetIndex = indexedItems.indexWhere(
      (item) => item.chapterIndex == chapterIndex,
    );
    if (targetIndex != -1) {
      _itemScrollController.scrollTo(
        index: targetIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _parseFB2();
    _itemPositionsListener.itemPositions.addListener(_onScrollChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScrollChanged);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  List<ChapterEntry> get chapterEntries => chapterList;

  int get currentChapter => currentChapterIndex;

  bool get darkMode => isDarkMode;

  double get paddingValue => padding;

  void setDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void setPadding(double value) {
    setState(() {
      padding = value;
    });
  }

  void scrollToChapterById(int id) {
    _scrollToChapter(id);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;
    final readerTheme = isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1B1227),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1729)),
          )
        : ThemeData.light();

    return Theme(
      data: readerTheme,
      child: renderable.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : isDesktop ? Center(
              child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    initialScrollIndex: widget.initialPosition ?? 0,
                    itemCount: renderable.length,
                    padding:
                        EdgeInsets.symmetric(horizontal: padding, vertical: 25.0),
                    physics: const ClampingScrollPhysics(),
                    minCacheExtent: 1500,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      return renderable[index];
                    },
                  ),
              ),
            ) : ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          initialScrollIndex: widget.initialPosition ?? 0,
          itemCount: renderable.length,
          padding:
          EdgeInsets.symmetric(horizontal: padding, vertical: 25.0),
          physics: const ClampingScrollPhysics(),
          minCacheExtent: 1500,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            return renderable[index];
          },
        ),
    );
  }

}

/// A chapter's structured data — title widgets + indexed paragraphs.
class Chapter {
  final List<Widget> title;
  final List<IndexedParagraph> content;

  Chapter({required this.title, required this.content});
}
