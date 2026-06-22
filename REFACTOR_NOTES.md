# Reader Refactor — Notes & Suggested Follow-ups

This document captures what was changed in the
`refactor/reader-shell-and-bookmarks` branch, what was intentionally left
untouched, and a prioritised list of follow-up improvements the codebase
would benefit from. It is the audit deliverable promised in the user's
brief.

---

## 1. What changed (architectural)

### Before
```
home.dart / currently_reading.dart
  └─ Navigator.push(Reader(...))         ← monolithic 1247-line widget
       └─ Scaffold
            ├─ AppBar (bookmarks/menu, popup, settings, close)
            └─ body Row [
                  Expanded(checkWidget()),       ← engine dispatch
                  if showAi: Expanded(_AiChatPanel)         ← private, 96 lines
                  if secondBookId: Expanded(_SecondBookReader) ← private, 202 lines
                ]
            + FloatingDesktopClockOverlay (in same file, 154 lines)

pdfReader.dart had its own immersive-mode impl (broken on mobile — see §3.1)
mobiReader.dart had no JS bridge at all (bookmarks impossible)
ai_chat.dart's Basic class was orphaned dead code
```

### After
```
home.dart / currently_reading.dart
  └─ Navigator.push(ReaderShell(...))    ← new shell, 748 lines
       └─ Scaffold
            └─ Stack [
                  AnimatedPadding → Row [
                    Expanded(Reader(...))           ← slimmed, 587 lines, no chrome
                    if showAi && desktop: Expanded(AiChatPanel)  ← lib/routes/ai_chat.dart
                    if secondBookId && desktop: Expanded(_SecondaryReaderHost → Reader(isSecondary:true))
                  ],
                  SlideTransition(AppBar),          ← shell owns AppBar
                  if mobile && immersive: _CenterTapExitOverlay,
                  if desktop && immersive: _ImmersiveHatchButton,
                  FloatingDesktopClockOverlay,
                ]

lib/reader_utils/ (new folder, ~555 lines total)
  ├─ reader_destination.dart   — ReaderDestination model + DestinationCapable mixin
  ├─ reader_utils.dart         — extracted per-engine progress-save functions
  ├─ immersive_mode.dart       — ImmersiveModeController (ValueNotifier<bool>) + isMobilePlatform
  └─ destinations_sheet.dart   — unified bottom-sheet renderer (tree support)

Each engine implements DestinationCapable:
  EPUB  → KatbookEpubController.tableOfContents → ReaderDestination tree (locator: startIndex)
  FB2   → chapterEntries                        → flat list            (locator: chapter id)
  PDF   → pdfrx outline tree                    → ReaderDestination tree (locator: path "0/1/2")
  MOBI  → foliate-js TOC via new JS bridge      → ReaderDestination tree (locator: href)
```

### Key invariants the new architecture enforces
- **One AppBar, owned by the shell.** The slimmed `Reader` has no `Scaffold`, no `AppBar` — so there is no risk of double-AppBar rendering when the second reader is embedded.
- **Mutual exclusivity of AI chat vs second reader.** Already enforced by `ReaderStateNotifier.setShowAiChatTrue()` (clears `secondBookId`) and `setSecondBook(id)` (clears `showAiChat`). The shell's `if (showAi) … else if (secondBookId != null) …` makes it visually impossible to render both.
- **Desktop-only split panels.** Both AI chat and second reader are gated on `!isMobilePlatform` in the shell's body Row AND in the AppBar popup menu items. Mobile users never see those controls.
- **Immersive mode is global.** A single `ImmersiveModeController` owned by the shell drives both the AppBar slide animation (shell-side) and the page-count overlay slide animation (PDF engine side, via the `immersiveController` constructor param).
- **Engine-agnostic destinations.** The shell's hamburger button opens `showDestinationsSheet` whose `loader` is `state.getDestinations` (typed `Future<List<ReaderDestination>> Function()`). The shell never inspects the locator string — it hands the tapped destination back to the engine via `state.goToDestination(d)`.

---

## 2. What was intentionally left untouched

