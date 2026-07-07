import 'package:flutter/foundation.dart';

class ODTTF {
  /// Deobfuscate an ODTTF (obfuscated TrueType font) byte stream.
  ///
  /// Returns a *new* [Uint8List] containing the deobfuscated bytes. The input
  /// [fontData] is left untouched. This is critical because archive entries
  /// are shared mutable buffers — mutating them in place (as the previous
  /// implementation did) corrupts the font on every subsequent parse of the
  /// same archive (e.g. when the user closes and re-opens the document without
  /// re-fetching the bytes).
  Uint8List deobfuscate(Uint8List fontData, String guid) {
    guid = guid.replaceAll('-', '');

    final List<int> key = List<int>.filled(16, 0);
    for (int i = 0; i < 16; i++) {
      final String hex = guid.substring(i * 2, (i * 2) + 2);
      key[i] = int.parse(hex, radix: 16);
    }
    // Reverse the key in place — avoids allocating a second list.
    for (int i = 0; i < 8; i++) {
      final int tmp = key[i];
      key[i] = key[15 - i];
      key[15 - i] = tmp;
    }

    // Always copy. Even if only the first 32 bytes change, we must never write
    // back into the caller's buffer.
    final Uint8List out = Uint8List.fromList(fontData);
    for (int i = 0; i < 32 && i < out.length; i++) {
      out[i] ^= key[i % key.length];
    }
    return out;
  }
}
