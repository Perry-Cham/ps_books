import 'dart:convert';

import 'package:ps_books/services/DB%20services/bookToDb.dart';

/// Standalone helpers for persisting reading progress for each engine.
///
/// Pulled out of `lib/readers/reader.dart` so that:
///   - The slimmed `Reader` widget can call them without owning DB plumbing.
///   - The new `ReaderShell` can call them on the second reader's behalf.
///   - The MOBI reader can persist progress via the JS bridge without
///     duplicating logic.
///
/// Each function takes the [BookToDb] instance and the [bookId] explicitly
/// so callers can share a single DB handle (the existing top-level
/// `final _database = BookToDb();` in `reader.dart`).
///
/// All functions are fire-and-forget — they do not throw on DB errors, they
/// just log to `debugPrint`. Callers that need to await can, but should not
/// block the UI thread on DB writes.

final BookToDb _defaultDb = BookToDb();

/// Persist the current PDF page + computed progress fraction.
///
/// [page] is 1-based. [totalPages] is the document's total page count.
/// Progress is `page / totalPages` clamped to `[0, 1]`.
Future<void> savePdfProgress({
  required int bookId,
  required int? page,
  required int totalPages,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  final p = (page ?? 1).clamp(1, totalPages > 0 ? totalPages : 1);
  final progress = totalPages > 0 ? (p / totalPages).clamp(0.0, 1.0) : 0.0;
  await database.updatePage(bookId, p);
  await database.updateProgress(bookId, progress);
}

/// Persist the EPUB reading position as a JSON-encoded
/// `katbook_epub_reader` `ReadingPosition`.
///
/// [positionJson] should be the result of `jsonEncode(position.toJson())`
/// (the same shape `BookToDb.updatePositionAndProgress` writes to the `cfi`
/// column).
Future<void> saveEpubPosition({
  required int bookId,
  required String positionJson,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  await database.updatePositionAndProgress(bookId, positionJson);
}

/// Persist the EPUB reading-progress fraction (0..1) only.
Future<void> saveEpubProgress({
  required int bookId,
  required double progress,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  await database.updateProgress(bookId, progress.clamp(0.0, 1.0));
}

/// Persist a Comic page index (0-based input, stored 1-based) + progress.
Future<void> saveComicPage({
  required int bookId,
  required double page,
  int? totalPages,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  final stored = page.toInt() + 1;
  await database.updatePage(bookId, stored);
  if (totalPages != null && totalPages > 0) {
    final progress = (stored / totalPages).clamp(0.0, 1.0);
    await database.updateProgress(bookId, progress);
  }
}

/// Persist a Comic reading-progress fraction (0..1) only.
Future<void> saveComicProgress({
  required int bookId,
  required double progress,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  await database.updateProgress(bookId, progress.clamp(0.0, 1.0));
}

/// Persist an FB2 position (a flat list-index `int`) + progress fraction.
Future<void> saveFb2Progress({
  required int bookId,
  required int position,
  required double progress,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  await database.updatePositionAndProgress(bookId, position.toString());
  await database.updateProgress(bookId, progress.clamp(0.0, 1.0));
}

/// Persist a MOBI / AZW3 CFI locator (foliate-js CFI string) + progress.
///
/// The MOBI engine calls this from the `relocate` JS-channel handler. The
/// CFI is stored in the same `cfi` column EPUB uses (the engines are
/// interchangeable for restore purposes).
Future<void> saveMobiProgress({
  required int bookId,
  required String? cfi,
  required double progress,
  BookToDb? db,
}) async {
  final database = db ?? _defaultDb;
  if (cfi != null && cfi.isNotEmpty) {
    await database.updatePositionAndProgress(bookId, cfi);
  }
  await database.updateProgress(bookId, progress.clamp(0.0, 1.0));
}

/// Helper: encode a `ReadingPosition`-like JSON string from a raw map.
///
/// Used by the EPUB engine to serialise `katbook_epub_reader`'s
/// `ReadingPosition` for [saveEpubPosition] without each caller needing to
/// import `dart:convert`.
String encodePositionJson(Map<String, dynamic> json) => jsonEncode(json);

/// Helper: decode a stored position string back into a `Map`.
///
/// Returns `null` if [stored] is null or empty or not valid JSON.
Map<String, dynamic>? decodePositionJson(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  try {
    final decoded = jsonDecode(stored);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {
    // fallthrough
  }
  return null;
}

/// Helper: decode a stored FB2 position (an int serialised as a string).
///
/// Returns `null` if [stored] is null or not parseable as int.
int? decodeFb2Position(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  return int.tryParse(stored);
}
