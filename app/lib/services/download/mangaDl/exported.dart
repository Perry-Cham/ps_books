import './parsers/weebcentral.dart';
import './services/download_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/models/comic_book_model.dart';
import './parsers/base.dart' as manga_models;

enum DownloadProvider { libgen, manga }

class MangaDownloader {
  WeebCentralParser parser = WeebCentralParser();
  Future<List<ComicBook>> search(String query) async {
    final results = await parser.search(query);

    final normalized = results.map((comic) {
      return ComicBook(
        id: comic.id,
        title: comic.title,
        coverUrl: comic.coverUrl,
        detailUrl: comic.detailUrl,
      );
    }).toList();

    return normalized;
  }

  Future<List<ChapterInfo>> getChapters({required String chapterUrl}) async {
    final res = await parser.getChapters(detailUrl: chapterUrl);
    final normalized = res
        .map(
          (comic) => ChapterInfo(
            id: comic.id,
            label: comic.label,
            chapterUrl: comic.chapterUrl,
          ),
        )
        .toList();
    return normalized;
  }

  Future<void> download({required ChapterInfo chapter}) async {
    final booksDir = await getApplicationDocumentsDirectory();
    final mangaChapter = manga_models.ChapterInfo(
      chapterUrl: chapter.chapterUrl,
      label: chapter.label,
      id: chapter.id,
    );

    await downloadChapter(
      parser: parser,
      outputDir: booksDir.path,
      format: "cbz",
      chapter: mangaChapter,
    );
  }
}
