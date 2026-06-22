import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../helpers/utils.dart';

/// Canonical AI chat panel.
///
/// Lives under `lib/routes/ai_chat.dart` so that it is the single source of
/// truth for AI-chat UI. The [ReaderShell] imports this and embeds it as a
/// split column on desktop when `readerStateProvider.showAiChat` is `true`.
///
/// The previous private `_AiChatPanel` that lived inside `lib/readers/reader.dart`
/// has been removed in favour of this widget.
const _aiBaseUrl = String.fromEnvironment(
  'BASE-URL',
  defaultValue: 'http://localhost:8000',
);
final _aiEndpoint = '/api/ai/chat';

class AiChatPanel extends StatefulWidget {
  const AiChatPanel({
    super.key,
    this.onClose,
    this.title = 'AI Chat',
  });

  /// Called when the user taps the close button in the panel header. The
  /// shell wires this to `setShowAiChatFalse()`.
  final VoidCallback? onClose;

  /// Title shown in the panel header.
  final String title;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _chatController = InMemoryChatController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    try {
      final dio = AuthDio.instance;
      final response = await dio.post(
        '$_aiBaseUrl$_aiEndpoint',
        data: {'prompt': text},
      );
      final reply = response.data['text'] as String?;
      if (reply != null && reply.isNotEmpty) {
        _chatController.insertMessage(
          TextMessage(
            id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
            authorId: 'ai',
            createdAt: DateTime.now().toUtc(),
            text: reply,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      _chatController.insertMessage(
        TextMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          authorId: 'ai',
          createdAt: DateTime.now().toUtc(),
          text: 'Error: Failed to fetch response from AI backend.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close AI Chat',
                ),
            ],
          ),
        ),
        Expanded(
          child: Chat(
            chatController: _chatController,
            currentUserId: 'user1',
            onMessageSend: (text) {
              _chatController.insertMessage(
                TextMessage(
                  // Better to use UUID or similar for the ID - IDs must be unique
                  id: '${Random().nextInt(1000) + 1}-${DateTime.now().millisecondsSinceEpoch}',
                  authorId: 'user1',
                  createdAt: DateTime.now().toUtc(),
                  text: text,
                ),
              );
              _sendMessage(text);
            },
            resolveUser: (UserID id) async {
              if (id == 'ai') {
                return User(id: id, name: 'AI Assistant');
              }
              return User(id: id, name: 'John Doe');
            },
          ),
        ),
      ],
    );
  }
}
