import 'package:ps_books/models/comic_book_model.dart';
import './parsers/weebcentral.dart';
import './services/download_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/models/downloader_models.dart';
import './parsers/base.dart' as manga_models;

class MangaDownloader implements SeriesCapable {
  WeebCentralParser parser = WeebCentralParser();

  @override
  Future<List<SeriesModel>> search({required String query}) async {
    final results = await parser.search(query);
    return results.map((comic) => SeriesModel(
      id: comic.id,
      title: comic.title,
      coverUrl: comic.coverUrl,
      detailUrl: comic.detailUrl,
    )).toList();
  }

  @override
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl}) async {
    final res = await parser.getChapters(detailUrl: volumeUrl);
    return res
        .map((comic) => VolumeInfo(
          id: comic.id,
          label: comic.label,
          chapterUrl: comic.chapterUrl,
        ))
        .toList();
  }

  @override
  void download({required VolumeInfo volume}) {
    throw UnimplementedError('Use downloadChapterAsync instead');
  }

  Future<DownloadResult> downloadChapterAsync({required VolumeInfo chapter}) async {
    final booksDir = await getApplicationDocumentsDirectory();
    final mangaChapter = manga_models.ChapterInfo(
      chapterUrl: chapter.chapterUrl,
      label: chapter.label,
      id: chapter.id,
    );

    return await downloadChapter(
      parser: parser,
      outputDir: booksDir.path,
      format: "cbz",
      chapter: mangaChapter,
    );
  }
}
