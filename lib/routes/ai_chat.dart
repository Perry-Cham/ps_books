import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../helpers/utils.dart';

const baseUrl = String.fromEnvironment('BASE-URL', defaultValue: 'http://localhost:8000');
final endpoint = "/api/ai/chat";

class Basic extends StatefulWidget {
  const Basic({super.key});

  @override
  BasicState createState() => BasicState();
}

class BasicState extends State<Basic> {
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
        "$baseUrl$endpoint",
        data: {
          "prompt": text,
        },
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
      debugPrint("Error sending message: $e");
      _chatController.insertMessage(
        TextMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          authorId: 'ai',
          createdAt: DateTime.now().toUtc(),
          text: "Error: Failed to fetch response from AI backend.",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        chatController: _chatController,
        currentUserId: 'user1',
        onMessageSend: (text) {
          _chatController.insertMessage(
            TextMessage(
              // Better to use UUID or similar for the ID - IDs must be unique
              id: '${Random().nextInt(1000) + 1}',
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
    );
  }
}