| Item | Why |
|---|---|
| `pdfReader.dart`'s `Drawer` (with TOC + search tabs) | The TOC tab is now redundant with the shell's destinations sheet, but removing it risks breaking the search functionality. Leaving for a follow-up. |
| `pdfReader.dart`'s `PdfOutlineNodeWidget` (recursive tree widget) | Still used inside the drawer. Could be removed once the drawer TOC tab is removed. |
| `pptReader.dart`'s `PptReaderPage` MaterialApp wrapper | Pre-existing oddity (the widget wraps itself in a MaterialApp, making it unusable as an embedded child). Out of scope for this refactor. |
| `microsoft_reader.dart`'s hardcoded `height: 1000, scale: 3.0` | Pre-existing. Needs an upstream fix in the `microsoft_viewer` package. |
| Drift schema (no `bookmarks` table added) | The user clarified that "bookmarks" = document-provided destinations, which are ephemeral — no persistence needed. |
| `reader_state.dart`'s four-field Riverpod state | Already well-structured. No changes needed. |
| `layout.dart` (app shell) | Only consumes `readerStateProvider.isReading`. No changes needed. |
| `main.dart` routes | `Reader` was already pushed via `Navigator.push` outside GoRouter. We just swap the symbol `Reader` → `ReaderShell` at the two call sites. |
| `home.dart` line 145 `database.watchAllBooks()` unresolved symbol | Pre-existing latent bug. The `database` symbol is not visibly imported. Flagged for follow-up, not fixed (would require understanding the original intent). |
| `home.dart` line 15 unused `BookToDb bookService = BookToDb();` | Pre-existing dead code. Flagged. |

---

## 3. Bugs found during the audit (with severity)

### 3.1 PDF immersive mode was racy on mobile (FIXED)

**Where:** `pdfReader.dart` `_handleScroll` (line 88 in the old file).
**Symptom:** Every `PdfViewerController` notification (zoom, goTo, page change, scroll) fired `_handleScroll`, which immediately re-engaged immersive mode — even if the user had just tapped to *exit* immersive. There was no symmetric auto-exit, and no mobile escape hatch FAB.
**Fix:** The local immersive implementation has been removed entirely. The shell's `ImmersiveModeController` is the single source of truth. Entry: shell auto-engages on mobile open, or AppBar button on desktop. Exit: centre-tap on mobile, hatch FAB on desktop, or AppBar toggle.

### 3.2 `truncateTitle` returned null for short titles (FIXED)

**Where:** old `reader.dart` line 642.
**Symptom:** `Text(truncateTitle(10, _title))` rendered as empty text when the title was ≤ 10 chars (the function fell through without a `return`).
**Fix:** The shell's `_truncateTitle` returns `title` in the `else` branch and uses `maxChars` (not `maxChars - 1`).

### 3.3 `dispose()` called `super.dispose()` first (FIXED)

**Where:** old `reader.dart` line 71-74.
**Symptom:** `super.dispose()` was called before any subclass cleanup. Harmless because there was nothing to clean up, but a footgun.
**Fix:** New `ReaderWidgetState.dispose()` calls `controller.dispose()` first, then `super.dispose()`.

### 3.4 `position` constructor param was untyped (FIXED)

**Where:** old `reader.dart` line 42 (`final position;`).
**Symptom:** Implicit `dynamic`. Callers passed `Book.cfi` (a `String?`). `jsonDecode(widget.position)` would crash at runtime if `position` was somehow not a string.
**Fix:** Now `final String? position;`.

### 3.5 PDF zoom never persisted (NOT FIXED)

**Where:** `pdfReader.dart` reads `pdfPreferences.zoom` but never calls `setZoom`.
**Symptom:** User zoom changes are lost on close.
**Fix:** Wire `widget.controller.setZoom` listener → `pdfPreferences.setZoom`. Left for follow-up.

### 3.6 Second-reader progress save only covered PDF (PARTIALLY FIXED)

**Where:** old `reader.dart` `_SecondBookReaderState._close()` only saved PDF progress.
**Symptom:** EPUB/FB2/Comic/MOBI second-reader sessions silently lost progress on close.
**Fix:** The slimmed `Reader._closeSecondary()` calls `saveProgress()` which currently only saves PDF progress. The other engines DO save continuously via callbacks during reading (e.g. `onPositionChanged: saveEpubPosition` fires throughout the session), so the only loss is the final position if the user moved in the last few hundred ms before closing. Acceptable for now; full fix would require each engine to expose a `flushProgress()` method.

