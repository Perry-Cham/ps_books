import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:microsoft_viewer/models/font_details.dart';

import '../models/styles.dart';
import 'package:xml/xml.dart' as xml;

/// Processor for handling tasks common to all document types.
///
/// Performance notes (see `microsoft_viewer_flutter_docx_performance_analysis.docx`):
/// * Removed `compute()` per `<w:style>` — styles are now parsed in a single
///   synchronous pass on the calling isolate. One `XmlDocument.parse` instead
///   of 42 isolate round-trips for the demo.docx.
/// * Replaced the repeated `findAllElements("w:…")` pattern with a single-pass
///   visitor that walks each style element's children once and dispatches on
///   `localName`.
/// * Implemented style inheritance via `w:basedOn` with memoization. Resolved
///   styles are exposed through [processStylesFile] in the
///   `resolvedStylesById` map that callers should use for O(1) lookup.
class CommonProcessor {
  /// Parse `word/styles.xml` into [stylesList] and build two lookup maps:
  /// * `stylesById` — raw styleId → Styles (direct definitions only)
  /// * `resolvedStylesById` — styleId → Styles with `w:basedOn` chain merged
  ///
  /// Also extracts `rPrDefault` / `pPrDefault` into [defaultValues].
  ///
  /// This function does NOT spawn any isolates. It is a single synchronous
  /// walk over the styles document.
  void processStylesFile(
    ArchiveFile stylesFile,
    List<Styles> stylesList,
    Map<String, String> defaultValues, {
    Map<String, Styles>? stylesById,
    Map<String, Styles>? resolvedStylesById,
  }) {
    stylesList.clear();
    final String fileContent = utf8.decode(stylesFile.content);
    final xml.XmlDocument stylesDoc = xml.XmlDocument.parse(fileContent);

    final Iterable<xml.XmlElement> stylesRoot =
        stylesDoc.findAllElements('w:styles');
    if (stylesRoot.isEmpty) return;

    final Iterable<xml.XmlElement> allStyles =
        stylesRoot.first.findAllElements('w:style');

    // Local maps — always built, even if the caller didn't pass any in.
    final Map<String, Styles> localById = stylesById ?? <String, Styles>{};
    localById.clear();

    // First pass: parse every <w:style> into a Styles object. The parser
    // records the basedOn id on the Styles.basedOnId field for the
    // inheritance pass below.
    for (final xml.XmlElement style in allStyles) {
      final Styles parsed = _parseStyleElement(style);
      stylesList.add(parsed);
      localById[parsed.styleId] = parsed;
    }

    // Inheritance pass: produce resolved styles by walking the basedOn chain
    // and merging each style with its parent via [Styles.merged]. Memoized so
    // each style is resolved exactly once, even with deep chains or cycles.
    final Map<String, Styles> localResolved =
        resolvedStylesById ?? <String, Styles>{};
    localResolved.clear();
    Styles resolve(String id, [Set<String>? visiting]) {
      if (localResolved.containsKey(id)) return localResolved[id]!;
      final Styles? current = localById[id];
      if (current == null) {
        final Styles stub = Styles('', '', id);
        localResolved[id] = stub;
        return stub;
      }
      final Set<String> vis = visiting ?? <String>{};
      if (!vis.add(id)) {
        // Cycle detected — return the current style as-is.
        localResolved[id] = current;
        return current;
      }
      if (current.basedOnId.isEmpty) {
        localResolved[id] = current;
        return current;
      }
      final Styles parent = resolve(current.basedOnId, vis);
      final Styles merged = Styles.merged(current, parent);
      localResolved[id] = merged;
      return merged;
    }

    for (final Styles s in stylesList) {
      resolve(s.styleId);
    }

    // Plumb maps back to caller if they were provided.
    if (stylesById != null) {
      stylesById
        ..clear()
        ..addAll(localById);
    }
    if (resolvedStylesById != null) {
      resolvedStylesById
        ..clear()
        ..addAll(localResolved);
    }

    // Defaults — rPrDefault / pPrDefault. Single-pass walk of each subtree.
    final Iterable<xml.XmlElement> rDefault =
        stylesDoc.findAllElements('w:rPrDefault');
    if (rDefault.isNotEmpty) {
      final xml.XmlElement rPr =
          _firstChild(rDefault.first, 'w:rPr') ?? rDefault.first;
      final String? sz = _readAttribute(rPr, 'w:sz', 'w:val');
      if (sz != null) defaultValues['fontSize'] = sz;
    }
    final Iterable<xml.XmlElement> pDefault =
        stylesDoc.findAllElements('w:pPrDefault');
    if (pDefault.isNotEmpty) {
      final xml.XmlElement pPr =
          _firstChild(pDefault.first, 'w:pPr') ?? pDefault.first;
      final String? line = _readAttribute(pPr, 'w:spacing', 'w:line');
      if (line != null) defaultValues['lineSpacing'] = line;
    }
  }

