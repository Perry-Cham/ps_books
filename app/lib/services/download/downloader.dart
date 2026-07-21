import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/models/downloader_models.dart';
import 'package:ps_books/services/download/libgen/exported.dart' as libgen_mod;
import 'package:ps_books/services/download/standardEbooks/exported.dart' as steb_mod;
import 'package:ps_books/services/download/manga/exported.dart' as manga_mod;
import 'package:ps_books/services/download/gutenberg/exported.dart' as gutenberg_mod;

final _db = BookToDb();

final downloadManager = DownloadManager(maxConcurrentTasks: 3);

enum DownloadProvider { libgen, steb, manga, gutenberg }

SeriesCapable _getProviderWithMode(String provider, {bool series = false}) {
  switch (provider) {
    case 'libgen':
      return libgen_mod.Libgen(
        mode: series ? libgen_mod.SearchMode.series : libgen_mod.SearchMode.files,
      );
    case 'steb':
      return steb_mod.StandardEbooks(
        mode: series ? steb_mod.StebSearchMode.collections : steb_mod.StebSearchMode.normal,
      );
    case 'manga':
      return manga_mod.MangaDownloader();
    case 'gutenberg':
      return gutenberg_mod.Gutenberg(
        mode: series ? gutenberg_mod.GutenbergSearchMode.series : gutenberg_mod.GutenbergSearchMode.normal,
      );
    default:
      return libgen_mod.Libgen();
  }
}

Future<List<SeriesModel>> SearchBooks(String query, String provider, {bool series = false}) async {
  final svc = _getProviderWithMode(provider, series: series);
  return svc.search(query: query);
}

Future<List<VolumeInfo>> GetVolumes(String provider, String volumeUrl, {bool series = false}) async {
  final svc = _getProviderWithMode(provider, series: series);
  return svc.getVolumes(volumeUrl: volumeUrl);
}

Future<void> processDownloadedBook(String savePath) async {
  final file = File(savePath);
  if (!(await file.exists())) return;

  final filename = savePath.split('/').last;
  final supportDir = await getApplicationSupportDirectory();
  final coversDir = Directory("${supportDir.path}/Covers");
  await coversDir.create(recursive: true);

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
    final fileBytes = await file.readAsBytes();
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
      page: (extension == 'pdf' ||
              extension == 'cbz' ||
              extension == 'cbt' ||
              extension == 'cbw')
          ? 1
          : null,
      coverPath: bookData.coverPath,
      dateAdded: DateTime.now(),
    );
  } else {
    await _db.addBook(
      name: filename.split('.')[0],
      extension: extension,
      path: savePath,
      dateAdded: DateTime.now(),
    );
  }
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
