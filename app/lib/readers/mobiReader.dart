import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as sr;
import 'package:webview_all/webview_all.dart';

import 'package:ps_books/reader_utils/reader_destination.dart';
import 'package:ps_books/reader_utils/reader_utils.dart';
import 'package:ps_books/reader_utils/theme.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';

final _database = BookToDb();

// ---------------------------------------------------------------------------
// Asset server
// ---------------------------------------------------------------------------

sr.Router _createRouter(Uint8List fileBytes, String? position) {
  sr.Router router = sr.Router();

  router.get('/get_file', (Request request) {
    return Response.ok(
      fileBytes,
      headers: {'content-type': 'application/octet-stream'},
    );
  });

  router.get('/get_position', (Request request) {
    return Response.ok(
      jsonEncode({'cfi': position}),
      headers: {'content-type': 'application/json'},
    );
  });

  router.get('/<path|.*>', (Request request) async {
    final path = request.url.path;
    final assetPath = path.isEmpty ? 'mobi.html' : path;
    try {
      final data = await rootBundle.load('assets/$assetPath');
      final bytes = data.buffer.asUint8List();
      return Response.ok(
        bytes,
        headers: {'content-type': _mimeType(assetPath)},
      );
    } catch (e) {
      return Response.notFound('Asset not found: $assetPath');
    }
  });

  return router;
}

String _mimeType(String path) {
  if (path.endsWith('.html')) return 'text/html';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg')) return 'image/jpeg';
  return 'application/octet-stream';
}

Future<HttpServer> _startAssetServer(Uint8List bytes, String? position) async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_createRouter(bytes, position).call);

  final server = await shelf_io.serve(handler, 'localhost', 0);
  debugPrint('Asset server running on http://localhost:${server.port}');
  return server;
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MobireaderPage extends StatefulWidget {
  const MobireaderPage({
    super.key,
    required this.bytes,
    required this.id,
    this.position,
  });

  final Uint8List bytes;
  final int id;
  final String? position;

  @override
  State<MobireaderPage> createState() => MobireaderPageState();
}

class MobireaderPageState extends State<MobireaderPage>
    implements DestinationCapable {
  late final WebViewController _controller;
  HttpServer? _server;
  int _progress = 0;
  bool _serverReady = false;

  /// Latest CFI received from the JS `relocate` event. Used as a best-effort
  /// fallback for [goToDestination] state and as the source of truth for
  /// dispose-time persistence.
  String? _lastCfi;

  /// Latest progress fraction (0..1) received from the JS `relocate` event.
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _startServerAndLoad();
  }

  Future<void> _startServerAndLoad() async {
    if (kIsWeb) {
      _controller.loadRequest(Uri.parse('assets/js/foliate-js-main/mobi.html'));
      if (mounted) setState(() => _serverReady = true);
      return;
    }

    _server = await _startAssetServer(widget.bytes, widget.position);
    final url =
        'http://localhost:${_server!.port}/js/foliate-js-main/mobi.html';

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        debugPrint('[MOBI JS ${message.level}] ${message.message}');
      })
      // Register the JS→Flutter channel. Flutter injects a global
      // `window.flutterChannel` object whose `.postMessage(string)` is
      // forwarded to [onMessageReceived]. The JS side uses this for
      // `relocate` events so we can persist reading position.
      ..addJavaScriptChannel(
        'flutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleFlutterChannelMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (String url) {
            debugPrint('Loading $url');
          },
          onPageFinished: (String url) {
            debugPrint('Finished $url');
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error ${error.errorCode}: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    if (mounted) setState(() => _serverReady = true);
  }

  // -------------------------------------------------------------------------
  // JS → Flutter channel handler
  // -------------------------------------------------------------------------

  void _handleFlutterChannelMessage(String raw) {
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('MOBI: failed to decode flutterChannel message: $e');
      return;
    }
    final type = data['type'] as String?;
    switch (type) {
      case 'relocate':
        final cfi = data['cfi'] as String?;
        final fraction = (data['fraction'] as num?)?.toDouble() ?? 0.0;
        _lastCfi = cfi;
        _lastProgress = fraction;
        // Persist position + progress on every relocate event.
        unawaited(
          saveMobiProgress(
            bookId: widget.id,
            cfi: cfi,
            progress: fraction,
          ).catchError((e) {
            debugPrint('MOBI saveMobiProgress failed: $e');
          }),
        );
        break;
      default:
        debugPrint('MOBI: unknown flutterChannel message type=$type');
    }
  }

  // -------------------------------------------------------------------------
  // Theme support
  // -------------------------------------------------------------------------

  void setTheme(ReaderTheme theme) {
    if (!_serverReady) return;
    final themeName = theme == ReaderTheme.dark
        ? 'dark'
        : theme == ReaderTheme.sepia
        ? 'sepia'
        : 'light';
    _controller.runJavaScript('window.mobiReader.setTheme("$themeName")');
  }

  // -------------------------------------------------------------------------
  // DestinationCapable — lingua franca for the reader shell
  // -------------------------------------------------------------------------

  @override
  Future<List<ReaderDestination>> getDestinations() async {
    if (!_serverReady || kIsWeb) return const [];
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'window.mobiReader.getDestinationsJSON()',
      );
      // `runJavaScriptReturningResult` semantics vary across webview versions:
      //   - v4+ returns the JS value already deserialised to a Dart type
      //     (List/Map/String/num/bool/null).
      //   - older versions (and some webview_all paths) return the value as a
      //     JSON-encoded String (so a returned string `"foo"` comes back as
      //     `"\"foo\""`).
      // The JS function returns a JSON string, so we normalise to a String
      // first and then jsonDecode that String into a List.
      String jsonStr;
      if (result is String) {
        if (result.trim().startsWith('"')) {
          // JSON-encoded string — decode once to get the inner JSON string.
          jsonStr = jsonDecode(result) as String;
        } else {
          jsonStr = result;
        }
      } else if (result is List) {
        // Already deserialised — re-encode so we can use the same parser.
        jsonStr = jsonEncode(result);
      } else {
        debugPrint(
          'MOBI getDestinations: unexpected result type ${result.runtimeType}',
        );
        return const [];
      }
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => _destinationFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('MOBI getDestinations failed: $e');
      return const [];
    }
  }

  static ReaderDestination _destinationFromJson(Map<String, dynamic> json) {
    return ReaderDestination(
      label: (json['label'] as String?) ?? '(untitled)',
      locator: (json['locator'] as String?) ?? '',
      level: (json['level'] as int?) ?? 0,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((c) => _destinationFromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  Future<void> goToDestination(ReaderDestination destination) async {
    if (!_serverReady || kIsWeb) return;
    try {
      // jsonEncode the locator to safely escape it as a JS string literal.
      await _controller.runJavaScript(
        'window.mobiReader.goToDestinationByLocator(${jsonEncode(destination.locator)})',
      );
    } catch (e) {
      debugPrint('MOBI goToDestination failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    // Best-effort persist of the latest known position. The webview is being
    // torn down synchronously so we cannot await further JS calls; the
    // `_lastCfi` cached from the last `relocate` event is the source of truth.
    if (_lastCfi != null && _lastCfi!.isNotEmpty) {
      unawaited(
        saveMobiProgress(
          bookId: widget.id,
          cfi: _lastCfi,
          progress: _lastProgress,
        ).catchError((_) {}),
      );
    }
    _controller.releaseFocus();
    _controller.dispose();
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _controller.requestFocus();
        } else {
          _controller.releaseFocus();
        }
      },
      child: _serverReady
          ? WebViewWidget(controller: _controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