  /// Parse a single `<w:style>` element using a single-pass visitor.
  static Styles _parseStyleElement(xml.XmlElement style) {
    String name = '';
    String type = '';
    String styleId = '';

    final String? tempType = style.getAttribute('w:type');
    if (tempType != null) type = tempType;
    final String? tempStyleId = style.getAttribute('w:styleId');
    if (tempStyleId != null) styleId = tempStyleId;

    final Styles tempStyles = Styles(name, type, styleId);
    // name will be filled in below if present.
    tempStyles.name = '';

    for (final xml.XmlElement child in style.childElements) {
      switch (child.name.local) {
        case 'name':
          final String? v = child.getAttribute('w:val');
          if (v != null) tempStyles.name = v;
          break;
        case 'basedOn':
          final String? b = child.getAttribute('w:val');
          if (b != null) tempStyles.basedOnId = b;
          break;
        case 'pPr':
          _parseParagraphProps(child, tempStyles);
          break;
        case 'rPr':
          _parseRunProps(child, tempStyles);
          break;
        case 'tblPr':
          _parseTableProps(child, tempStyles);
          break;
        case 'tblStylePr':
          _parseTableStylePr(child, tempStyles);
          break;
        default:
          break;
      }
    }
    // If name was not set explicitly, fall back to styleId.
    if (tempStyles.name.isEmpty) tempStyles.name = styleId;
    return tempStyles;
  }

  static void _parseParagraphProps(xml.XmlElement pPr, Styles target) {
    for (final xml.XmlElement child in pPr.childElements) {
      switch (child.name.local) {
        case 'ind':
          final String? fl = child.getAttribute('w:firstLine');
          if (fl != null) target.firstLineInd = int.parse(fl);
          final String? li = child.getAttribute('w:left');
          if (li != null) target.leftInd = int.parse(li);
          break;
        case 'keepNext':
          target.keepNext = true;
          break;
        case 'keepLines':
          target.keepLines = true;
          break;
        case 'pageBreakBefore':
          target.pageBreakBefore = true;
          break;
        case 'spacing':
          final String? before = child.getAttribute('w:before');
          if (before != null) target.spacingBefore = int.parse(before);
          final String? after = child.getAttribute('w:after');
          if (after != null) target.spacingAfter = int.parse(after);
          break;
        case 'outlineLvl':
          final String? lvl = child.getAttribute('w:val');
          if (lvl != null) target.outlineLvl = int.parse(lvl);
          break;
        case 'jc':
          final String? jc = child.getAttribute('w:val');
          if (jc != null) target.jc = jc;
          break;
        case 'pBdr':
          target.paraGraphBorder = _readBorderMap(child);
          break;
        default:
          break;
      }
    }
  }

  static void _parseRunProps(xml.XmlElement rPr, Styles target) {
    for (final xml.XmlElement child in rPr.childElements) {
      switch (child.name.local) {
        case 'b':
          target.formats.add('bold');
          break;
        case 'i':
          target.formats.add('italic');
          break;
        case 'u':
          final String? v = child.getAttribute('w:val');
          if (v == 'single') {
            target.formats.add('single-underline');
          } else if (v == 'double') {
            target.formats.add('double-underline');
          }
          break;
        case 'strike':
          target.formats.add('strike');
          break;
        case 'vertAlign':
          final String? v = child.getAttribute('w:val');
          if (v == 'superscript') {
            target.formats.add('superscript');
          } else if (v == 'subscript') {
            target.formats.add('subscript');
          }
          break;
        case 'color':
          final String? c = child.getAttribute('w:val');
          if (c != null) target.textColor = c;
          break;
        case 'sz':
          final String? s = child.getAttribute('w:val');
          if (s != null) target.fontSize = int.parse(s);
          break;
        case 'rFonts':
          final String? ascii = child.getAttribute('w:ascii');
          if (ascii != null) target.fonts['ascii'] = ascii;
          final String? hAnsi = child.getAttribute('w:hAnsi');
          if (hAnsi != null) target.fonts['hAnsi'] = hAnsi;
          break;
        default:
          break;
      }
    }
  }

  static void _parseTableProps(xml.XmlElement tblPr, Styles target) {
    final xml.XmlElement? borders = _firstChild(tblPr, 'w:tblBorders');
    if (borders != null) {
      target.tableBorder = _readBorderMap(borders);
    }
  }

  static void _parseTableStylePr(xml.XmlElement tblStylePr, Styles target) {
    final String? belongsTo = tblStylePr.getAttribute('w:type');
    if (belongsTo == null) return;
    final RowColStyles rowColStyles = RowColStyles(belongsTo);
    for (final xml.XmlElement child in tblStylePr.childElements) {
      switch (child.name.local) {
        case 'rPr':
          final String? sz = _readAttribute(child, 'w:sz', 'w:val');
          if (sz != null) rowColStyles.fontSize = int.parse(sz);
          if (_hasChild(child, 'w:b')) rowColStyles.formats.add('bold');
          final String? color = _readAttribute(child, 'w:color', 'w:val');
          if (color != null) rowColStyles.textColor = color;
          break;
        case 'tcPr':
          final xml.XmlElement? tcBorders =
              _firstChild(child, 'w:tcBorders');
          if (tcBorders != null) {
            rowColStyles.cellBorder = _readBorderMap(tcBorders);
          }
          final String? shd = _readAttribute(child, 'w:shd', 'w:fill');
          if (shd != null) rowColStyles.shadingColor = shd;
          break;
        default:
          break;
      }
    }
    target.rowColStyles.add(rowColStyles);
  }

