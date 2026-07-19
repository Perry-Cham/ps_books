import "./comic_book_model.dart";

abstract class SeriesCapable {
  Future<List<VolumeInfo>> getVolumes({required String volumeUrl});

  Future<List<SeriesModel>> search({required String query});

  void download({required VolumeInfo volume});
}
