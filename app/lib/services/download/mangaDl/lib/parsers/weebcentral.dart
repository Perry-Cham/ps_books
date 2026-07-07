// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/parsers/weebcentral.dart — WeebCentral parser.
//
// Direct port of `src/parsers/weebcentral.js` from the Node.js version.
// The HTML selectors, the htmx-aware endpoints, the chapter-list
// fallback to the /full-chapter-list endpoint — all identical to the
// JS version. The only differences are language-level:
//
//   - cheerio → package:html
//   - URLSearchParams → Uri.encodeComponent + manual join
//   - fetch() → http.post() / http.get()
//   - module-level functions → static methods on the parser class
//
// We keep the same Cloudflare limitation: Dart's HttpClient has the
// same TLS-fingerprint issue as Node's undici, so live requests to
// WeebCentral will return 403 with the "Just a moment…" challenge.
// The parser logic is verified by the offline tests.
// -----------------------------------------------------------------------------

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'base.dart';

const String _kBaseUrl = 'https://weebcentral.com';

const String _kUserAgent =
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Safari/537.36';

class WeebCentralParser extends BaseParser {
  @override
  String get key => 'weebcentral';

  @override
  String get displayName => 'Weeb Central';

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final html = await _postForm(
      '$_kBaseUrl/search/simple?location=main',
      {'text': query},
      _kBaseUrl,
    );
    return parseSearchResults(html);
  }

  @override
  Future<List<ChapterInfo>> getChapters(MangaSearchResult manga) async {
    // The series detail page only shows ~9 chapters. The "Show All
    // Chapters" button hits a separate htmx endpoint that returns
    // every chapter in one fragment. We call that endpoint directly.
    //
    // manga.detailUrl is like:
    //   https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece
    // We strip the slug and append /full-chapter-list.
    final base = manga.detailUrl.replaceAll(RegExp(r'/[^/]+$'), '');
    final url = '$base/full-chapter-list';
    final html = await _httpGet(url, referer: manga.detailUrl, extraHeaders: {
      'HX-Request': 'true',
    });
    return parseChapterList(html);
  }

  @override
  Future<List<String>> getChapterImages(ChapterInfo chapter) async {
    final url =
        '${chapter.chapterUrl}/images?is_prev=False&current_page=1&reading_style=single_page';
    final html = await _httpGet(url, referer: chapter.chapterUrl, extraHeaders: {
      'HX-Request': 'true',
      'HX-Current-URL': chapter.chapterUrl,
      'HX-Target': 'last-chapter-top',
    });
    return parseChapterImageList(html);
  }
}

// ---------------------------------------------------------------------------
// HTTP helpers — ported from src/utils/http.js. We keep them file-local
// (not in a separate utils file) because Flutter apps typically use
// package:http directly; extracting a wrapper would be over-engineering
// for a learning project.
// ---------------------------------------------------------------------------

const Map<String, String> _kDefaultHeaders = {
  'User-Agent': _kUserAgent,
  'Accept-Language': 'en-US,en;q=0.9',
  'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
};

Future<String> _httpGet(
  String url, {
  String? referer,
  Map<String, String>? extraHeaders,
}) async {
  final headers = Map<String, String>.from(_kDefaultHeaders);
  if (referer != null) headers['Referer'] = referer;
  if (extraHeaders != null) headers.addAll(extraHeaders);

  final res = await http.get(Uri.parse(url), headers: headers);

  if (res.statusCode == 403) {
    final body = res.body;
    if (body.contains('Just a moment') || body.contains('cf-challenge')) {
      throw CloudflareException(url);
    }
    throw Exception('GET $url returned HTTP 403');
  }
  if (res.statusCode != 200) {
    throw Exception('GET $url returned HTTP ${res.statusCode}');
  }
  return res.body;
}