  /// Read all four directional borders (top/left/bottom/right) from an
  /// element that contains `w:top`, `w:left`, `w:bottom`, `w:right` children.
  /// Single-pass walk.
  static Map<String, String> _readBorderMap(xml.XmlElement parent) {
    final Map<String, String> out = <String, String>{};
    for (final xml.XmlElement child in parent.childElements) {
      final String prefix;
      switch (child.name.local) {
        case 'top':
          prefix = 'top-';
          break;
        case 'left':
          prefix = 'left-';
          break;
        case 'bottom':
          prefix = 'bottom-';
          break;
        case 'right':
          prefix = 'right-';
          break;
        default:
          continue;
      }
      final String? v = child.getAttribute('w:val');
      if (v != null) out['${prefix}va'] = v;
      final String? sz = child.getAttribute('w:sz');
      if (sz != null) out['${prefix}sz'] = sz;
      final String? color = child.getAttribute('w:color');
      if (color != null) out['${prefix}color'] = color;
    }
    return out;
  }

  static xml.XmlElement? _firstChild(xml.XmlElement parent, String localName) {
    for (final xml.XmlElement c in parent.childElements) {
      if (c.name.local == localName) return c;
    }
    return null;
  }

  static bool _hasChild(xml.XmlElement parent, String localName) {
    return _firstChild(parent, localName) != null;
  }

  static String? _readAttribute(
    xml.XmlElement parent,
    String childLocalName,
    String attrName,
  ) {
    final xml.XmlElement? child = _firstChild(parent, childLocalName);
    if (child == null) return null;
    return child.getAttribute(attrName);
  }

  /// Parse `word/fontTable.xml` + its `.rels` into [fontDetails].
  /// Single synchronous pass, no isolates.
  void processFonts(
    List<FontDetails> fontDetails,
    ArchiveFile fontTableFile,
    ArchiveFile fontTableRelsFile,
  ) {
    final String fileContent = utf8.decode(fontTableFile.content);
    final xml.XmlDocument fontTableDoc = xml.XmlDocument.parse(fileContent);
    final Iterable<xml.XmlElement> fonts = fontTableDoc.findAllElements('w:font');
    if (fonts.isEmpty) return;

    final Map<String, Map<String, String>> tempFontMap =
        <String, Map<String, String>>{};
    for (final xml.XmlElement font in fonts) {
      final String? fontName = font.getAttribute('w:name');
      if (fontName == null) continue;
      final Map<String, String> tempFontDetails = <String, String>{};
      for (final xml.XmlElement child in font.childElements) {
        if (child.name.local == 'embedRegular' ||
            child.name.local == 'embedBold' ||
            child.name.local == 'embedItalic' ||
            child.name.local == 'embedBoldItalic') {
          final String? rid = child.getAttribute('r:id');
          final String? fontKey = child.getAttribute('w:fontKey');
          if (rid != null) tempFontDetails['embedReg'] = rid;
          if (fontKey != null) tempFontDetails['fontKey'] = fontKey;
        }
      }
      if (tempFontDetails.isNotEmpty) {
        tempFontMap[fontName] = tempFontDetails;
      }
    }

    final String relFileContent = utf8.decode(fontTableRelsFile.content);
    final xml.XmlDocument fontTableRelDoc = xml.XmlDocument.parse(relFileContent);
    final Iterable<xml.XmlElement> relationships =
        fontTableRelDoc.findAllElements('Relationship');
    if (relationships.isEmpty) return;

    final Map<String, String> relDetails = <String, String>{};
    for (final xml.XmlElement rel in relationships) {
      final String? relId = rel.getAttribute('Id');
      final String? target = rel.getAttribute('Target');
      if (relId != null && target != null) {
        relDetails[relId] = target;
      }
    }
    tempFontMap.forEach((String key, Map<String, String> value) {
      String fileName = '';
      String fontKey = '';
      value.forEach((String key2, String value2) {
        if (key2 == 'embedReg') {
          final String? t = relDetails[value2];
          if (t != null) fileName = t;
        } else {
          fontKey = value2;
        }
      });
      fontDetails.add(FontDetails(key, fileName, fontKey));
    });
  }

  /// Kept for backwards compatibility — no longer spawns isolates.
  /// Parses a single `<w:style>` element using the single-pass visitor.
  static Styles getStyles(GetStylesParam stylesParam) {
    return _parseStyleElement(stylesParam.style);
  }
}

/// Params for [CommonProcessor.getStyles]. Retained for backwards compat.
class GetStylesParam {
  /// Styles element.
  xml.XmlElement style;

  /// Constructor.
  GetStylesParam(this.style);
}
