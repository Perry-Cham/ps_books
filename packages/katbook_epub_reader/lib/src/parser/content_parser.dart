import 'package:epub_pro/epub_pro.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart';

import '../models/chapter_node.dart';
import '../models/paragraph_element.dart';
import 'html_parser.dart';

/// Result of content parsing.
class ParseResult {

  const ParseResult({
    required this.tableOfContents,
    required this.flatChapters,
    required this.paragraphs,
  });
  final List<ChapterNode> tableOfContents;
  final List<ChapterNode> flatChapters;
  final List<ParagraphElement> paragraphs;
}

/// Parses EPUB content following chapter hierarchy.
class EpubContentParser {

  EpubContentParser(this._book);
  final EpubBook _book;
  final List<ChapterNode> _tableOfContents = [];
  final List<ChapterNode> _flatChapters = [];
  final List<ParagraphElement> _paragraphs = [];
  
  // Cache parsed HTML files
  final Map<String, List<dom.Element>> _parsedFiles = {};

  /// Parse the entire EPUB content.
  ParseResult parse() {
    _parseHtmlFiles();
    _addFrontMatter(); // Add content before chapters
    _processChapters();
    
    debugPrint('📑 TOC: ${_tableOfContents.length} root chapters');
    debugPrint('📑 Flat: ${_flatChapters.length} total chapters');
    debugPrint('📄 Paragraphs: ${_paragraphs.length}');
    
    return ParseResult(
      tableOfContents: _tableOfContents,
      flatChapters: _flatChapters,
      paragraphs: _paragraphs,
    );
  }

  /// Add front matter content (before chapters: cover, dedication, etc.)
  void _addFrontMatter() {
    if (_book.chapters == null || _book.chapters!.isEmpty) return;
    
    // Get spine order if available
    final spine = _book.schema?.package?.spine?.items;
    final manifest = _book.schema?.package?.manifest?.items;
    
    if (spine == null || manifest == null || manifest.isEmpty) return;
    
    // Collect ALL files referenced by chapters (including nested)
    final chapterFiles = <String>{};
    void collectChapterFiles(List<EpubChapter> chapters) {
      for (final chapter in chapters) {
        final fileName = chapter.contentFileName;
        if (fileName != null) {
          chapterFiles.add(fileName);
          chapterFiles.add(fileName.split('/').last);
        }
        if (chapter.subChapters != null) {
          collectChapterFiles(chapter.subChapters!);
        }
      }
    }
    collectChapterFiles(_book.chapters!);
    
    // Add front matter (files in spine that are NOT used by any chapter)
    int paragraphIndex = 0;
    
    for (final spineItem in spine) {
      // Find manifest item
      EpubManifestItem? manifestItem;
      for (final m in manifest) {
        if (m.id == spineItem.idRef) {
          manifestItem = m;
          break;
        }
      }
      
      if (manifestItem == null) continue;
      
      final href = manifestItem.href;
      if (href == null) continue;
      
      final fileName = href.split('/').last;
      
      // Skip if this file is used by any chapter
      if (chapterFiles.contains(fileName) || chapterFiles.contains(href)) {
        continue;
      }
      
      // Find the content
      List<dom.Element>? elements;
      for (final entry in _parsedFiles.entries) {
        final entryName = entry.key.split('/').last;
        if (entryName == fileName || entry.key == href) {
          elements = entry.value;
          break;
        }
      }
      
      if (elements == null || elements.isEmpty) continue;
      
      debugPrint('📖 Adding front matter: $fileName (${elements.length} elements)');
      
      for (final element in elements) {
        _paragraphs.add(ParagraphElement(
          element: element,
          chapterIndex: 0,
          absoluteIndex: paragraphIndex,
          isChapterStart: paragraphIndex == 0,
          chapterTitle: paragraphIndex == 0 ? 'Couverture' : null,
        ));
        paragraphIndex++;
      }
    }
    
    // Add a front matter chapter if we found content
    if (paragraphIndex > 0) {
      const frontMatterNode = ChapterNode(
        title: 'Couverture',
        startIndex: 0,
        depth: 0,
      );
      _tableOfContents.insert(0, frontMatterNode);
      _flatChapters.insert(0, frontMatterNode);
    }
  }

