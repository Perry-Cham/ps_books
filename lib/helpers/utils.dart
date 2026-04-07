import 'dart:typed_data';
import 'dart:io';
import '../dbs/initdb.dart';

final _database = DBProvider().db;

Future<Uint8List> convertEpubToBytes({required String path}) async {
  File file = File(path);
  Uint8List epubBytes = await file.readAsBytes();
  print('done converting epub');
  return epubBytes;
}

Future<void> deleteBook({required String path, required int id}) async {
File file = File(path);
await file.delete();
await _database.deleteBook(id);

}
