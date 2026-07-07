import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:comic_reader/src/parsers/comic_reader_parser.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory fakeTempDir;

  setUp(() async {
    fakeTempDir = await Directory.systemTemp.createTemp('comic_reader_test');
    
    // Mock path_provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return fakeTempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    await fakeTempDir.delete(recursive: true);
  });

  group('ComicReaderParser Metadata Parsing', () {
    test('successfully parses ComicInfo.xml and extracts cover image', () async {
      final parser = ComicReaderParser();
      
      // Create a mock archive
      final archive = Archive();
      
      // Add an image
      final imageBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
      archive.addFile(ArchiveFile('cover.jpg', imageBytes.length, imageBytes));
      
      // Add ComicInfo.xml
      final xmlContent = '''
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Series>The Amazing Spider-Man</Series>
  <Title>Coming Home</Title>
  <Number>30</Number>
  <Year>2001</Year>
  <Writer>J. Michael Straczynski</Writer>
</ComicInfo>
''';
      final xmlBytes = Uint8List.fromList(xmlContent.codeUnits);
      archive.addFile(ArchiveFile('ComicInfo.xml', xmlBytes.length, xmlBytes));
      
      final zipBytes = ZipEncoder().encode(archive)!;
      
      final comic = await parser.parse(Uint8List.fromList(zipBytes), 'spiderman_30.cbz');
      
      expect(comic.comicName, 'spiderman_30');
      expect(comic.comicPages.length, 1);
      expect(path.basename(comic.comicPages.first), 'cover.jpg');
      
      // Verify metadata
      expect(comic.metadata, isNotNull);
      expect(comic.metadata!.series, 'The Amazing Spider-Man');
      expect(comic.metadata!.title, 'Coming Home');
      expect(comic.metadata!.number, '30');
      expect(comic.metadata!.year, '2001');
      expect(comic.metadata!.writer, 'J. Michael Straczynski');
      
      // Verify cover image method
      final cover = await comic.coverImage();
      expect(cover, imageBytes);
    });

    test('skips metadata if ComicInfo.xml is missing', () async {
      final parser = ComicReaderParser();
      
      final archive = Archive();
      final imageBytes = Uint8List.fromList([0, 1, 2]);
      archive.addFile(ArchiveFile('page1.png', imageBytes.length, imageBytes));
      
      final zipBytes = ZipEncoder().encode(archive)!;
      
      final comic = await parser.parse(Uint8List.fromList(zipBytes), 'no_metadata.cbz');
      
      expect(comic.metadata, isNull);
      expect(comic.comicPages.length, 1);
      
      final cover = await comic.coverImage();
      expect(cover, imageBytes);
    });
  });
}
