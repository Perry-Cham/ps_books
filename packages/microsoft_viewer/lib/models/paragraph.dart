import 'package:microsoft_viewer/models/ms_image.dart';
import 'package:microsoft_viewer/models/ms_text_span.dart';

/// Class for storing word paragraph details.
///
/// Performance note: the parser still populates [textSpans] and [images] as
/// parallel lists keyed by `pSeqNo` (preserved for backwards compatibility),
/// but it now also populates [orderedContent] — a single ordered list of
/// `MsTextSpan`/`MsImage` entries in document order. Renderers should prefer
/// [orderedContent] to avoid the O((S+I)²) merge loop in `getComponents`.
class Paragraph {
  int seqNo;
  String style;
  List<MsTextSpan> textSpans = [];
  List<MsImage> images = [];
  /// Unified, ordered list of text spans and images, in document order.
  /// Populated by the parser; consumed by the renderer.
  List<dynamic> orderedContent = [];
  Map<String, String> tabDetails = {};
  String? shadingColor;
  Map<String, String>? formats;

  Paragraph(this.seqNo, this.style);
}
