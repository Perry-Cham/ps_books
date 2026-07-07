/// Represents a user in the chat.
class ChatUser {
  /// Unique identifier for the user
  final String id;

  /// Display name of the user
  final String name;

  /// Optional URL to the user's avatar image
  final String? avatar;

  /// Optional custom properties for the user
  final Map<String, dynamic>? customProperties;

  /// Optional role of the user (e.g., 'admin', 'user', 'bot')
  final String? role;

  const ChatUser({
    required this.id,
    String? name,
    String? firstName,
    this.avatar,
    this.customProperties,
    this.role,
  }) : name = name ?? firstName ?? id;

  /// Creates a copy of this user with the given fields replaced with new values
  ChatUser copyWith({
    String? id,
    String? name,
    String? firstName,
    String? avatar,
    Map<String, dynamic>? customProperties,
    String? role,
  }) =>
      ChatUser(
        id: id ?? this.id,
        name: name ?? firstName ?? this.name,
        avatar: avatar ?? this.avatar,
        customProperties: customProperties ?? this.customProperties,
        role: role ?? this.role,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          avatar == other.avatar &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ avatar.hashCode ^ role.hashCode;

  /// Serialization support for thread persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'customProperties': customProperties,
      'role': role,
    };
  }

  /// Deserialization support for thread persistence
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
      role: json['role'] as String?,
    );
  }
}
