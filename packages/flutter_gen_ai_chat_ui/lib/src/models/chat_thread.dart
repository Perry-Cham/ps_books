import 'chat/chat_message.dart';

/// Model representing a chat thread with persistent state
/// Equivalent to CopilotKit's thread management system
class ChatThread {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const ChatThread({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  ChatThread copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': <Map<String,
          dynamic>>[], // Messages serialization not implemented yet
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: <ChatMessage>[], // Messages deserialization not implemented yet
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Thread state for managing multiple chat threads
/// Similar to CopilotKit's isolated chat states
class ThreadState {
  final Map<String, ChatThread> threads;
  final String? activeThreadId;
  final bool isLoading;

  const ThreadState({
    this.threads = const {},
    this.activeThreadId,
    this.isLoading = false,
  });

  ThreadState copyWith({
    Map<String, ChatThread>? threads,
    String? activeThreadId,
    bool? isLoading,
  }) {
    return ThreadState(
      threads: threads ?? this.threads,
      activeThreadId: activeThreadId ?? this.activeThreadId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  ChatThread? get activeThread =>
      activeThreadId != null ? threads[activeThreadId] : null;

  List<ChatThread> get sortedThreads => threads.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}
