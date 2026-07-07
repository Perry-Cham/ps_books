// This file is deprecated. Use chat/chat_user.dart instead.
// Please update your imports to use the new location.

@Deprecated('Use chat/chat_user.dart instead')
export 'chat/chat_user.dart';

class ChatUser {
  final String id;
  final String name;
  final String? avatar;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatar,
  });
}
