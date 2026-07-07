// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:test/test.dart';

void main() {
  group('decodePdfTextString (pdfjs parity)', () {
    test('ASCII string decodes identically', () {
      final bytes = Uint8List.fromList(utf8.encode('Hello World'));
      expect(decodePdfTextString(bytes), 'Hello World');
    });

    test('UTF-16BE BOM is decoded', () {
      // FE FF 00 48 00 65 00 6C 00 6C 00 6F -> "Hello"
      final bytes = Uint8List.fromList([
        0xFE, 0xFF, 0x00, 0x48, 0x00, 0x65, 0x00, 0x6C, 0x00, 0x6C, 0x00, 0x6F
      ]);
      expect(decodePdfTextString(bytes), 'Hello');
    });

    test('UTF-16LE BOM is decoded', () {
      // FF FE 48 00 65 00 6C 00 6C 00 6F 00 -> "Hello"
      final bytes = Uint8List.fromList([
        0xFF, 0xFE, 0x48, 0x00, 0x65, 0x00, 0x6C, 0x00, 0x6C, 0x00, 0x6F, 0x00
      ]);
      expect(decodePdfTextString(bytes), 'Hello');
    });

    test('UTF-8 BOM is stripped and decoded', () {
      // EF BB BF 48 65 6C 6C 6F -> "Hello"
      final bytes =
          Uint8List.fromList([0xEF, 0xBB, 0xBF, 0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      expect(decodePdfTextString(bytes), 'Hello');
    });

    test('PDFDocEncoding byte 0xA0 -> bullet', () {
      // 0xA0 is U+2022 BULLET in PDFDocEncoding
      final bytes = Uint8List.fromList([0x41, 0xA0, 0x42]);
      expect(decodePdfTextString(bytes), 'A\u2022B');
    });

    test('PDFDocEncoding byte 0xC0 -> Euro sign', () {
      // 0xC0 is U+20AC EURO SIGN in PDFDocEncoding
      final bytes = Uint8List.fromList([0x31, 0x32, 0x33, 0xC0]);
      expect(decodePdfTextString(bytes), '123\u20AC');
    });

    test('Latin-1 fallback for byte 0xE9 (é)', () {
      // 0xE9 is "é" in Latin-1; PDFDocEncoding leaves it as Latin-1.
      final bytes = Uint8List.fromList([0x4A, 0x6F, 0x73, 0xE9]);
      expect(decodePdfTextString(bytes), 'José');
    });

    test('Language escape sequences (0x1b-delimited) are stripped', () {
      // "A" + ESC + "lang-code" + ESC + "B"
      final bytes = Uint8List.fromList([0x41, 0x1B, 0x6C, 0x61, 0x6E, 0x67, 0x1B, 0x42]);
      expect(decodePdfTextString(bytes), 'AB');
    });

    test('Regression: bytes that look like UTF-8 lead bytes do not truncate', () {
      // 0xC0 followed by 'a' is INVALID UTF-8 (overlong start) and was
      // previously swallowed by utf8.decode(allowMalformed). With
      // PDFDocEncoding it now decodes to the Euro sign + 'a'.
      final bytes = Uint8List.fromList([0xC0, 0x61, 0x62, 0x63]);
      expect(decodePdfTextString(bytes), '\u20ACabc');
    });
  });

  group('PDFLiteralString.asString()', () {
    test('PDFDocEncoding round trip', () {
      final s = PDFLiteralString(Uint8List.fromList([0x4A, 0x6F, 0x73, 0xE9]));
      expect(s.asString(), 'José');
    });

    test('UTF-16BE BOM is honoured', () {
      final s = PDFLiteralString(Uint8List.fromList([
        0xFE, 0xFF, 0x00, 0x48, 0x00, 0x69
      ]));
      expect(s.asString(), 'Hi');
    });
  });

  group('PDFMetadata.parseDate', () {
    test('parses a basic UTC date', () {
      final dt = PDFMetadata.parseDate('D:20240101120000Z');
      expect(dt, isNotNull);
      expect(dt!.toUtc(), DateTime.utc(2024, 1, 1, 12, 0, 0));
    });

    test('parses a date with offset', () {
      final dt = PDFMetadata.parseDate("D:20240101120000+02'00'");
      expect(dt, isNotNull);
      expect(dt!.toUtc(), DateTime.utc(2024, 1, 1, 10, 0, 0));
    });

    test('parses a date with no TZ as local', () {
      final dt = PDFMetadata.parseDate('D:20240101120000');
      expect(dt, isNotNull);
      expect(dt!.year, 2024);
      expect(dt.month, 1);
      expect(dt.day, 1);
      expect(dt.hour, 12);
    });

    test('returns null for garbage', () {
      expect(PDFMetadata.parseDate(null), isNull);
      expect(PDFMetadata.parseDate(''), isNull);
      expect(PDFMetadata.parseDate('not a date'), isNull);
    });
  });

  group('parseXmpMetadata', () {
    const xmp = '''<?xpacket begin="\xef\xbb\xbf" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:title>My Document Title</dc:title>
      <dc:creator>
        <rdf:Seq>
          <rdf:li>José Author</rdf:li>
          <rdf:li>Second Author</rdf:li>
        </rdf:Seq>
      </dc:creator>
      <dc:description>The subject</dc:description>
    </rdf:Description>
    <rdf:Description xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
      <pdf:Keywords>dart, pdf, metadata</pdf:Keywords>
      <pdf:Producer>pdfjs-compatible producer</pdf:Producer>
    </rdf:Description>
    <rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/">
      <xmp:CreatorTool>TheCreatorTool</xmp:CreatorTool>
      <xmp:CreateDate>2024-01-01T12:00:00Z</xmp:CreateDate>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
<?xpacket end="w"?>''';

    test('extracts title', () {
      expect(parseXmpMetadata(xmp).title, 'My Document Title');
    });

    test('extracts dc:creator list as comma-separated string', () {
      expect(parseXmpMetadata(xmp).author, 'José Author, Second Author');
    });

    test('extracts subject', () {
      expect(parseXmpMetadata(xmp).subject, 'The subject');
    });

    test('extracts keywords', () {
      expect(parseXmpMetadata(xmp).keywords, 'dart, pdf, metadata');
    });

    test('extracts producer', () {
      expect(parseXmpMetadata(xmp).producer, 'pdfjs-compatible producer');
    });

    test('extracts creator tool', () {
      expect(parseXmpMetadata(xmp).creator, 'TheCreatorTool');
    });

    test('extracts creation date', () {
      expect(parseXmpMetadata(xmp).creationDate, '2024-01-01T12:00:00Z');
    });
  });

  group('Regression: buggy UTF-8 fallback cases', () {
    // These cases reproduce the user's symptoms and verify they are fixed.

    test('Author "José" stored as PDFDocEncoding no longer "unknown"', () {
      // Previously: utf8.decode([0x4A, 0x6F, 0x73, 0xE9], allowMalformed: true)
      // would return "Jos\uFFFD" (replacement char) which the user saw as
      // "unknown". Now: PDFDocEncoding correctly returns "José".
      final author = PDFLiteralString(Uint8List.fromList([0x4A, 0x6F, 0x73, 0xE9]));
      expect(author.asString(), 'José');
    });

    test('Title no longer truncated when containing non-ASCII byte', () {
      // "Document.pdf" with a Latin-1 byte (0xE9 = é) in the middle. Previously
      // this byte was a UTF-8 3-byte sequence lead and, with allowMalformed,
      // would either swallow following characters or emit U+FFFD. Now it is
      // decoded as the Latin-1 identity (é) and the rest of the string is
      // preserved verbatim.
      final title = PDFLiteralString(Uint8List.fromList([
        0x44, 0x6F, 0x63, 0x75, 0x6D, 0x65, 0x6E, 0x74, 0xE9, 0x2E, 0x70, 0x64, 0x66
      ]));
      expect(title.asString(), 'Documenté.pdf');
    });

    test('UTF-16LE BOM is decoded (previously only UTF-16BE worked)', () {
      // "Author" in UTF-16LE
      final author = PDFLiteralString(Uint8List.fromList([
        0xFF, 0xFE,
        0x41, 0x00, 0x75, 0x00, 0x74, 0x00, 0x68, 0x00, 0x6F, 0x00, 0x72, 0x00
      ]));
      expect(author.asString(), 'Author');
    });
  });
}
