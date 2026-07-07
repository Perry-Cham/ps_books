import 'dart:convert';
import 'dart:typed_data';

/// PDFDocEncoding translation table, as defined by the PDF 1.7 specification
/// (Annex D, Section D.1).
///
/// For each byte value 0x00-0xFF, the table provides the corresponding Unicode
/// code point. A value of `0` means "the byte itself should be used as a Latin-1
/// code point" (i.e. the byte maps to the Unicode code point equal to the byte
/// value). This matches pdfjs's `PDFStringTranslateTable` semantics and keeps
/// backwards-compatible behaviour for ASCII strings while correctly decoding
/// PDFDocEncoding-specific characters (e.g. 0xA0 -> U+2022 BULLET).
///
/// Bytes that are explicitly undefined in PDFDocEncoding (0x7F, 0x80-0x9F,
/// 0xBF, 0xC1-0xFF) fall back to their Latin-1 code point, which is the same
/// behaviour as pdfjs and prevents the decoder from crashing on real-world
/// PDFs that occasionally misuse those slots.
@pragma('vm:prefer-inline')
int pdfDocEncodingMap(int byte) {
  // 0x00 - 0x17: control chars, same as Latin-1 (value 0 -> use byte).
  // 0x18 - 0x1F: PDFDocEncoding-specific (breve, caron, etc.).
  // 0x20 - 0x7E: printable ASCII, same as Latin-1.
  // 0x7F: undefined in PDFDocEncoding -> Latin-1 fallback (DEL).
  // 0x80 - 0x9F: undefined in PDFDocEncoding -> Latin-1 fallback (C1 controls).
  // 0xA0 - 0xBF: PDFDocEncoding-specific (bullet, dagger, quotes, ligatures).
  // 0xC0: Euro sign (U+20AC).
  // 0xC1 - 0xFF: undefined in PDFDocEncoding -> Latin-1 fallback.
  switch (byte) {
    case 0x18:
      return 0x02D8; // ˘ BREVE
    case 0x19:
      return 0x02C7; // ˇ CARON
    case 0x1A:
      return 0x02C6; // ˆ MODIFIER LETTER CIRCUMFLEX ACCENT
    case 0x1B:
      return 0x02D9; // ˙ DOT ABOVE
    case 0x1C:
      return 0x02DD; // ˝ DOUBLE ACUTE ACCENT
    case 0x1D:
      return 0x02DB; // ˛ OGONEK
    case 0x1E:
      return 0x02DA; // ˚ RING ABOVE
    case 0x1F:
      return 0x02DC; // ˜ SMALL TILDE
    case 0xA0:
      return 0x2022; // • BULLET
    case 0xA1:
      return 0x2020; // † DAGGER
    case 0xA2:
      return 0x2021; // ‡ DOUBLE DAGGER
    case 0xA3:
      return 0x2026; // … HORIZONTAL ELLIPSIS
    case 0xA4:
      return 0x2014; // — EM DASH
    case 0xA5:
      return 0x2013; // – EN DASH
    case 0xA6:
      return 0x0192; // ƒ LATIN SMALL LETTER F WITH HOOK
    case 0xA7:
      return 0x2044; // ⁄ FRACTION SLASH
    case 0xA8:
      return 0x2039; // ‹ SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    case 0xA9:
      return 0x203A; // › SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    case 0xAA:
      return 0x2212; // − MINUS SIGN
    case 0xAB:
      return 0x2030; // ‰ PER MILLE SIGN
    case 0xAC:
      return 0x201E; // „ DOUBLE LOW-9 QUOTATION MARK
    case 0xAD:
      return 0x201C; // " LEFT DOUBLE QUOTATION MARK
    case 0xAE:
      return 0x201D; // " RIGHT DOUBLE QUOTATION MARK
    case 0xAF:
      return 0x2018; // ' LEFT SINGLE QUOTATION MARK
    case 0xB0:
      return 0x2019; // ' RIGHT SINGLE QUOTATION MARK
    case 0xB1:
      return 0x201A; // ‚ SINGLE LOW-9 QUOTATION MARK
    case 0xB2:
      return 0x2122; // ™ TRADE MARK SIGN
    case 0xB3:
      return 0xFB01; // ﬁ LATIN SMALL LIGATURE FI
    case 0xB4:
      return 0xFB02; // ﬂ LATIN SMALL LIGATURE FL
    case 0xB5:
      return 0x0141; // Ł LATIN CAPITAL LETTER L WITH STROKE
    case 0xB6:
      return 0x0152; // Œ LATIN CAPITAL LIGATURE OE
    case 0xB7:
      return 0x0160; // Š LATIN CAPITAL LETTER S WITH CARON
    case 0xB8:
      return 0x0178; // Ÿ LATIN CAPITAL LETTER Y WITH DIAERESIS
    case 0xB9:
      return 0x017D; // Ž LATIN CAPITAL LETTER Z WITH CARON
    case 0xBA:
      return 0x0131; // ı LATIN SMALL LETTER DOTLESS I
    case 0xBB:
      return 0x0142; // ł LATIN SMALL LETTER L WITH STROKE
    case 0xBC:
      return 0x0153; // œ LATIN SMALL LIGATURE OE
    case 0xBD:
      return 0x0161; // š LATIN SMALL LETTER S WITH CARON
    case 0xBE:
      return 0x017E; // ž LATIN SMALL LETTER Z WITH CARON
    case 0xC0:
      return 0x20AC; // € EURO SIGN
    default:
      // Identity mapping for the ASCII range, the undefined C1 range, and
      // 0xC1-0xFF. This is the same fall-back pdfjs uses.
      return byte;
  }
}

