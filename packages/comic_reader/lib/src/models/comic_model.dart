// lib/src/models/comic_model.dart

import 'dart:io';
import 'dart:typed_data';

/// A model class representing metadata for a comic book.
class ComicMetadata {
  /// The series name of the comic.
  final String? series;

  /// The title of the comic issue.
  final String? title;

  /// The issue number.
  final String? number;

  /// The publication year.
  final String? year;

  /// The writer of the comic.
  final String? writer;

  ComicMetadata({
    this.series,
    this.title,
    this.number,
    this.year,
    this.writer,
  });

  /// Converts the [ComicMetadata] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'series': series,
      'title': title,
      'number': number,
      'year': year,
      'writer': writer,
    };
  }

  /// Creates a [ComicMetadata] instance from a JSON map.
  factory ComicMetadata.fromJson(Map<String, dynamic> json) {
    return ComicMetadata(
      series: json['series'],
      title: json['title'],
      number: json['number'],
      year: json['year'],
      writer: json['writer'],
    );
  }
}

/// A model class representing a comic book with pages and name.
///
/// This class provides functionality to convert between JSON and Dart objects,
/// making it suitable for data serialization and deserialization.
class ComicModel {
  /// List of comic page URLs or references.
  ///
  /// Each string in this list typically represents a path or URL to a comic page image.
  final List<String> comicPages;

  /// The name of the comic book.
  ///
  /// This string represents the title or name identifier for the comic.
  final String comicName;

  /// Metadata for the comic book, parsed from ComicInfo.xml if available.
  final ComicMetadata? metadata;

  /// Creates a new [ComicModel] instance.
  ///
  /// Requires [comicPages] as a list of strings representing the comic pages
  /// and [comicName] as a string representing the name of the comic.
  /// [metadata] is optional.
  ///
  /// Example:
  /// ```dart
  /// final comic = ComicModel(
  ///   comicPages: ['page1.jpg', 'page2.jpg', 'page3.jpg'],
  ///   comicName: 'My Awesome Comic',
  /// );
  /// ```
  ComicModel({
    required this.comicPages,
    required this.comicName,
    this.metadata,
  });

  /// Returns the first image of the comic as bytes.
  ///
  /// Throws an [Exception] if no pages are found or if the file cannot be read.
  Future<Uint8List> coverImage() async {
    if (comicPages.isEmpty) {
      throw Exception('No pages found in comic');
    }
    final file = File(comicPages.first);
    if (!await file.exists()) {
      throw Exception('Cover image file not found: ${comicPages.first}');
    }
    return await file.readAsBytes();
  }

  /// Converts the [ComicModel] instance to a JSON map.
  ///
  /// Returns a [Map] with keys 'comicPages', 'comicName', and 'metadata'.
  Map<String, dynamic> toJson() {
    return {
      'comicPages': comicPages,
      'comicName': comicName,
      'metadata': metadata?.toJson(),
    };
  }

  /// Creates a [ComicModel] instance from a JSON map.
  ///
  /// The [json] parameter must contain the keys 'comicPages' and 'comicName'.
  /// The 'comicPages' value must be a list that can be converted to a list of strings.
  ///
  /// Throws an error if the required keys are missing or have incompatible types.
  factory ComicModel.fromJson(Map<String, dynamic> json) {
    return ComicModel(
      comicPages: List<String>.from(json['comicPages']),
      comicName: json['comicName'],
      metadata: json['metadata'] != null
          ? ComicMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}