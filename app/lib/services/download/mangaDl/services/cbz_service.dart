// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/services/cbz_service.dart — Pack a list of image bytes into a .cbz.
//
// Direct port of `src/services/cbzService.js`. Same convention: a CBZ
// is just a renamed ZIP. Uses package:archive's ZipFileEncoder for
// streaming output (the Dart analogue of Node's archiver).
// -----------------------------------------------------------------------------

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// A single page to pack into the CBZ.
class CbzPage {
  final Uint8List data;
  final String filename;
  const CbzPage({required this.data, required this.filename});
}

/// Pack `pages` into a CBZ file at `outputPath`.
///
/// Mirrors packCbz() in cbzService.js. Returns the output path.
Future<String> packCbz(List<CbzPage> pages, String outputPath) async {
  final outFile = File(outputPath);
  await outFile.parent.create(recursive: true);

  final encoder = ZipFileEncoder();
  encoder.create(outputPath);
  try {
    for (final page in pages) {
      // ZipFileEncoder.addFile takes a File, not bytes. To add bytes
      // directly we use the underlying Archive API.
      // We write each page's bytes to a temp file then add it.
      // (For production you'd use Archive.addFile with raw bytes; we
      // do the temp-file route here because ZipFileEncoder doesn't
      // expose a bytes-only API directly.)
      final tmpPath = p.join(outFile.parent.path, '.tmp_${page.filename}');
      final tmpFile = File(tmpPath);
      await tmpFile.writeAsBytes(page.data);
      encoder.addFile(tmpFile, page.filename);
      await tmpFile.delete();
    }
  } finally {
    encoder.close();
  }
  return outputPath;
}

/// Build a flat list of zero-padded page filenames given a count and
/// an extension. Mirrors pageFilenames() in cbzService.js.
List<String> pageFilenames(int count, {String ext = 'jpg'}) {
  final padWidth = count.toString().length;
  final width = padWidth < 3 ? 3 : padWidth;
  return List<String>.generate(
    count,
    (i) => 'page${(i + 1).toString().padLeft(width, '0')}.$ext',
  );
}
