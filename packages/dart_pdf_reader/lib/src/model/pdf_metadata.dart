import 'dart:convert';

import 'package:meta/meta.dart';

import 'pdf_constants.dart';
import 'pdf_document.dart';
import 'pdf_types.dart';
import '../parser/object_resolver.dart';

/// Document-level metadata extracted from a PDF.
///
/// Values are sourced from the trailer's `Info` dictionary first, then
/// optionally augmented from the catalog's XMP `Metadata` stream when the
/// `Info` entry is missing or empty. This matches the behaviour of pdfjs,
/// which reads both sources and merges them.
@immutable
class PDFMetadata {
  /// The document title (Info:Title or XMP dc:title).
  final String? title;

  /// The document author (Info:Author or XMP dc:creator).
  final String? author;

  /// The document subject (Info:Subject or XMP dc:description).
  final String? subject;

  /// Keywords associated with the document (Info:Keywords or XMP pdf:Keywords).
  final String? keywords;

  /// The application that created the original document (Info:Creator or
  /// XMP xmp:CreatorTool).
  final String? creator;

  /// The PDF producer library (Info:Producer or XMP pdf:Producer).
  final String? producer;

  /// The creation date as stored in the PDF (Info:CreationDate or
  /// XMP xmp:CreateDate). The raw string is returned; parse it with
  /// [PDFMetadata.parseDate] if needed.
  final String? creationDate;

  /// The last modification date (Info:ModDate or XMP xmp:ModifyDate).
  final String? modDate;

  /// The PDF version declared by the document, if any.
  final String? version;

  /// The document language, if any.
  final String? language;

  /// Custom metadata keys found in the Info dictionary that are not part of
  /// the standard set. Values are decoded using the same string decoder as
  /// standard fields.
  final Map<String, String> custom;

  /// Raw XMP metadata (the unparsed XML string), if a Metadata stream was
  /// present in the catalog.
  final String? rawXmp;

  /// Creates a new [PDFMetadata] instance.
  const PDFMetadata({
    this.title,
    this.author,
    this.subject,
    this.keywords,
    this.creator,
    this.producer,
    this.creationDate,
    this.modDate,
    this.version,
    this.language,
    this.custom = const {},
    this.rawXmp,
  });

  /// Parses a PDF date string (e.g. `D:20240101120000+00'00'`) into a UTC
  /// [DateTime]. Returns `null` if the string cannot be parsed.
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var s = raw;
    if (s.startsWith('D:')) s = s.substring(2);

    final year = int.tryParse(s.substring(0, 4));
    if (year == null) return null;
    var idx = 4;
    int readPair() {
      if (idx + 2 > s.length) return 0;
      final v = int.tryParse(s.substring(idx, idx + 2));
      idx += 2;
      return v ?? 0;
    }

    var month = 1, day = 1, hour = 0, minute = 0, second = 0;
    if (idx + 2 <= s.length && _isDigit(s[idx])) {
      month = readPair();
    }
    if (idx + 2 <= s.length && _isDigit(s[idx])) {
      day = readPair();
    }
    if (idx + 2 <= s.length && _isDigit(s[idx])) {
      hour = readPair();
    }
    if (idx + 2 <= s.length && _isDigit(s[idx])) {
      minute = readPair();
    }
    if (idx + 2 <= s.length && _isDigit(s[idx])) {
      second = readPair();
    }

    var tzOffsetMinutes = 0;
    var hasTz = false;
    if (idx < s.length) {
      final tzChar = s[idx];
      if (tzChar == 'Z') {
        hasTz = true;
        tzOffsetMinutes = 0;
      } else if (tzChar == '+' || tzChar == '-') {
        hasTz = true;
        final sign = tzChar == '+' ? 1 : -1;
        idx++;
        var tzH = 0;
        if (idx + 2 <= s.length && _isDigit(s[idx])) {
          tzH = int.tryParse(s.substring(idx, idx + 2)) ?? 0;
          idx += 2;
        }
        // Optional ' (apostrophe) separator before minutes.
        if (idx < s.length && s[idx] == "'") idx++;
        var tzM = 0;
        if (idx + 2 <= s.length && _isDigit(s[idx])) {
          tzM = int.tryParse(s.substring(idx, idx + 2)) ?? 0;
        }
        tzOffsetMinutes = sign * (tzH * 60 + tzM);
      }
    }

