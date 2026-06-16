import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/services/DB%20services/bookToDb.dart';
import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:ps_books/services/download/steb.dart';
import 'package:ps_books/services/download/zlib.dart';
import 'package:ps_books/services/download/libgen.dart';

final _db = BookToDb();

Future<List<DownloadBook>> SearchBooks(String query, String provider) async {
  if (provider == 'libgen') {
    return await LibgenScraper.search(query) ?? [];
  } else if (provider == 'steb') {
    return await StandardEbooksScraper.search(query);
  } else if (provider == 'zlib') {
    return await searchZlib(query);
  }
  return [];
}

Stream<double> downloadBookWithProgress(
  String url,
  CancelToken cancelToken,
) async* {
  final dio = Dio();
  final d = await getApplicationDocumentsDirectory();
  final supportDir = await getApplicationSupportDirectory();
  final coversDir = Directory("${supportDir.path}/Covers");
  await coversDir.create(recursive: true);

  final String filename = await getFileName(url);
  final String savePath = "${d.path}/Books/$filename";

  final controller = StreamController<double>();

  unawaited(
    dio
        .download(
          url,
          savePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              controller.add(received / total);
            }
          },
        )
        .then((_) async {
          final String extension = filename.split('.').last.toLowerCase();
          if ([
            'pdf',
            'epub',
            'fb2',
            'cbz',
            'cbt',
            'cbw',
            'mobi',
            'azw3',
          ].contains(extension)) {

            final fileBytes = await File(savePath).readAsBytes();
            final bookData = await processBook(
              fileBytes: fileBytes,
              fileName: filename,
              extension: extension,
              coversDir: coversDir,
            );

            await _db.addBook(
              name: bookData.title,
              author: bookData.author,
              extension: extension,
              path: savePath,
              page:
                  (extension == 'pdf' ||
                      extension == 'cbz' ||
                      extension == 'cbt' ||
                      extension == 'cbw')
                  ? 1
                  : null,
              coverPath: bookData.coverPath,
            );
          } else {
            await _db.addBook(
              name: filename.split('.')[0],
              extension: extension,
              path: savePath,
            );
          }
        })
        .catchError((e) {
          controller.addError(e);
        })
        .whenComplete(() {
          controller.close();
        }),
  );

  yield* controller.stream;
}

Future<String> getFileName(String url) async {
  final dio = Dio();
  final response = await dio.head(url);

  final contentDisposition = response.headers.value('content-disposition');

  if (contentDisposition != null && contentDisposition.contains('filename=')) {
    final regExp = RegExp(r'filename="?([^";]+)"?');
    final match = regExp.firstMatch(contentDisposition);
    if (match != null) {
      return match.group(1)!;
    }
  }

  return url.split('/').last.split('?').first;
}
