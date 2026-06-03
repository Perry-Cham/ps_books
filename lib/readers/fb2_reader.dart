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
  State<FB2Reader> createState() => _FB2ReaderState();
}

class _FB2ReaderState extends State<FB2Reader> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDesktop = MediaQuery.of(context).size.width > 600;
    final readerTheme = isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1B1227),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1729)),
          )
        : ThemeData.light();

    return Theme(
      data: readerTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reader'),
          actions: [
            IconButton(
              onPressed: () => _showSettings(context),
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            )
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    'Chapters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chapterList.length,
                    itemBuilder: (context, index) {
                      final chapter = chapterList[index];
                      final isActive = chapter.id == currentChapterIndex;

                      return ListTile(
                        dense: true,
                        selected: isActive,
                        selectedTileColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        leading: isActive
                            ? Icon(Icons.menu_book,
                                color: theme.colorScheme.primary, size: 20)
                            : const Icon(Icons.circle, size: 6),
                        title: Text(
                          chapter.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          _scrollToChapter(chapter.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: renderable.isEmpty
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
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reader Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Light Theme'),
                      Switch(
                        value: !isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = !value;
                          });
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Horizontal Padding'),
                  Slider(
                    value: padding,
                    min: 0.0,
                    max: 50.0,
                    divisions: 10,
                    label: padding.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        padding = value;
                      });
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class Settings extends StatefulWidget {
  final int padding;

  Settings({super.key, required this.padding});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filled(onPressed: () {}, icon: Icon(Icons.add)),
                Text(widget.padding.toString()),
                IconButton.filled(
                  onPressed: () {},
                  icon: Icon(Icons.exposure_minus_1),
                ),
              ],
            ),
          ],
        ),
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
