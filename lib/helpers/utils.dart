import 'dart:typed_data';
import 'dart:io';
import '../dbs/initdb.dart';

final _db = DBProvider().db;

Future<Uint8List> convertEpubToBytes({required String path}) async {
  File file = File(path);
  Uint8List epubBytes = await file.readAsBytes();
  print('done converting epub');
  return epubBytes;
}

Future<void> deleteSavedBooks({required Set<int> booksToDelete}) async {
    if (booksToDelete.isEmpty) return;

  for (final id in booksToDelete) {
    await _db.deleteSavedBook(id);
  }
}


Future<void> deleteBooks(Set<int> deletedBookIds) async {
  if (deletedBookIds.isEmpty) return;

  for (final id in deletedBookIds) {
    final book = await _db.getBookById(id);
    await _db.deleteBook(id);
    if(book.coverPath != null){
    final image = File(book.coverPath!);
    await image.delete();
    }
    final bookFile = File(book.path);
    await bookFile.delete();
  }
}
