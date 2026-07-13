
import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

import '../helpers/utils.dart';

const _aiBaseUrl = String.fromEnvironment(
  'BASE-URL',
  defaultValue: 'http://localhost:8000',
);
final _aiEndpoint = '/api/ai/chat';

class AiChatPanel extends StatefulWidget {
  const AiChatPanel({super.key, this.onClose, this.title = 'AI Chat'});

  final VoidCallback? onClose;
  final String title;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _controller = ChatMessagesController();
  final _currentUser = ChatUser(id: 'user', firstName: 'User');
  final _aiUser = ChatUser(id: 'ai', firstName: 'AI Assistant');
  final bool _isLoading = false;

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
              currentUser: _currentUser,
              aiUser: _aiUser,
              controller: _controller,
              enableMarkdownStreaming: true,
              enableMathRendering: true,
              onSendMessage: _sendMessage,
              loadingConfig: LoadingConfig(isLoading: _isLoading),
              inputOptions: InputOptions(
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
