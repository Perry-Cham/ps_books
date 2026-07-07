import 'package:flutter/material.dart';

/// Represents a media attachment in a chat message.
class ChatMedia {
  /// The URL of the media
  final String url;

  /// The type of media (image, video, file, etc.)
  final ChatMediaType type;

  /// Optional file name
  final String? fileName;

  /// Optional file size in bytes
  final int? size;

  /// Optional file extension
  final String? extension;

  /// Optional metadata about the media
  final Map<String, dynamic>? metadata;

  /// Optional widget to use for rendering this media
  final Widget Function(BuildContext, ChatMedia)? customBuilder;

  const ChatMedia({
    required this.url,
    this.type = ChatMediaType.image,
    this.fileName,
    this.size,
    this.extension,
    this.metadata,
    this.customBuilder,
  });

  /// Creates a copy of this media with the given fields replaced with new values
  ChatMedia copyWith({
    String? url,
    ChatMediaType? type,
    String? fileName,
    int? size,
    String? extension,
    Map<String, dynamic>? metadata,
    Widget Function(BuildContext, ChatMedia)? customBuilder,
  }) =>
      ChatMedia(
        url: url ?? this.url,
        type: type ?? this.type,
        fileName: fileName ?? this.fileName,
        size: size ?? this.size,
        extension: extension ?? this.extension,
        metadata: metadata ?? this.metadata,
        customBuilder: customBuilder ?? this.customBuilder,
      );
}

/// Enum representing different types of media in chat messages.
enum ChatMediaType {
  /// Image files (jpg, png, gif, etc.)
  image,

  /// Video files (mp4, mov, etc.)
  video,

  /// Audio files (mp3, wav, etc.)
  audio,

  /// Document files (pdf, doc, etc.)
  document,

  /// Any other type of file
  other
}
