import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Streaming Text and Markdown Tests', () {
    late ChatMessagesController controller;

    setUp(() {
      controller = TestUtils.createController();
    });

    testWidgets('Should render streaming text with animation',
        (WidgetTester tester) async {
      // Act: Render the chat widget with streaming enabled
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          enableAnimation: true,
          enableMarkdownStreaming: true,
          streamingDuration:
              const Duration(milliseconds: 50), // Fast for testing
        ),
      );

      // Add a streaming message
      controller.addMessage(
        TestUtils.generateAiMessage(
          text: 'This is a streaming message',
          isStreaming: true,
        ),
      );

      // Allow initial frame to render
      await tester.pump();

      // Verify the message container exists but text might not be fully visible yet
      // Instead of looking for a specific widget type, look for a container that will hold the message
      expect(find.byType(Container), findsWidgets);

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Assert: The full text should be visible after animation
      expect(find.text('This is a streaming message', findRichText: true),
          findsOneWidget);
    });

    testWidgets('Should render markdown content', (WidgetTester tester) async {
      // Arrange: Create markdown style sheet
      final markdownStyleSheet = MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        code: const TextStyle(backgroundColor: Colors.grey),
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          markdownStyleSheet: markdownStyleSheet,
        ),
      );

      // Add a message with markdown content
      controller.addMessage(
        TestUtils.generateAiMessage(
          text: '# Heading\n- List item\n- Another item\n\n`code block`',
        ),
      );

      // Allow rendering to complete
      await tester.pumpAndSettle();

      // Assert: Markdown elements should be rendered
      expect(find.byType(MarkdownBody), findsOneWidget);

      // Check for specific markdown rendered elements (these might need adjustment based on implementation)
      final markdownElement =
          find.byType(MarkdownBody).evaluate().first.widget as MarkdownBody;
      expect(markdownElement.data,
          '# Heading\n- List item\n- Another item\n\n`code block`');
    });

    testWidgets('Should update streaming text progressively',
        (WidgetTester tester) async {
      // Arrange: Create a controller for manual streaming updates
      final streamingController = ChatMessagesController();

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: streamingController,
          enableAnimation: true,
          enableMarkdownStreaming: true,
          streamingDuration: const Duration(milliseconds: 30),
        ),
      );

      // Start with empty streaming message
      final streamingMessage = TestUtils.generateAiMessage(
        text: '',
        isStreaming: true,
      );
      streamingController.addMessage(streamingMessage);
      await tester.pump();

      // Simulate progressive updates to the streaming message
      // Update 1
      final update1 = streamingMessage.copyWith(text: 'Hello');
      streamingController.updateMessage(update1);
      await tester.pump(const Duration(milliseconds: 50));

      // Update 2
      final update2 = update1.copyWith(text: 'Hello, how');
      streamingController.updateMessage(update2);
      await tester.pump(const Duration(milliseconds: 50));

      // Final update
      final finalUpdate = update2.copyWith(
        text: 'Hello, how are you?',
        customProperties: null, // Remove streaming flag
      );
      streamingController.updateMessage(finalUpdate);

      // Allow animation to complete
      await tester.pumpAndSettle();

      // Assert: Final text should be visible
      expect(
          find.text('Hello, how are you?', findRichText: true), findsOneWidget);
    });

    testWidgets('Should disable streaming animation when configured',
        (WidgetTester tester) async {
      // Act: Render the chat widget with streaming disabled
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          enableAnimation: true,
          enableMarkdownStreaming: false, // Disable streaming
        ),
      );

      // Add a message that would normally stream
      controller.addMessage(
        TestUtils.generateAiMessage(
          text: 'This should appear immediately without streaming',
          isStreaming: true, // This would normally enable streaming
        ),
      );

      // Pump once - the text should be immediately visible
      await tester.pump();

      // Assert: The full text should be immediately visible
      expect(
        find.text('This should appear immediately without streaming',
            findRichText: true),
        findsOneWidget,
      );
    });
  });
}
