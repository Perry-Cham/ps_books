import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/timetable.dart' as tt_model;
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/services/dbServices/notesToDB.dart';
import 'package:ps_books/services/dbServices/target.dart';
import 'package:ps_books/services/dbServices/timetableToDB.dart';
import 'package:ps_books/routes/studyRouteComp/timetable.dart' as tt;

class DataHandler {
  final _bookToDb = BookToDb();
  final _notesToDb = NotesToDB();
  final _targetService = TargetService();
  final _timetableToDb = TimetableToDb();

  // ── Simple book export (original behavior, copies files directly) ──

  Future<bool> exportBooks() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${docsPath.path}/Books');
    final books = await docsDir.list().toList();

    final selectedDirectoryUri = await FilePicker.platform.getDirectoryPath();
    if (books.isEmpty) return false;
    if (selectedDirectoryUri == null) return false;

    try {
      for (final book in books) {
        final bookFile = File(book.path);
        await bookFile.copy(
          '$selectedDirectoryUri/${bookFile.path.split(Platform.pathSeparator).last}',
        );
      }
      return true;
    } catch (e) {
      print('Failed to export book: $e');
      return false;
    }
  }

  // ── Full .pbf export ──

  Future<bool> exportPBF() async {
    return _exportToPBF(
      includeBooks: true,
      includeTimetable: true,
      includeTargets: true,
      includeNotes: true,
      includeSavedBooks: true,
    );
  }

  Future<bool> exportTimetable() async {
    return _exportToPBF(includeTimetable: true);
  }

  Future<bool> exportTargets() async {
    return _exportToPBF(includeTargets: true);
  }

  Future<bool> exportNotes() async {
    return _exportToPBF(includeNotes: true);
  }

  // ── Import from .pbf ──

  Future<bool> importPBF(String filePath) async {
    if (!filePath.endsWith('.pbf')) return false;

    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory('${tempDir.path}/Data_import');

    try {
      if (extractDir.existsSync()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final entry in archive) {
        if (entry.isFile) {
          final outPath = p.join(extractDir.path, entry.name);
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(entry.content as List<int>);
        }
      }

      final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
      if (!manifestFile.existsSync()) return false;

      final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;

      if (manifest['Books'] != null) {
        await _importBooks(manifest['Books'] as String, extractDir.path);
      }
      if (manifest['Timetable'] != null) {
        await _importTimetable(manifest['Timetable'] as String, extractDir.path);
      }
      if (manifest['Notes'] != null) {
        await _importNotes(manifest['Notes'] as String, extractDir.path);
      }
      if (manifest['Targets'] != null) {
        await _importTargets(manifest['Targets'] as String, extractDir.path);
      }
      if (manifest['Wishlist'] != null) {
        await _importSavedBooks(manifest['Wishlist'] as String, extractDir.path);
      }

      await extractDir.delete(recursive: true);
      return true;
    } catch (e, st) {
      print('Import failed: $e');
      print(st);
      if (extractDir.existsSync()) {
        await extractDir.delete(recursive: true);
      }
      return false;
    }
  }

  // ── Core export logic ──

  Future<bool> _exportToPBF({
    bool includeBooks = false,
    bool includeTimetable = false,
    bool includeTargets = false,
    bool includeNotes = false,
    bool includeSavedBooks = false,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final dataDir = Directory('${tempDir.path}/Data');
    final booksDir = Directory('${dataDir.path}/books');
    final coversDir = Directory('${booksDir.path}/covers');
    final dataSubDir = Directory('${dataDir.path}/data');

    try {
      if (dataDir.existsSync()) {
        await dataDir.delete(recursive: true);
      }
      await coversDir.create(recursive: true);
      await dataSubDir.create(recursive: true);

      final manifest = <String, dynamic>{
        'Books': null,
        'Timetable': null,
        'Notes': null,
        'Targets': null,
        'Wishlist': null,
      };

      if (includeBooks) {
        await _exportBooksData(dataDir, booksDir, coversDir, manifest);
      }

      if (includeTimetable) {
        await _exportTimetableData(dataSubDir, manifest);
      }

      if (includeTargets) {
        await _exportTargetsData(dataSubDir, manifest);
      }

      if (includeNotes) {
        await _exportNotesData(dataSubDir, manifest);
      }

      if (includeSavedBooks) {
        await _exportSavedBooksData(dataSubDir, manifest);
      }

      // ── Manifest ──
      final manifestFile = File(p.join(dataDir.path, 'manifest.json'));
      await manifestFile.writeAsString(jsonEncode(manifest));

      // ── Create archive ──
      final selectedDir = await FilePicker.platform.getDirectoryPath();
      if (selectedDir == null) {
        await dataDir.delete(recursive: true);
        return false;
      }

      final archivePath = p.join(selectedDir, 'Data.pbf');
      final archive = Archive();
      await _addDirectoryToArchive(archive, dataDir, dataDir.path);

      final encoded = ZipEncoder().encode(archive);
      await File(archivePath).writeAsBytes(encoded);

      // ── Cleanup ──
      await dataDir.delete(recursive: true);
      return true;
    } catch (e, st) {
      print('Export failed: $e');
      print(st);
      if (dataDir.existsSync()) {
        await dataDir.delete(recursive: true);
      }
      return false;
    }
  }

  // ── Private export helpers ──

  Future<void> _exportBooksData(Directory dataDir, Directory booksDir, Directory coversDir, Map<String, dynamic> manifest) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final supportPath = await getApplicationSupportDirectory();

    final appBooksDir = Directory('${docsPath.path}/Books');
    final appCoversDir = Directory('${supportPath.path}/Covers');

    if (await appBooksDir.exists()) {
      await for (final entry in appBooksDir.list()) {
        if (entry is File) {
          final destPath = p.join(booksDir.path, p.basename(entry.path));
          await entry.copy(destPath);
        }
      }
    }

    if (await appCoversDir.exists()) {
      await for (final entry in appCoversDir.list()) {
        if (entry is File) {
          final destPath = p.join(coversDir.path, p.basename(entry.path));
          await entry.copy(destPath);
        }
      }
    }

    final allBooks = await _bookToDb.getAllBooks();
    final allCollections = await _bookToDb.getAllCollections();
    final allSeries = await _bookToDb.getAllSeries();

    final booksJson = allBooks.map((b) {
      return {
        'name': b.name,
        'author': b.author,
        'path': 'books/${p.basename(b.path)}',
        'extension': b.extension,
        'progress': b.progress,
        'page': b.page,
        'cfi': b.cfi,
        'coverPath': b.coverPath != null ? 'books/covers/${p.basename(b.coverPath!)}' : null,
        'lastRead': b.lastRead,
        'collection': b.collection,
        'series': b.series,
        'isSeries': b.isSeries,
      };
    }).toList();

    final collectionsJson = allCollections.map((c) {
      return {
        'id': c.id,
        'name': c.name,
        'isSavedCollection': c.isSavedCollection,
      };
    }).toList();

    final seriesJson = allSeries.map((s) {
      return {
        'id': s.id,
        'name': s.name,
        'cover': s.cover,
        'description': s.description,
        'collection': s.collection,
      };
    }).toList();

    final booksFile = File(p.join(booksDir.path, 'books.json'));
    await booksFile.writeAsString(jsonEncode({
      'books': booksJson,
      'collections': collectionsJson,
      'series': seriesJson,
    }));

    manifest['Books'] = 'books/books.json';
  }

  Future<void> _exportTimetableData(Directory dataSubDir, Map<String, dynamic> manifest) async {
    final t = await _timetableToDb.getTimetableRecord();
    if (t == null) return;

    final currentData = await _timetableToDb.getTimeTable().first;
    final timetableModel = tt_model.TimetableModel(
      version: t.version,
      lastModified: t.lastModified,
      days: currentData.map((entry) {
        return tt_model.DayData(
          day: entry.day.day,
          isBreakDay: entry.day.isBreakDay,
          sessions: entry.session.map((s) {
            return tt_model.SessionData(
              start: s.start,
              end: s.end,
              subjects: s.subjects,
            );
          }).toList(),
        );
      }).toList(),
    );

    final file = File(p.join(dataSubDir.path, 'timetable.json'));
    await file.writeAsString(jsonEncode(timetableModel.toJson()));
    manifest['Timetable'] = 'data/timetable.json';
  }

  Future<void> _exportTargetsData(Directory dataSubDir, Map<String, dynamic> manifest) async {
    final subjects = await _targetService.getAllSubjects();
    if (subjects.isEmpty) return;

    final List<Map<String, dynamic>> subjectsJson = [];
    for (final subject in subjects) {
      final topics = await _targetService.getTopicsForSubject(subject.id);

      subjectsJson.add({
        'uuid': subject.uuid,
        'name': subject.name,
        'syncedAt': subject.syncedAt?.toIso8601String(),
        'topics': topics.map((t) => {
          'uuid': t.uuid,
          'name': t.name,
          'isCompleted': t.isCompleted,
          'lastModified': t.lastModified.toIso8601String(),
        }).toList(),
      });
    }

    final file = File(p.join(dataSubDir.path, 'targets.json'));
    await file.writeAsString(jsonEncode({'subjects': subjectsJson}));
    manifest['Targets'] = 'data/targets.json';
  }

  Future<void> _exportNotesData(Directory dataSubDir, Map<String, dynamic> manifest) async {
    final allNotes = await _notesToDb.getAllNotesList();
    if (allNotes.isEmpty) return;

    final notesJson = allNotes.map((n) {
      return {
        'uuid': n.uuid,
        'title': n.title,
        'content': n.content,
        'lastModified': n.lastModified.toIso8601String(),
        'bookId': n.bookId,
        'collection': n.collection,
      };
    }).toList();

    final file = File(p.join(dataSubDir.path, 'notes.json'));
    await file.writeAsString(jsonEncode({'notes': notesJson}));
    manifest['Notes'] = 'data/notes.json';
  }

  Future<void> _exportSavedBooksData(Directory dataSubDir, Map<String, dynamic> manifest) async {
    final allSaved = await _bookToDb.getAllSavedBooks();
    if (allSaved.isEmpty) return;

    final savedJson = allSaved.map((s) {
      return {
        'title': s.title,
        'author': s.author,
        'collection': s.collection,
      };
    }).toList();

    final file = File(p.join(dataSubDir.path, 'savedBooks.json'));
    await file.writeAsString(jsonEncode({'savedBooks': savedJson}));
    manifest['Wishlist'] = 'data/savedBooks.json';
  }

  // ── Private import helpers ──

  Future<void> _importBooks(String relativePath, String extractDir) async {
    final booksFile = File(p.join(extractDir, relativePath));
    if (!booksFile.existsSync()) return;

    final data = jsonDecode(await booksFile.readAsString()) as Map<String, dynamic>;

    final docsPath = await getApplicationDocumentsDirectory();
    final supportPath = await getApplicationSupportDirectory();
    final appBooksDir = Directory('${docsPath.path}/Books');
    final appCoversDir = Directory('${supportPath.path}/Covers');
    await appBooksDir.create(recursive: true);
    await appCoversDir.create(recursive: true);

    if (data['collections'] is List) {
      for (final c in (data['collections'] as List)) {
        final cMap = c as Map<String, dynamic>;
        final existing = await _bookToDb.getCollection(cMap['name'] as String);
        if (existing == null) {
          await _bookToDb.addCollection(
            cMap['name'] as String,
            isSavedCollection: cMap['isSavedCollection'] as bool? ?? false,
          );
        }
      }
    }

    final Map<int, int> seriesIdMap = {};
    if (data['series'] is List) {
      for (final s in (data['series'] as List)) {
        final sMap = s as Map<String, dynamic>;
        final name = sMap['name'] as String;
        final existing = await _bookToDb.getSeriesByName(name);
        if (existing != null) {
          seriesIdMap[sMap['id'] as int] = existing.id;
        } else {
          final newId = await _bookToDb.addSeries(
            name,
            cover: sMap['cover'] as String?,
            description: sMap['description'] as String?,
            collection: sMap['collection'] as int?,
            dateAdded: DateTime.now(),
          );
          seriesIdMap[sMap['id'] as int] = newId;
        }
      }
    }

    if (data['books'] is List) {
      for (final b in (data['books'] as List)) {
        final bMap = b as Map<String, dynamic>;
        final name = bMap['name'] as String;
        final author = bMap['author'] as String?;

        final existingBooks = await _bookToDb.getBooksByName(name);
        final match = existingBooks.any((e) => e.author == author);
        if (match) continue;

        final relativeBookPath = bMap['path'] as String;
        final sourceBook = File(p.join(extractDir, relativeBookPath));
        if (!sourceBook.existsSync()) continue;

        final fileName = p.basename(relativeBookPath);
        final extension = bMap['extension'] as String;
        final newPath = p.join(appBooksDir.path, fileName);

        await sourceBook.copy(newPath);

        final fileBytes = await sourceBook.readAsBytes();
        final bookData = await processBook(
          fileBytes: fileBytes,
          fileName: fileName,
          extension: extension,
          coversDir: appCoversDir,
        );

        final oldSeriesId = bMap['series'] as int?;
        await _bookToDb.addBook(
          name: bookData.title,
          author: bookData.author,
          path: newPath,
          extension: extension,
          page: bMap['page'] as int?,
          coverPath: bookData.coverPath,
          series: oldSeriesId != null ? seriesIdMap[oldSeriesId] : null,
          isSeries: bMap['isSeries'] as bool? ?? false,
          dateAdded: DateTime.now(),
        );
      }
    }
  }

  Future<void> _importTimetable(String relativePath, String extractDir) async {
    final file = File(p.join(extractDir, relativePath));
    if (!file.existsSync()) return;

    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final received = tt_model.TimetableModel.fromJson(data);

    await _timetableToDb.deleteTimetable();

    final daysToInsert = received.days.map((d) {
      final day = tt.Day(day: d.day);
      day.isBreak = d.isBreakDay;
      day.sessions = d.sessions.map((s) {
        final session = tt.Session(start: s.start, end: s.end);
        session.subjects = s.subjects.split(',').map((sub) => sub.trim()).toList();
        return session;
      }).toList();
      return day;
    }).toList();

    await _timetableToDb.insertTimetable(
      daysToInsert,
      version: received.version,
      lastModified: received.lastModified,
    );
  }

  Future<void> _importTargets(String relativePath, String extractDir) async {
    final file = File(p.join(extractDir, relativePath));
    if (!file.existsSync()) return;

    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final subjectsList = data['subjects'] as List;

    for (final subData in subjectsList) {
      final subMap = subData as Map<String, dynamic>;
      final subjectUuid = subMap['uuid'] as String;
      final subjectName = subMap['name'] as String;
      final syncedAt = subMap['syncedAt'] != null
          ? DateTime.parse(subMap['syncedAt'] as String)
          : null;

      var existingSubject = await _targetService.getSubjectByUuid(subjectUuid);

      int subjectId;
      if (existingSubject != null) {
        subjectId = existingSubject.id;
        await _targetService.updateSubject(subjectId, subjectName, syncedAt);
      } else {
        subjectId = await _targetService.insertSubject(
          uuid: subjectUuid,
          name: subjectName,
          syncedAt: syncedAt,
        );
      }

      final topicsList = subMap['topics'] as List;
      for (final topData in topicsList) {
        final topMap = topData as Map<String, dynamic>;
        final topicUuid = topMap['uuid'] as String;
        final topicName = topMap['name'] as String;
        final isCompleted = topMap['isCompleted'] as bool;
        final lastModified = DateTime.parse(topMap['lastModified'] as String);

        final existingTopic = await _targetService.getTopicByUuid(topicUuid);

        if (existingTopic != null) {
          if (lastModified.isAfter(existingTopic.lastModified)) {
            await _targetService.updateTopic(
              existingTopic.id,
              topicName,
              isCompleted,
              lastModified,
            );
          }
        } else {
          await _targetService.insertTopic(
            uuid: topicUuid,
            name: topicName,
            isCompleted: isCompleted,
            lastModified: lastModified,
            subjectId: subjectId,
          );
        }
      }
    }
  }

  Future<void> _importNotes(String relativePath, String extractDir) async {
    final file = File(p.join(extractDir, relativePath));
    if (!file.existsSync()) return;

    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final notesList = data['notes'] as List;

    for (final noteData in notesList) {
      final noteMap = noteData as Map<String, dynamic>;
      final uuid = noteMap['uuid'] as String;
      final title = noteMap['title'] as String;
      final content = noteMap['content'] as String? ?? '';
      final lastModified = DateTime.parse(noteMap['lastModified'] as String);

      final existingNote = await _notesToDb.getNoteByUuid(uuid);

      if (existingNote != null) {
        if (lastModified.isAfter(existingNote.lastModified)) {
          await _notesToDb.editNote(existingNote.id, title, content, lastModified);
        }
      } else {
        await _notesToDb.createNewNote(
          title: title,
          content: content,
          uuid: uuid,
          lastModified: lastModified,
          bookId: noteMap['bookId'] as int?,
          collection: noteMap['collection'] as int?,
        );
      }
    }
  }

  Future<void> _importSavedBooks(String relativePath, String extractDir) async {
    final file = File(p.join(extractDir, relativePath));
    if (!file.existsSync()) return;

    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final savedList = data['savedBooks'] as List;

    for (final savedData in savedList) {
      final savedMap = savedData as Map<String, dynamic>;
      final title = savedMap['title'] as String;
      final author = savedMap['author'] as String? ?? '';
      final collection = savedMap['collection'] as int?;

      final existing = await _bookToDb.getSavedBookByTitleAndAuthor(title, author);
      if (existing != null) continue;

      await _bookToDb.addWishBook(title, author, collection: collection);
    }
  }

  // ── Archive helper ──

  Future<void> _addDirectoryToArchive(Archive archive, Directory dir, String basePath) async {
    await for (final entity in dir.list()) {
      final relativePath = p.relative(entity.path, from: basePath);
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      } else if (entity is Directory) {
        await _addDirectoryToArchive(archive, entity, basePath);
      }
    }
  }
}
