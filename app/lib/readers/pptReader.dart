import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as sr;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:webview_all/webview_all.dart';

sr.Router createRouter(Uint8List fileBytes) {
  sr.Router router = sr.Router();
  router.get('/pptx/<path|.*>', (Request request) async {
    final segments = request.url.path.split('/');
    segments.remove('pptx');
    final relativePath = segments.join('/');
    final assetPath = relativePath.isEmpty ? 'index.html' : relativePath;

    try {
      final data = await rootBundle.load('assets/pptx/$assetPath');
      final bytes = data.buffer.asUint8List();
      return Response.ok(
        bytes,
        headers: {'content-type': _mimeType(assetPath)},
      );
    } catch (e) {
      return Response.notFound('Asset not found: $assetPath');
    }
  });
  router.get("/get_file", (Request request) {
    return Response.ok(
      fileBytes,
      headers: {'content-type': 'application/octet-stream'},
    );
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

Future<HttpServer> startAssetServer(Uint8List bytes) async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createRouter(bytes).call);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  debugPrint('Asset server running on http://localhost:${server.port}');
  return server;
}

class PptReaderPage extends StatelessWidget {
  const PptReaderPage({super.key, required this.fileBytes});
  final Uint8List fileBytes;

  @override
  Widget build(BuildContext context) {
    return PptReader(bytes: fileBytes);
  }
}

class PptReader extends StatefulWidget {
  const PptReader({super.key, required this.bytes});
  final Uint8List bytes;

  @override
  State<PptReader> createState() => _PptReaderState();
}

class _PptReaderState extends State<PptReader> {
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
    _server = await startAssetServer(widget.bytes);
    final url = 'http://localhost:${_server!.port}/pptx/index.html';

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PptReader',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('PptReader channel: ${message.message}');
        },
      )
      ..setOnConsoleMessage((message) {
        debugPrint('[JS ${message.level}] ${message.message}');
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
    _controller.releaseFocus();
    _controller.dispose();
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.requestFocus(),
      onExit: (_) => _controller.releaseFocus(),
      child: _serverReady
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1300),
                child: WebViewWidget(controller: _controller),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
