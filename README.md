# P's Books

A modern Flutter ebook reader and downloader with multi-format support, Google Drive sync, study tools, and an AI chat panel. Built as a Melos monorepo with reusable packages.

## Architecture

The project is structured as a **Melos monorepo** with a main app and 13 packages:

```
ps_books/
├── app/                          # Main Flutter application
│   └── lib/
│       ├── main.dart             # App entry point, routing, theme
│       ├── layout.dart           # Navigation layout (Rail on desktop, BottomNav on mobile)
│       ├── dbs/                  # Drift (SQLite) database schema and queries
│       ├── helpers/              # Book processing & file picking utilities
│       ├── models/               # Data models (BookData, DownloadBook, etc.)
│       ├── reader_utils/         # Reader theming, destinations, immersive mode
│       ├── readers/              # Reader engines for all supported formats
│       ├── routes/               # UI pages (Library, Bookshelf, Download, Study, Settings, Login)
│       ├── services/             # Business logic (download, auth, DB, study, audio, notifications)
│       └── state/                # Riverpod state management
└── packages/
    ├── comic_reader/             # CBR/CBZ comic reader widget
    ├── dart_pdf_reader/          # PDF reader widget
    ├── epub_pro/                 # EPUB reader engine
    ├── flutter_gen_ai_chat_ui/   # AI chat UI component
    ├── katbook_epub_reader/      # Alternative EPUB reader
    ├── kindle_unpack/            # MOBI/AZW3 unpacker & EPUB converter
    ├── microsoft_viewer/         # DOC/DOCX/PPT viewer
    ├── unrar/                    # RAR archive extraction
    ├── webview_all/              # Cross-platform WebView
    ├── webview_all_linux/        # Linux WebView implementation
    ├── webview_all_ohos/         # OpenHarmony WebView implementation
    ├── webview_all_web/          # Web WebView implementation
    └── webview_all_windows/      # Windows WebView implementation
```

### Architectural Breakdown 
The app directory contains the main reader application while the packages directory contains slightly customized third party packages.
## Features

### Supported Formats
- **EPUB** — via `epub_pro` and `katbook_epub_reader` packages
- **PDF** — via `dart_pdf_reader` and `pdfrx` engines
- **MOBI / AZW3** — via `kindle_unpack` with automatic EPUB conversion
- **FB2** — FictionBook format with XML parsing and cover extraction
- **CBR / CBZ / CBT / CBW** — Comic book archives
- **Microsoft formats** — DOC, DOCX, PPT via `microsoft_viewer`

### Library Management
- Grid-based book library with cover images and reading progress
- Filter books by collection
- Multi-select for batch operations
- Recently read / currently reading tracking
- Search and add books via file picker (Google Drive or local)

### Book Downloading
- **LibGen scraper** — Search and download from Library Genesis mirrors with rate-limit-aware batching and automatic MOBI-to-EPUB conversion
- **Standard Ebooks scraper** — Search and download DRM-free EPUBs from standardebooks.org
- Download progress tracking with cancel support
- Automatic metadata extraction and cover art generation on download

### Google Drive Sync
- Sign in with Google and browse Drive files
- Download books stored in a dedicated P's Books Drive folder
- Progress bar and automatic DB insertion on completion

### Study Tools
- **Timetable manager** — Create weekly timetables with subjects and sessions
- **Study targets** — Track topics and completion status per subject, with cloud sync via P's Books backend
- **Pomodoro timer** — Configurable focus/break cycles with audio cues, local notifications, and a floating desktop overlay inside the reader

### Reading Experience
- **Reader Shell** with slide-up AppBar and immersive fullscreen mode
- Split-screen reading (desktop): open a second book side-by-side
- AI Chat panel (desktop): ask questions about the book
- Bookmarks / table of contents drawer via destinations sheet
- Reader theme (light/dark) independent of app theme
- Reading progress auto-saved per book (page for PDF, CFI for EPUB)
- Dual-column page-turn detection for mobile (centre-tap exits immersive mode)

### Authentication
- Google OAuth for Drive integration
- P's Books account for study target cloud sync
- Session persistence via SharedPreferences

### AI Chat
- Integrated chat panel alongside the reader (desktop only)
- Powered by custom AI provider integration

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.11+ (Dart SDK ^3.11.0) |
| State Management | Riverpod (v3) + AsyncNotifier |
| Routing | go_router (v17) |
| Database | Drift (SQLite ORM with drift_flutter) |
| HTTP | Dio + http |
| PDF | pdfrx, dart_pdf_engine, pdf_renderer_bridge |
| EPUB | epub_pro, katbook_epub_reader |
| Google APIs | google_sign_in, googleapis (Drive v3) |
| Task Scheduling | workmanager + flutter_local_notifications |
| Architecture | Monorepo (Melos v8) |

## Getting Started

### Prerequisites
- Flutter SDK ^3.11.0
- Android Studio / Xcode (for mobile builds)
- Google Cloud Console project with Drive API enabled (for Google Drive features)

### Installation

```bash
# Clone the repository
git clone https://github.com/Perry-Cham/ps_books.git
cd ps_books

# Install Melos globally (if not already)
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run the app
cd app
flutter run
```

### Environment Configuration

Create `app/env.json` with your API keys:

```json
{
  "ai_api_key": "your-ai-provider-key",
  "ps_books_api_url": "https://your-backend-url"
}
```

## Database Schema

The local SQLite database (via Drift) includes these tables:
- **Books** — id, name, author, path, extension, page, cfi, progress, collection, lastRead, coverPath
- **Collections** — id, name, isSavedCollection
- **Timetables** / **TimetableDays** / **TimetableSessions** — weekly study schedule
- **TargetSubjects** / **TargetTopics** — study target tracking with UUID-based sync
- **SavedBooks** — wishlist/bookmark storage

## State Management

State is managed via Riverpod providers:

| Provider | Purpose |
|----------|---------|
| `settingsProvider` | App theme (light/dark), alarm preferences |
| `readerStateProvider` | Reading state, AI chat visibility, split reader |
| `LibraryStateProvider` | Multi-select, filters in library grid |
| `DownloadStateProvider` | Search results, download provider selection |
| `downloadProgressProvider` | Active download progress tracking |
| `pomodoroProvider` | Pomodoro timer state and control |
| `authServiceProvider` | Google Drive auth service singleton |
| `userAccountsProvider` | Google and P's Books user accounts |
| `driveBooksProvider` | Google Drive file listing |

## Copyright & Disclaimer

**This is an educational project.**
I do not own any of the books accessible through this application. Users are responsible for checking and complying with their local copyright laws. The developers of P's Books do not condone or encourage the illegal download of copyrighted material.
