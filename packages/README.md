# Packages

This directory contains the local packages used by **P's Books**. They are kept
in-repo rather than published to pub.dev because the project necessitated
modifications to each package to meet its specific requirements — a common
pattern when the upstream package doesn't perfectly align with the app's
design. This approach makes iterating and fixing issues much faster, albeit at
the cost of a larger repository size.

## Dart / Flutter packages

| Package | Description |
|---------|-------------|
| **comic_reader** | Widget for reading CBR / CBZ / CBT / CBW comic-book archives. Provides a scrollable/page-based viewer with touch and keyboard navigation. |
| **dart_pdf_reader** | Pure-Dart PDF parser — reads PDF structure, extracts text, images, and metadata. Used as a lightweight alternative to platform-native PDF engines. |
| **epub_pro** | EPUB reader engine — parses the EPUB container (OPF, NCX, navigation documents) and provides chapter-by-chapter content access. |
| **flutter_download_manager** | General-purpose download manager with queue support, progress callbacks, and pause/resume functionality. |
| **flutter_gen_ai_chat_ui** | Reusable AI chat UI component with streaming message rendering, markdown support, and code highlighting. |
| **JS packages** | JavaScript build workspace — contains the source files for the three JS libraries used by the WebView-based readers (see its own README). |
| **katbook_epub_reader** | Full-featured EPUB reader widget with pagination, scrolling, themes, font controls, TOC navigation, and reading-position persistence. The primary EPUB engine used in the app. |
| **kindle_unpack** | MOBI / AZW3 / AZW unpacker that extracts the raw content and converts it to a structured EPUB-like representation for rendering. |
| **unrar** | RAR archive extraction via `dart:ffi` — wraps the native unrar C++ library for extracting CBR comic-book archives on desktop and mobile. |
| **webview_all** | Cross-platform abstraction over the platform's WebView. Provides a unified `WebViewController` / `WebViewWidget` API similar to `webview_flutter` but with broader platform support (Linux, OpenHarmony). |
| **webview_all_linux** | Linux implementation of `webview_all` using WebKitGTK. |
| **webview_all_ohos** | OpenHarmony implementation of `webview_all`. |
| **webview_all_web** | Web implementation of `webview_all` using the browser's native iframe/WebView. |
| **webview_all_windows** | Windows implementation of `webview_all` using WebView2. |

## Why local packages?

All of the packages above were either:

- **Forked or modified** from their upstream pub.dev equivalents to fix bugs,
  add features, or adapt to P's Books' specific architecture (e.g., custom
  theming, split-screen support, unique file-handling patterns).
- **Written from scratch** because no suitable pub.dev package existed for the
  project's needs (e.g., `comic_reader`, `kindle_unpack`).

By keeping them in-repo, we avoid the overhead of maintaining separate
repositories, publishing cycles, and version-matching across forks. The tradeoff
is increased repository size and the need to manually sync any upstream changes
when desired.

## Building JS assets

See `JS packages/README.md` for instructions on building the JavaScript
bundles used by the WebView-based readers (pptx, docx, foliate-js).