    final dt = DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
    );
    if (!hasTz) return dt;
    return dt.subtract(Duration(minutes: tzOffsetMinutes)).toUtc();
  }

  static bool _isDigit(String c) =>
      c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  @override
  String toString() => 'PDFMetadata(title: $title, author: $author, '
      'subject: $subject, keywords: $keywords, creator: $creator, '
      'producer: $producer, creationDate: $creationDate, modDate: $modDate, '
      'version: $version, language: $language, custom: $custom)';
}

/// Reads [PDFMetadata] from a [PDFDocument], mirroring pdfjs's approach:
/// read the trailer's Info dictionary first, then optionally merge in values
/// from the catalog's XMP Metadata stream.
///
/// Robust against malformed PDFs: any error while resolving a particular field
/// is swallowed and the field is left null, so callers always get back a
/// non-null [PDFMetadata] object even when the underlying PDF is broken.
Future<PDFMetadata> readPdfMetadata(PDFDocument document) async {
  final title = <String?>[];
  final author = <String?>[];
  final subject = <String?>[];
  final keywords = <String?>[];
  final creator = <String?>[];
  final producer = <String?>[];
  final creationDate = <String?>[];
  final modDate = <String?>[];
  final version = <String?>[];
  final language = <String?>[];
  final custom = <String, String>{};
  final rawXmp = <String?>[];

  // 1. Try the Info dictionary from the trailer.
  try {
    final infoDict =
        await document.resolve<PDFDictionary>(document.mainTrailer[PDFNames.info]);
    if (infoDict != null) {
      final info = _readInfoDictionary(infoDict);
      title.add(info.title);
      author.add(info.author);
      subject.add(info.subject);
      keywords.add(info.keywords);
      creator.add(info.creator);
      producer.add(info.producer);
      creationDate.add(info.creationDate);
      modDate.add(info.modDate);
      custom.addAll(info.custom);
    }
  } catch (_) {
    // Info dictionary missing or malformed - fall through to XMP.
  }

  // 2. Try the catalog's XMP Metadata stream as a fallback / supplement.
  try {
    final catalog = await document.catalog;
    final xmp = await _readXmpMetadata(catalog.dictionary, catalog.resolver);
    if (xmp != null) {
      rawXmp.add(xmp);
      final xmpMeta = parseXmpMetadata(xmp);
      title.add(xmpMeta.title);
      author.add(xmpMeta.author);
      subject.add(xmpMeta.subject);
      keywords.add(xmpMeta.keywords);
      creator.add(xmpMeta.creator);
      producer.add(xmpMeta.producer);
      creationDate.add(xmpMeta.creationDate);
      modDate.add(xmpMeta.modDate);
    }

    // 3. Catalog-level version and language as a last resort.
    if (version.isEmpty) {
      final v = await catalog.getVersion();
      version.add(v);
    }
    if (language.isEmpty) {
      final l = await catalog.getLanguage();
      language.add(l);
    }
  } catch (_) {
    // Catalog missing or malformed - ignore.
  }

  String? firstNonEmpty(List<String?> list) =>
      list.firstWhere((e) => e != null && e.isNotEmpty, orElse: () => null);

  return PDFMetadata(
    title: firstNonEmpty(title),
    author: firstNonEmpty(author),
    subject: firstNonEmpty(subject),
    keywords: firstNonEmpty(keywords),
    creator: firstNonEmpty(creator),
    producer: firstNonEmpty(producer),
    creationDate: firstNonEmpty(creationDate),
    modDate: firstNonEmpty(modDate),
    version: firstNonEmpty(version),
    language: firstNonEmpty(language),
    custom: custom,
    rawXmp: firstNonEmpty(rawXmp),
  );
}