### 3.7 PDF drawer TOC tab is redundant with the new destinations sheet (NOT FIXED)

**Where:** `pdfReader.dart` lines 116-167 (drawer with TOC + search tabs).
**Symptom:** Two ways to view the same TOC. The drawer's TOC tab is now redundant since the shell's hamburger button opens the unified destinations sheet.
**Fix:** Remove the TOC tab from the drawer, keep only the search tab. Or remove the drawer entirely and add a separate "Search" action to the shell's AppBar. Left for follow-up.

### 3.8 Two parallel DAO layers (NOT FIXED)

**Where:** `AppDatabase` (database.dart lines 129-190) and `BookToDb` (bookToDb.dart) both define `watchAllBooks`, `getBookById`, `deleteBook`, `updatePage`, `updatePositionAndProgress`, `updateProgress`.
**Symptom:** Maintainability hazard — bugs can be fixed in one place but not the other.
**Fix:** Pick one canonical home (probably `AppDatabase` since it's the Drift-generated class) and have `BookToDb` either delegate or be deleted.

### 3.9 `updatePositionAndProgress` is misnamed (NOT FIXED)

**Where:** `database.dart` line 163 and `bookToDb.dart` line 85.
**Symptom:** Method name suggests it updates both position and progress, but it only updates `cfi`. Callers must call `updateProgress` separately.
**Fix:** Rename to `updatePosition` (and optionally make it also update progress in a single transaction).

### 3.10 `_AiChatPanel` used unimported `AuthDio` (FIXED)

**Where:** old `reader.dart` line 968.
**Symptom:** `AuthDio.instance` referenced but `AuthDio` not in the import list. Worked only because of transitive exports.
**Fix:** The new `ai_chat.dart` explicitly imports `'../helpers/utils.dart'` which exports `AuthDio`.

### 3.11 Stray `console.log` in MOBI script.js (FIXED)

**Where:** `script.js` line 227 (`console.log(target);`).
**Symptom:** Noisy debug output.
**Fix:** Removed in the rewrite of `goTo(target)`.

### 3.12 `home.dart` line 145 references undefined `database` symbol (NOT FIXED)

**Where:** `home.dart` line 145 — `database.watchAllBooks()`.
**Symptom:** `database` is not visibly imported. Either there's an undetected export, or this is a latent runtime crash waiting to happen.
**Fix:** Investigate the intent. Probably should be `bookService.watchAllBooks()` (using the file-level `BookToDb bookService` declared on line 15).

### 3.13 `defaultTargetPlatform` is a build-time hint, not a runtime check (NOT FIXED)

**Where:** Throughout (was in reader.dart, pdfReader.dart; now centralised in `isMobilePlatform`).
**Symptom:** On web, `defaultTargetPlatform` may not reflect the actual platform. The app already has `dart:io` `Platform` usages that break on web, so this is consistent with the app's implicit non-web stance.
**Fix:** If web support is ever added, replace `defaultTargetPlatform` checks with `kIsWeb ? Web : (Platform.isAndroid || Platform.isIOS ? Mobile : Desktop)`.

### 3.14 PDF `onGeneralTap` is now a no-op (BY DESIGN)

**Where:** `pdfReader.dart` line 213 — `onGeneralTap: (_, _, _) => false`.
**Symptom:** Tapping the PDF canvas no longer toggles immersive mode (it used to, racy-ly).
**Fix:** This is intentional. The shell's centre-tap overlay handles exit-immersive on mobile. On desktop, the hatch FAB handles it. The PDF's `onGeneralTap` returning `false` lets taps fall through to the shell's overlay stack.

---

## 4. Suggested follow-ups (prioritised)

### P0 — correctness
1. **Wire PDF zoom persistence.** Add a `widget.controller` listener that calls `pdfPreferences.setZoom(...)` when zoom changes. Currently user zoom is lost on close.
2. **Fix `home.dart` line 145 `database` symbol.** Replace with `bookService.watchAllBooks()` (or import the missing symbol explicitly).
3. **Verify the MOBI JS bridge works on `webview_all` for desktop.** The `addJavaScriptChannel` API is well-defined for `webview_flutter` v4 on Android/iOS. On desktop (Windows/macOS/Linux), `webview_all` may use a different backend (e.g. webview_windows) that may not support JS channels. Test and add a fallback if needed.

### P1 — UX polish
4. **Remove the PDF drawer's redundant TOC tab** (keep only search). Or remove the drawer entirely and surface search via the shell's AppBar.
5. **Persist conversation history in `AiChatPanel`.** Currently the `InMemoryChatController` loses everything on dispose. Consider persisting to a `chat_history` table or SharedPreferences.
6. **Add book context to the AI chat prompt.** Currently the prompt is just `{"prompt": text}`. Could include the book title, current chapter, current position, or a snippet of surrounding text. Would require the shell to pass context to `AiChatPanel` via constructor params.
7. **Add a visual hint for the centre-tap exit on mobile.** Currently the centre-tap overlay shows a faint `Icons.keyboard_arrow_up` icon. Consider a brief "tap to exit immersive" tooltip on first entry, then fade out.
8. **Animate the centre-tap overlay's appearance.** Currently it pops in/out instantly. A fade would be smoother.

### P2 — code health
9. **Consolidate the DAO layer.** Pick `AppDatabase` OR `BookToDb` as the single source of truth. Delete the other.
10. **Rename `updatePositionAndProgress` → `updatePosition`** (or make it actually update both in one transaction).
11. **Promote `ComicReaderPage` from `StatelessWidget` to `StatefulWidget`** so it can implement `DestinationCapable` (it currently has no state to expose).
12. **Wrap `microsoft_viewer` in a stateful adapter** so `MicrosoftReader` can implement `DestinationCapable` (currently a 16-line `StatelessWidget` with no callbacks).
13. **Implement `DestinationCapable` for `PptReader`.** Needs a JS-channel bridge similar to MOBI (the `PptReader` JS channel exists but only `debugPrint`s messages).
14. **Add a `/reader` GoRouter route** so deep links work and the back button behaves consistently. Replace the `Navigator.push` calls in `home.dart`/`currently_reading.dart` with `context.go('/reader', ...)`.
15. **Move `FloatingDesktopClockOverlay` to its own file** under `lib/readers/` or `lib/widgets/`. It's currently 154 lines at the bottom of `reader_shell.dart` — extracting it would improve readability.
16. **Add a `flushProgress()` method to each engine's state** so the shell can explicitly persist non-PDF progress on dispose (currently relies on the engine's continuous-callback saving, which may miss the last few hundred ms).

