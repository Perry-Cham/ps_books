import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as sr;
import 'package:webview_all/webview_all.dart';

import 'package:ps_books/services/DB%20services/bookToDb.dart';

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
  State<MobireaderPage> createState() => _MobireaderPageState();
}

class _MobireaderPageState extends State<MobireaderPage> {
  late final WebViewController _controller;
  HttpServer? _server;
  int _progress = 0;
  bool _serverReady = false;

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

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _serverReady
        ? WebViewWidget(controller: _controller)
        : const Center(child: CircularProgressIndicator());
  }
}