PDFMetadata _readInfoDictionary(PDFDictionary infoDict) {
  String? readString(PDFName name) {
    final obj = infoDict[name];
    if (obj is PDFStringLike) {
      return obj.asString();
    }
    if (obj is PDFName) {
      return obj.value;
    }
    return null;
  }

  final custom = <String, String>{};
  const standardKeys = <String>{
    'Title',
    'Author',
    'Subject',
    'Keywords',
    'Creator',
    'Producer',
    'CreationDate',
    'ModDate',
    'Trapped',
  };

  for (final entry in infoDict.entries.entries) {
    final keyName = entry.key.value;
    if (standardKeys.contains(keyName)) continue;
    final value = entry.value;
    String? decoded;
    if (value is PDFStringLike) {
      decoded = value.asString();
    } else if (value is PDFName) {
      decoded = value.value;
    } else if (value is PDFNumber) {
      decoded = value.toString();
    } else if (value is PDFBoolean) {
      decoded = value.value.toString();
    }
    if (decoded != null && decoded.isNotEmpty) {
      custom[keyName] = decoded;
    }
  }

  return PDFMetadata(
    title: readString(PDFNames.title),
    author: readString(PDFNames.author),
    subject: readString(PDFNames.subject),
    keywords: readString(PDFNames.keywords),
    creator: readString(PDFNames.creator),
    producer: readString(PDFNames.producer),
    creationDate: readString(PDFNames.creationDate),
    modDate: readString(PDFNames.modDate),
    custom: custom,
  );
}

Future<String?> _readXmpMetadata(
  PDFDictionary catalogDict,
  ObjectResolver resolver,
) async {
  final raw = catalogDict[PDFNames.metadata];
  if (raw == null) return null;

  final stream = await resolver.resolve<PDFStreamObject>(raw);
  if (stream == null) return null;

  // Validate Subtype is XML (per the PDF spec), but tolerate missing/incorrect
  // entries — many real-world PDFs do not set Subtype correctly.
  final subtype = stream.dictionary[PDFNames.subtype];
  if (subtype is PDFName && subtype.value != 'XML') {
    return null;
  }

  final bytes = await stream.read(resolver);
  // XMP is required to be UTF-8 by the XMP specification; try that first and
  // fall back to Latin-1 if the bytes are not valid UTF-8.
  try {
    return utf8.decode(bytes, allowMalformed: true);
  } catch (_) {
    return String.fromCharCodes(bytes);
  }
}

/// Parses the raw XMP XML string into a [PDFMetadata]. Only the most common
/// fields are extracted; everything else is left null.
///
/// This is a deliberately small XML parser tuned for XMP — XMP is well-formed
/// in practice, so a hand-written tag scanner is faster and more forgiving
/// than depending on `dart:html` or a third-party XML package.
PDFMetadata parseXmpMetadata(String xml) {
  if (xml.isEmpty) return const PDFMetadata();

  String? extract(String tag) {
    // Match either <tag>value</tag> or <tag ...>value</tag> (with attributes).
    final openRe = RegExp('<$tag(?:\\s[^>]*)?>([^<]*)</$tag>',
        caseSensitive: false, dotAll: true);
    final m = openRe.firstMatch(xml);
    if (m == null) return null;
    final value = m.group(1);
    if (value == null) return null;
    return _decodeXmlEntities(value).trim();
  }

  // dc:creator and dc:subject are typically wrapped in rdf:Bag / rdf:Seq /
  // rdf:Alt structures with <rdf:li> items. We extract all <rdf:li> values
  // and join them.
  String? extractList(String tag) {
    final blockRe = RegExp(
      '<$tag(?:\\s[^>]*)?>([\\s\\S]*?)</$tag>',
      caseSensitive: false,
    );
    final blockMatch = blockRe.firstMatch(xml);
    if (blockMatch == null) return extract(tag);
    final inner = blockMatch.group(1) ?? '';
    final liRe = RegExp(r'<rdf:li(?:\s[^>]*)?>([^<]*)</rdf:li>',
        caseSensitive: false);
    final items = liRe
        .allMatches(inner)
        .map((m) => _decodeXmlEntities(m.group(1) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (items.isEmpty) {
      return extract(tag);
    }
    return items.join(', ');
  }

  return PDFMetadata(
    title: extractList('dc:title') ?? extract('pdf:Title'),
    author: extractList('dc:creator') ?? extract('pdf:Author'),
    subject: extractList('dc:description') ?? extract('pdf:Subject'),
    keywords: extract('pdf:Keywords'),
    creator: extract('xmp:CreatorTool') ?? extract('pdf:Creator'),
    producer: extract('pdf:Producer'),
    creationDate: extract('xmp:CreateDate'),
    modDate: extract('xmp:ModifyDate'),
    rawXmp: xml,
  );
}

String _decodeXmlEntities(String s) {
  if (!s.contains('&')) return s;
  return s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}