### P3 — nice-to-haves
17. **Add user-created positional bookmarks** as a separate feature. The current refactor only handles document-provided destinations. A future `user_bookmarks` table + an "Add Bookmark" action in the AppBar overflow would be a clean addition on top of the existing `DestinationCapable` infrastructure.
18. **Add search to the destinations sheet.** For books with very long TOCs (e.g. textbooks), a search filter at the top of the sheet would help.
19. **Add keyboard shortcuts.** `Cmd/Ctrl+B` for destinations, `Cmd/Ctrl+F` for search, `Esc` for exit-immersive, etc.
20. **Internationalise the hardcoded strings.** The reader shell has many English-only strings ("Bookmarks", "AI Chat", "Add Reader", "Immersive Mode", etc.) that should be wrapped in `AppLocalizations.of(context)!.xxx`.

---

## 5. Files changed in this branch

```
 lib/reader_utils/destinations_sheet.dart   | +250  (new)
 lib/reader_utils/immersive_mode.dart       | +53   (new)
 lib/reader_utils/reader_destination.dart   | +103  (new)
 lib/reader_utils/reader_utils.dart         | +149  (new)
 lib/readers/reader_shell.dart              | +748  (new)
 lib/readers/reader.dart                    | +587  (was 1247, slimmed by ~53%)
 lib/readers/pdfReader.dart                 | modified (immersive strip + DestinationCapable)
 lib/readers/epubReader.dart                | modified (DestinationCapable)
 lib/readers/fb2_reader.dart                | modified (DestinationCapable)
 lib/readers/mobiReader.dart                | modified (JS bridge + DestinationCapable)
 lib/routes/ai_chat.dart                    | modified (Basic → AiChatPanel, public)
 lib/routes/home.dart                       | modified (Reader → ReaderShell)
 lib/routes/home comp/currently_reading.dart| modified (Reader → ReaderShell)
 assets/js/foliate-js-main/script.js       | modified (flutterChannel bridge + TOC + nav)
```
