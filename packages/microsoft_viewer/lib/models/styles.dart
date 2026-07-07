/// Class for storing styles information.
///
/// Added [basedOnId] to support `w:basedOn` style inheritance. Resolution
/// (merging parent properties into the child) is done by `CommonProcessor`
/// and exposed via the `resolvedStylesById` map.
class Styles {
  String name;
  String type;
  String styleId;
  /// Style id of the parent style (from `w:basedOn w:val="…"`), or empty.
  String basedOnId = '';
  int firstLineInd = 0;
  int leftInd = 0;
  Map<String, String> fonts = {};
  int fontSize = 0;
  bool? keepNext;
  bool? keepLines;
  bool? pageBreakBefore;
  int spacingBefore = 0;
  int spacingAfter = 0;
  int outlineLvl = 0;
  Map<String, String> tableBorder = {};
  Map<String, String> paraGraphBorder = {};
  List<String> formats = [];
  String? textColor;
  String? jc;
  List<RowColStyles> rowColStyles = [];

  Styles(this.name, this.type, this.styleId);

  /// Produce a shallow merge of [parent] under [child]: child wins on every
  /// non-empty / non-null field; parent fills in the gaps. Used to implement
  /// `w:basedOn` inheritance.
  factory Styles.merged(Styles child, Styles parent) {
    final Styles out = Styles(
      child.name.isNotEmpty ? child.name : parent.name,
      child.type.isNotEmpty ? child.type : parent.type,
      child.styleId.isNotEmpty ? child.styleId : parent.styleId,
    )
      ..basedOnId = child.basedOnId
      ..firstLineInd =
          child.firstLineInd != 0 ? child.firstLineInd : parent.firstLineInd
      ..leftInd = child.leftInd != 0 ? child.leftInd : parent.leftInd
      ..fontSize = child.fontSize != 0 ? child.fontSize : parent.fontSize
      ..keepNext = child.keepNext ?? parent.keepNext
      ..keepLines = child.keepLines ?? parent.keepLines
      ..pageBreakBefore = child.pageBreakBefore ?? parent.pageBreakBefore
      ..spacingBefore =
          child.spacingBefore != 0 ? child.spacingBefore : parent.spacingBefore
      ..spacingAfter =
          child.spacingAfter != 0 ? child.spacingAfter : parent.spacingAfter
      ..outlineLvl =
          child.outlineLvl != 0 ? child.outlineLvl : parent.outlineLvl
      ..textColor = child.textColor ?? parent.textColor
      ..jc = child.jc ?? parent.jc;

    // Merge maps: child entries win, parent entries fill in.
    out.fonts = Map<String, String>.from(parent.fonts)
      ..addAll(child.fonts);
    out.tableBorder = Map<String, String>.from(parent.tableBorder)
      ..addAll(child.tableBorder);
    out.paraGraphBorder = Map<String, String>.from(parent.paraGraphBorder)
      ..addAll(child.paraGraphBorder);

    // Formats: union (preserving order, child first).
    final Set<String> seen = <String>{};
    out.formats = <String>[
      ...child.formats.where((String f) => seen.add(f)),
      ...parent.formats.where((String f) => seen.add(f)),
    ];

    // rowColStyles: child takes precedence; we keep child's entries plus
    // any parent entries whose applicableTo isn't overridden by child.
    final Set<String> childTypes = <String>{
      for (final RowColStyles r in child.rowColStyles) r.applicableTo,
    };
    out.rowColStyles = <RowColStyles>[
      ...child.rowColStyles,
      ...parent.rowColStyles
          .where((RowColStyles r) => !childTypes.contains(r.applicableTo)),
    ];
    return out;
  }
}

class RowColStyles {
  String applicableTo;
  int spacingBefore = 0;
  int spacingAfter = 0;
  int fontSize = 0;
  List<String> formats = [];
  String? textColor;
  String? cellFillColor;
  Map<String, String> cellBorder = {};
  Map<String, String> fonts = {};
  String? shadingColor;

  RowColStyles(this.applicableTo);
}
