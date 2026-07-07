import 'dart:typed_data';

/// Class for storing image details.
///
/// Added [bytes] to carry the in-memory image data so the renderer can use
/// `Image.memory(bytes)` directly instead of going through `Image.file(path)`.
/// The [imagePath] field is retained for backwards compatibility but is no
/// longer required to be a real on-disk path — when [bytes] is non-null the
/// renderer uses it directly and skips filesystem I/O entirely.
class MsImage {
  /// Image sequence number (position within the parent paragraph).
  int pSeqNo;

  /// Image path — only used as a fallback when [bytes] is null. For
  /// non-web platforms in the legacy flow this was a filesystem path under
  /// the app's support directory; in the new flow it is just the media
  /// entry's basename (informational).
  String imagePath;

  /// Image type — `"inline"` or `"anchor"`.
  String type;

  /// Image width in EMUs (English Metric Units).
  int cx;

  /// Image height in EMUs.
  int cy;

  /// Raw image bytes, populated from the archive's `word/media/<name>` entry
  /// at parse time. When non-null, the renderer uses `Image.memory(bytes)`.
  /// When null (legacy path), the renderer falls back to `Image.file`.
  Uint8List? bytes;

  /// Constructor.
  MsImage(this.pSeqNo, this.imagePath, this.type, this.cx, this.cy,
      {this.bytes});
}
