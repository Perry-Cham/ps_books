import 'dart:typed_data';
import 'dart:io';

Future<Uint8List> convertEpubToBytes({required String path}) async {
  File file = File(path);
  Uint8List epubBytes = await file.readAsBytes();
  print('done converting epub');
  return epubBytes;
}