/// Decodes [bytes] as a PDF text string, following the same algorithm as
/// pdfjs's `stringToPDFString`:
///
///   1. If the string starts with the UTF-16BE BOM (FE FF), decode as UTF-16BE.
///   2. If the string starts with the UTF-16LE BOM (FF FE), decode as UTF-16LE.
///   3. If the string starts with the UTF-8 BOM (EF BB BF), decode as UTF-8
///      (after stripping the BOM).
///   4. Otherwise, decode using PDFDocEncoding (with Latin-1 fallback for
///      undefined slots).
///
/// Language escape sequences bracketed by 0x1B bytes (PDF spec §7.9.2.2) are
/// stripped from non-Unicode strings, mirroring pdfjs behaviour.
String decodePdfTextString(Uint8List bytes) {
  if (bytes.isEmpty) return '';

  final first = bytes[0];

  // UTF-16BE BOM
  if (first == 0xFE && bytes.length >= 2 && bytes[1] == 0xFF) {
    return _decodeUtf16(bytes.sublist(2), bigEndian: true);
  }
  // UTF-16LE BOM
  if (first == 0xFF && bytes.length >= 2 && bytes[1] == 0xFE) {
    return _decodeUtf16(bytes.sublist(2), bigEndian: false);
  }
  // UTF-8 BOM
  if (first == 0xEF &&
      bytes.length >= 3 &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    try {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    } catch (_) {
      return String.fromCharCodes(bytes.sublist(3));
    }
  }

  // PDFDocEncoding / Latin-1 fallback, with language escape stripping.
  final buffer = StringBuffer();
  var i = 0;
  while (i < bytes.length) {
    final byte = bytes[i];
    if (byte == 0x1B) {
      // Language escape sequence: skip until the next 0x1B (or end of string).
      ++i;
      while (i < bytes.length && bytes[i] != 0x1B) {
        ++i;
      }
      if (i < bytes.length) {
        ++i; // consume the closing 0x1B
      }
      continue;
    }
    buffer.writeCharCode(pdfDocEncodingMap(byte));
    ++i;
  }
  return buffer.toString();
}

String _decodeUtf16(Uint8List bytes, {required bool bigEndian}) {
  // Drop a trailing odd byte to keep pairs aligned (matches pdfjs).
  final len = bytes.length & ~1;
  final buffer = StringBuffer();
  for (var i = 0; i < len; i += 2) {
    final unit = bigEndian
        ? (bytes[i] << 8) | bytes[i + 1]
        : (bytes[i + 1] << 8) | bytes[i];
    if (unit >= 0xD800 && unit <= 0xDBFF && i + 3 < len) {
      final next = bigEndian
          ? (bytes[i + 2] << 8) | bytes[i + 3]
          : (bytes[i + 3] << 8) | bytes[i + 2];
      if (next >= 0xDC00 && next <= 0xDFFF) {
        final codePoint = 0x10000 +
            ((unit - 0xD800) << 10) +
            (next - 0xDC00);
        buffer.writeCharCode(codePoint);
        i += 2;
        continue;
      }
    }
    buffer.writeCharCode(unit);
  }
  return buffer.toString();
}

/// Best-effort UTF-8 decoder used for XMP metadata streams and other content
/// that legitimately contains UTF-8. Replaces malformed sequences with U+FFFD.
String utf8AllowMalformed(Uint8List bytes) {
  try {
    return utf8.decode(bytes, allowMalformed: true);
  } catch (_) {
    return String.fromCharCodes(bytes);
  }
}
