import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

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
  const AiChatPanel({super.key, this.onClose, this.title = 'AI Chat'});

  /// Called when the user taps the close button in the panel header. The
  /// shell wires this to `setShowAiChatFalse()`.
  final VoidCallback? onClose;

  /// Title shown in the panel header.
  final String title;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _controller = ChatMessagesController();
  final _currentUser = ChatUser(id: 'user', firstName: 'User');
  final _aiUser = ChatUser(id: 'ai', firstName: 'AI Assistant');
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(ChatMessage text) async {
    try {
      _controller.addMessage(
        ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now().toUtc(),
          text: text.text,
        ),
      );
      final dio = AuthDio.instance;
      final response = await dio.post(
        '$_aiBaseUrl$_aiEndpoint',
        data: {'prompt': text.text},
      );
      final reply = response.data['text'] as String?;
      if (reply != null && reply.isNotEmpty) {
        _controller.addMessage(
          ChatMessage(
            user: _aiUser,
            createdAt: DateTime.now().toUtc(),
            text: reply,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      _controller.addMessage(
        ChatMessage(
          text: "There was an error processing your request",
          user: _aiUser,
          createdAt: DateTime.now(),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical:  8.0, horizontal: 8.0),
            child: AiChatWidget(
              // Required parameters
              currentUser: _currentUser,
              aiUser: _aiUser,
              controller: _controller,
              enableMarkdownStreaming: true,
              enableMathRendering: true,
              onSendMessage: _sendMessage,
              // Optional parameters
              loadingConfig: LoadingConfig(isLoading: _isLoading),
              inputOptions: InputOptions(
                //hintText: 'Ask me anything...',
                sendOnEnter: true,
              ),
              welcomeMessageConfig: WelcomeMessageConfig(
                title: 'Welcome to AI Chat',
                questionsSectionTitle: 'Try asking me:',
              ),
              exampleQuestions: [
                ExampleQuestion(question: "What can you help me with?"),
                ExampleQuestion(question: "Tell me about your features"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
