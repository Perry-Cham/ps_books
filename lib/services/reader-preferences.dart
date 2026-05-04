import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pdfPreferences {
  final SharedPreferences prefs;
  static final String _zoomKey = 'zoom';

  pdfPreferences._({required this.prefs});

  static Future<pdfPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return pdfPreferences._(prefs: prefs);
  }

  double get zoom => prefs.getDouble(_zoomKey) ?? 1.0;
  Future<void> setZoom(double zoom) => prefs.setDouble(_zoomKey, zoom);
}

class epubPreferences {
  final SharedPreferences prefs;

  epubPreferences._({required this.prefs});

  static Future<epubPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return epubPreferences._(prefs: prefs);
  }

  String get readingMode => prefs.getString('readingMode') ?? 'page';
  ReadingMode getReadingMode() {
    String? mode = prefs.getString('readingMode');
    if (mode != null) {
      if (mode == "page") {
        return ReadingMode.page;
      } else {
        return ReadingMode.scroll;
      }
    } else {
      setReadingMode(ReadingMode.page);
      return ReadingMode.page;
    }
  }

  Future<void> setReadingMode(ReadingMode mode) {
    if (mode == ReadingMode.page) {
      return prefs.setString('readingMode', 'page');
    } else {
      return prefs.setString('readingMode', 'scroll');
    }
  }

  String get theme => prefs.getString('theme') ?? 'sepia';
  Future<void> setTheme(String theme) => prefs.setString('theme', theme);

  double get fontSize => prefs.getDouble('fontSize') ?? 16.0;
  Future<void> setFontSize(double fontSize) =>
      prefs.setDouble('fontSize', fontSize);
}

// providers/pdf_settings_provider.dart
final pdfPrefsProvider = FutureProvider<pdfPreferences>((ref) {
  return pdfPreferences.create();
});

// providers/epub_settings_provider.dart
final epubPrefsProvider = FutureProvider<epubPreferences>((ref) {
  return epubPreferences.create();
});
