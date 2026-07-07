import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility class for font and text direction handling
class FontHelper {
  /// Regular expression for detecting RTL characters (Arabic, Hebrew, etc.)
  static final RegExp _rtlRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0590-\u05FF\u07C0-\u07FF]',
  );

  /// Returns an appropriate font based on text content
  static TextStyle getAppropriateFont({
    required final String text,
    required final TextStyle? baseStyle,
  }) {
    if (isRTL(text)) {
      return GoogleFonts.notoSansArabic(
        textStyle: baseStyle,
        height: 1.5,
        letterSpacing: 0.5,
      );
    }

    return GoogleFonts.inter(
      textStyle: baseStyle,
      height: 1.4,
    );
  }

  /// Detects if text contains RTL characters
  static bool isRTL(String text) {
    if (text.isEmpty) return false;
    return _rtlRegex.hasMatch(text);
  }

  /// Returns the appropriate TextDirection based on text content
  static TextDirection getTextDirection(String text) {
    return isRTL(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns the appropriate TextAlign based on text content
  static TextAlign getTextAlign(String text) {
    return isRTL(text) ? TextAlign.right : TextAlign.left;
  }

  /// Returns the appropriate text alignment direction for a widget containing the text
  static Alignment getAlignment(String text) {
    return isRTL(text) ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Returns the appropriate cross axis alignment for a widget containing the text
  static CrossAxisAlignment getCrossAxisAlignment(String text) {
    return isRTL(text) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  /// Get effective direction considering both text content and app context
  static TextDirection getEffectiveDirection(
      String text, BuildContext context) {
    // If text has RTL characters, prefer that direction
    if (isRTL(text)) return TextDirection.rtl;

    // Otherwise use the app's direction
    return Directionality.of(context);
  }

  /// Returns the appropriate InputDecoration with RTL-aware settings
  /// without affecting the overall directionality
  static InputDecoration getInputDecorationWithRTL(
    InputDecoration baseDecoration,
    String text,
    BuildContext context,
  ) {
    final isRtlText = isRTL(text);
    final isRtlContext = Directionality.of(context) == TextDirection.rtl;

    // If either the text or context is RTL, adjust the decoration
    if (isRtlText || isRtlContext) {
      return baseDecoration.copyWith(
        alignLabelWithHint: true,
        hintTextDirection: isRtlText ? TextDirection.rtl : null,
      );
    }

    return baseDecoration;
  }
}