  /// Pre-parse all HTML content files.
  void _parseHtmlFiles() {
    final htmlFiles = _book.content?.html;
    if (htmlFiles == null) return;

    for (final entry in htmlFiles.entries) {
      final fileName = entry.key;
      final content = entry.value.content;
      if (content != null) {
        _parsedFiles[fileName] = EpubHtmlParser.parseHtmlToElements(content);
      }
    }
    
    debugPrint('📄 Parsed ${_parsedFiles.length} HTML files');
  }

  /// Process chapters in TOC order.
  void _processChapters() {
    if (_book.chapters == null || _book.chapters!.isEmpty) {
      _processWithoutToc();
      return;
    }

    // Start chapter index after front matter (if any)
    int chapterIndex = _flatChapters.length;
    // Start paragraph index after front matter paragraphs (if any)
    int paragraphIndex = _paragraphs.length;

    final chapters = _book.chapters!;
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      // Determine the next sibling boundary so chapters know where to stop
      final nextChapter = i + 1 < chapters.length ? chapters[i + 1] : null;

      final result = _processChapter(
        chapter: chapter,
        depth: 0,
        chapterIndex: chapterIndex,
        paragraphIndex: paragraphIndex,
        nextBoundaryFile: nextChapter?.contentFileName,
        nextBoundaryAnchor: nextChapter?.anchor,
      );
      
      _tableOfContents.add(result.node);
      chapterIndex = result.nextChapterIndex;
      paragraphIndex = result.nextParagraphIndex;
    }
  }

  /// Fallback when no TOC is defined.
  void _processWithoutToc() {
    int index = 0;
    for (final entry in _parsedFiles.entries) {
      for (final element in entry.value) {
        _paragraphs.add(ParagraphElement(
          element: element,
          chapterIndex: 0,
          absoluteIndex: index,
          isChapterStart: index == 0,
          chapterTitle: index == 0 ? (_book.title ?? 'Content') : null,
        ));
        index++;
      }
    }
    
    if (_paragraphs.isNotEmpty) {
      final node = ChapterNode(
        title: _book.title ?? 'Content',
        startIndex: 0,
        depth: 0,
      );
      _tableOfContents.add(node);
      _flatChapters.add(node);
    }
  }

  /// Process a single chapter and its subchapters.
  ///
  /// [nextBoundaryFile] and [nextBoundaryAnchor] define where the next sibling
  /// (or parent's next sibling) starts, so this chapter knows where its content
  /// ends. This prevents content duplication when multiple TOC entries reference
  /// the same XHTML file.
  _ChapterResult _processChapter({
    required EpubChapter chapter,
    required int depth,
    required int chapterIndex,
    required int paragraphIndex,
    String? nextBoundaryFile,
    String? nextBoundaryAnchor,
  }) {
    final startIndex = paragraphIndex;
    final fileName = chapter.contentFileName;
    
    debugPrint('  ${"  " * depth}📖 ${chapter.title}');

    // Get elements for this chapter (respecting boundaries)
    final elements = _getElementsForChapter(
      chapter,
      nextBoundaryFile: nextBoundaryFile,
      nextBoundaryAnchor: nextBoundaryAnchor,
    );
    
    // Add paragraphs
    bool isFirst = true;
    for (final element in elements) {
      _paragraphs.add(ParagraphElement(
        element: element,
        chapterIndex: chapterIndex,
        absoluteIndex: paragraphIndex,
        isChapterStart: isFirst,
        chapterTitle: isFirst ? chapter.title : null,
      ));
      paragraphIndex++;
      isFirst = false;
    }

    // Process subchapters
    final childNodes = <ChapterNode>[];
    int nextChapterIdx = chapterIndex + 1;
    
    if (chapter.subChapters != null && chapter.subChapters!.isNotEmpty) {
      final subs = chapter.subChapters!;
      for (int i = 0; i < subs.length; i++) {
        final sub = subs[i];
        
        // Determine the next boundary for this sub-chapter
        String? childNextFile;
        String? childNextAnchor;
        
        if (i + 1 < subs.length) {
          // Next sibling exists
          childNextFile = subs[i + 1].contentFileName;
          childNextAnchor = subs[i + 1].anchor;
        } else {
          // Last child → propagate parent's boundary
          childNextFile = nextBoundaryFile;
          childNextAnchor = nextBoundaryAnchor;
        }
        
        final result = _processChapter(
          chapter: sub,
          depth: depth + 1,
          chapterIndex: nextChapterIdx,
          paragraphIndex: paragraphIndex,
          nextBoundaryFile: childNextFile,
          nextBoundaryAnchor: childNextAnchor,
        );
        childNodes.add(result.node);
        nextChapterIdx = result.nextChapterIndex;
        paragraphIndex = result.nextParagraphIndex;
      }
    }

    // Create node
    final node = ChapterNode(
      title: chapter.title ?? 'Sans titre',
      startIndex: startIndex,
      depth: depth,
      children: childNodes,
      contentFileName: fileName,
      anchor: chapter.anchor,
    );
    
    _flatChapters.add(node);

    return _ChapterResult(
      node: node,
      nextChapterIndex: nextChapterIdx,
      nextParagraphIndex: paragraphIndex,
    );
  }

  /// Get elements belonging to a specific chapter.
  ///
  /// Uses boundary information to determine exactly which elements belong to
  /// this chapter, preventing duplication when multiple TOC entries reference
  /// the same XHTML file (with or without anchors).
  ///
  /// - For chapters with subchapters: content ends where the first same-file
  ///   sub-chapter starts. If that sub-chapter has no anchor and the parent
  ///   has no anchor either, the parent gets no content (they start at the
  ///   same position).
  /// - For leaf chapters: content ends where [nextBoundaryFile]/[nextBoundaryAnchor]
  ///   starts (the next sibling or a propagated parent boundary).
  List<dom.Element> _getElementsForChapter(
    EpubChapter chapter, {
    String? nextBoundaryFile,
    String? nextBoundaryAnchor,
  }) {
    final fileName = chapter.contentFileName;
    if (fileName == null) return [];

    // Find matching file
    List<dom.Element>? allElements;
    for (final entry in _parsedFiles.entries) {
      if (_fileNamesMatch(entry.key, fileName)) {
        allElements = entry.value;
        break;
      }
    }
    
    if (allElements == null || allElements.isEmpty) return [];

    final anchor = chapter.anchor;
    final hasSubchapters = chapter.subChapters?.isNotEmpty ?? false;

    // Find start position (from anchor or beginning of file)
    int startIdx = 0;
    if (anchor != null) {
      for (int i = 0; i < allElements.length; i++) {
        if (EpubHtmlParser.elementContainsAnchor(allElements[i], anchor)) {
          startIdx = i;
          break;
        }
      }
    }

    // Find end position
    int endIdx = allElements.length;
    
    if (hasSubchapters) {
      // End at the first sub-chapter that's in the same file
      for (final sub in chapter.subChapters!) {
        final subAnchor = sub.anchor;
        final subFile = sub.contentFileName;
        
        if (_fileNamesMatch(fileName, subFile)) {
          if (subAnchor != null) {
            // Sub-chapter starts at an anchor → parent content ends there
            for (int i = startIdx; i < allElements.length; i++) {
              if (EpubHtmlParser.elementContainsAnchor(allElements[i], subAnchor)) {
                endIdx = i;
                break;
              }
            }
          } else {
            // Sub-chapter references the same file without anchor
            // → it starts at the same position, so parent has no own content
            endIdx = startIdx;
          }
          break;
        }
      }
    } else if (nextBoundaryFile != null &&
        _fileNamesMatch(fileName, nextBoundaryFile)) {
      // Leaf chapter: end at the next sibling's position in the same file
      if (nextBoundaryAnchor != null) {
        for (int i = startIdx + 1; i < endIdx; i++) {
          if (EpubHtmlParser.elementContainsAnchor(
              allElements[i], nextBoundaryAnchor)) {
            endIdx = i;
            break;
          }
        }
      }
      // If next boundary is in same file with no anchor, it would start at
      // the beginning of the file. Since current chapter already started at
      // or after that, keep endIdx as-is (unusual edge case).
    }

    // Return elements or empty if range is invalid
    if (startIdx >= endIdx) return [];
    return allElements.sublist(startIdx, endIdx);
  }

  /// Check if two file names refer to the same file.
  bool _fileNamesMatch(String? a, String? b) {
    if (a == null || b == null) return false;
    if (a == b) return true;
    
    // Compare just filenames
    final nameA = a.split('/').last;
    final nameB = b.split('/').last;
    return nameA == nameB;
  }
}

/// Internal result class for chapter processing.
class _ChapterResult {

  const _ChapterResult({
    required this.node,
    required this.nextChapterIndex,
    required this.nextParagraphIndex,
  });
  final ChapterNode node;
  final int nextChapterIndex;
  final int nextParagraphIndex;
}
