/// A model representing a quick reply option in the chat.
class QuickReply {
  /// The title/text of the quick reply
  final String title;

  /// Optional value different from title
  final String? value;

  /// Optional message text to be sent when tapped
  final String? messageText;

  /// Optional custom data associated with this quick reply
  final Map<String, dynamic>? customProperties;

  const QuickReply({
    required this.title,
    this.value,
    this.messageText,
    this.customProperties,
  });

  /// Creates a copy of this quick reply with the given fields replaced with new values
  QuickReply copyWith({
    String? title,
    String? value,
    String? messageText,
    Map<String, dynamic>? customProperties,
  }) =>
      QuickReply(
        title: title ?? this.title,
        value: value ?? this.value,
        messageText: messageText ?? this.messageText,
        customProperties: customProperties ?? this.customProperties,
      );
}