Future<String> _postForm(
  String url,
  Map<String, String> fields,
  String referer,
) async {
  final body = fields.entries
      .map((e) =>
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  final headers = {
    'User-Agent': _kUserAgent,
    'Content-Type': 'application/x-www-form-urlencoded',
    'HX-Request': 'true',
    'Referer': referer,
    'Origin': Uri.parse(referer).origin,
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  final res = await http.post(Uri.parse(url), headers: headers, body: body);

  if (res.statusCode == 403) {
    final responseBody = res.body;
    if (responseBody.contains('Just a moment') ||
        responseBody.contains('cf-challenge')) {
      throw CloudflareException(url);
    }
    throw Exception('POST $url returned HTTP 403');
  }
  if (res.statusCode != 200) {
    throw Exception('POST $url returned HTTP ${res.statusCode}');
  }
  return res.body;
}

/// Thrown when WeebCentral returns a Cloudflare JavaScript challenge
/// page. The Dart HttpClient can't pass Cloudflare bot detection —
/// same limitation as Node's fetch in the JS version.
class CloudflareException implements Exception {
  final String url;
  CloudflareException(this.url);

  @override
  String toString() =>
      'Cloudflare bot-detection challenge at $url. Dart/Flutter HTTP '
      'clients cannot pass Cloudflare. Use a Cloudflare-bypassing tool '
      '(FlareSolverr, Playwright, curl-impersonate) for live access.';
}

// ---------------------------------------------------------------------------
// HTML parsers — pure functions, exported for unit testing.
// ---------------------------------------------------------------------------

/// Parse a search-results HTML fragment.
/// Mirrors parseSearchResults in weebcentral.js.
List<MangaSearchResult> parseSearchResults(String html) {
  final doc = html_parser.parse(html);
  final results = <MangaSearchResult>[];

  for (final a in doc.querySelectorAll('a[href^="$_kBaseUrl/series/"]')) {
    final href = a.attributes['href'];
    if (href == null) continue;

    final match = RegExp(r'/series/([^/]+)(?:/(.+))?').firstMatch(href);
    if (match == null) continue;
    final id = match.group(1)!;

    // Cover image: prefer <img src>, fall back to <source srcset>.
    final img = a.querySelector('img');
    final source = a.querySelector('source');
    final coverUrl = img?.attributes['src'] ??
        source?.attributes['srcset'] ??
        '';

    // Title: the longest non-empty text line inside <a>.
    // The site wraps the title in a <div>, but cheerio's .text()
    // flattens nested tags — so we just take the longest line.
    String title = '';
    final allText = a.text
        .trim()
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (allText.isNotEmpty) {
      title = allText.reduce((x, y) => x.length >= y.length ? x : y);
    }
    if (title.isEmpty) {
      final alt = img?.attributes['alt'];
      if (alt != null) {
        title = alt.replaceAll(RegExp(r' cover$'), '');
      }
    }
    if (title.isEmpty) continue;

    results.add(MangaSearchResult(
      id: id,
      title: title,
      coverUrl: coverUrl,
      detailUrl: href,
    ));
  }
  return results;
}

/// Parse a chapter-list HTML fragment (either the partial preview
/// from the series page, or the full list from the htmx endpoint).
/// Mirrors parseChapterList in weebcentral.js.
List<ChapterInfo> parseChapterList(String html) {
  final doc = html_parser.parse(html);
  final chapters = <ChapterInfo>[];

  // Try the scoped selector first; fall back to all chapter links.
  var links = doc.querySelectorAll('#chapter-list a[href^="$_kBaseUrl/chapters/"]');
  if (links.isEmpty) {
    links = doc.querySelectorAll('a[href^="$_kBaseUrl/chapters/"]');
  }

  for (final a in links) {
    final href = a.attributes['href'];
    if (href == null) continue;

    final match = RegExp(r'/chapters/([^/?#]+)').firstMatch(href);
    if (match == null) continue;
    final id = match.group(1)!;

    // Find the leaf <span> whose text is exactly "Chapter N".
    // See the JS version for the long explanation of why we need
    // an exact-match regex (to skip wrapper spans whose .text()
    // concatenates child text).
    String label = '';
    for (final span in a.querySelectorAll('span')) {
      final txt = span.text.trim();
      if (RegExp(r'^Chapter\s+\S+$').hasMatch(txt)) {
        label = txt;
        break;
      }
    }
    if (label.isEmpty) {
      for (final span in a.querySelectorAll('span')) {
        final txt = span.text.trim();
        final m = RegExp(r'^Chapter\s+\S+').firstMatch(txt);
        if (m != null) {
          label = m.group(0)!;
          break;
        }
      }
    }
    if (label.isEmpty) {
      label = a.text.trim().split('\n').first;
    }

    final time = a.querySelector('time');
    final publishedAt = time?.attributes['datetime'];

    chapters.add(ChapterInfo(
      id: id,
      label: label,
      chapterUrl: href,
      publishedAt: publishedAt,
    ));
  }

  // WeebCentral lists newest first; we want ascending.
  return chapters.reversed.toList();
}

/// Parse a chapter-images HTML fragment.
/// Mirrors parseChapterImageList in weebcentral.js.
List<String> parseChapterImageList(String html) {
  final doc = html_parser.parse(html);
  final urls = <String>[];
  for (final img in doc.querySelectorAll('section img')) {
    final src = img.attributes['src'];
    if (src != null && !src.startsWith('/static/')) {
      urls.add(src);
    }
  }
  return urls;
}
