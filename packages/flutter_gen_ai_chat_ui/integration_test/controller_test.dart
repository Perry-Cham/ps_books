import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ChatMessagesController Tests', () {
    late ChatMessagesController controller;

    setUp(() {
      controller = TestUtils.createController();
    });

    testWidgets('Should add a message and update UI',
        (WidgetTester tester) async {
      // Arrange: Render the chat widget with empty controller
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
        ),
      );

      // Act: Add a message to the controller
      controller.addMessage(
        TestUtils.generateAiMessage(text: 'Hello from controller test'),
      );

      // Allow the UI to update
      await tester.pumpAndSettle();

      // Assert: Message should be displayed
      expect(
        find.text('Hello from controller test', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('Should update a message and reflect in UI',
        (WidgetTester tester) async {
      // Arrange: Add initial message
      final initialMessage = TestUtils.generateAiMessage(
        text: 'Initial message',
      );
      controller.addMessage(initialMessage);

      // Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
        ),
      );

      // Verify initial message is displayed
      expect(find.text('Initial message', findRichText: true), findsOneWidget);

      // Act: Update the message
      final updatedMessage = initialMessage.copyWith(
        text: 'Updated message',
      );
      controller.updateMessage(updatedMessage);

      // Allow the UI to update
      await tester.pumpAndSettle();

      // Assert: Updated message should be displayed, and original should be gone
      expect(find.text('Initial message', findRichText: true), findsNothing);
      expect(find.text('Updated message', findRichText: true), findsOneWidget);
    });

    testWidgets('Should remove a message from list and update UI',
        (WidgetTester tester) async {
      // Arrange: Add messages
      final messageToKeep = TestUtils.generateAiMessage(
        text: 'This message stays',
      );
      final messageToRemove = TestUtils.generateAiMessage(
        text: 'This message will be removed',
      );

      controller.addMessages([messageToKeep, messageToRemove]);

      // Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
        ),
      );

      // Verify both messages are displayed
      expect(
          find.text('This message stays', findRichText: true), findsOneWidget);
      expect(find.text('This message will be removed', findRichText: true),
          findsOneWidget);

      // Act: Remove one message by creating a new list without it
      final messages = controller.messages.toList();
      messages.removeWhere((msg) => msg.text == 'This message will be removed');
      controller.clearMessages();
      controller.addMessages(messages);

      // Allow the UI to update
      await tester.pumpAndSettle();

      // Assert: Only the kept message should be displayed
      expect(
          find.text('This message stays', findRichText: true), findsOneWidget);
      expect(find.text('This message will be removed', findRichText: true),
          findsNothing);
    });

    testWidgets('Should clear all messages and update UI',
        (WidgetTester tester) async {
      // Arrange: Add multiple messages
      controller.addMessages([
        TestUtils.generateUserMessage(text: 'User message 1'),
        TestUtils.generateAiMessage(text: 'AI response 1'),
        TestUtils.generateUserMessage(text: 'User message 2'),
        TestUtils.generateAiMessage(text: 'AI response 2'),
      ]);

      // Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
        ),
      );

      // Verify messages are displayed
      expect(find.text('User message 1', findRichText: true), findsOneWidget);
      expect(find.text('AI response 1', findRichText: true), findsOneWidget);
      expect(find.text('User message 2', findRichText: true), findsOneWidget);
      expect(find.text('AI response 2', findRichText: true), findsOneWidget);

      // Act: Clear all messages
      controller.clearMessages();

      // Allow the UI to update
      await tester.pumpAndSettle();

      // Assert: No messages should be displayed
      expect(find.text('User message 1', findRichText: true), findsNothing);
      expect(find.text('AI response 1', findRichText: true), findsNothing);
      expect(find.text('User message 2', findRichText: true), findsNothing);
      expect(find.text('AI response 2', findRichText: true), findsNothing);
    });

    testWidgets('Should support streaming text updates',
        (WidgetTester tester) async {
      // Arrange: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          enableMarkdownStreaming: true,
          streamingDuration: const Duration(milliseconds: 30),
        ),
      );

      // Start with an empty streaming message
      final streamingMessage = TestUtils.generateAiMessage(
        text: '',
        isStreaming: true,
      );
      controller.addMessage(streamingMessage);
      await tester.pump();

      // Act: Stream content word by word
      final wordList = [
        'Hello',
        ', ',
        'this',
        ' ',
        'is',
        ' ',
        'streaming',
        '.'
      ];
      var currentText = '';

      for (final word in wordList) {
        currentText += word;
        final update = streamingMessage.copyWith(text: currentText);
        controller.updateMessage(update);
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finalize the message by removing streaming flag
      final finalMessage = streamingMessage.copyWith(
        text: currentText,
        customProperties: null,
      );
      controller.updateMessage(finalMessage);

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Assert: Final message should be visible
      expect(
        find.text('Hello, this is streaming.', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('Should notify listeners when messages change',
        (WidgetTester tester) async {
      // Arrange: Create a controller and a counter for change notifications
      final notifyController = ChatMessagesController();
      var changeCount = 0;

      // Set up a listener
      notifyController.addListener(() {
        changeCount++;
      });

      // Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: notifyController,
        ),
      );

      // Act & Assert: Each operation should trigger a notification

      // Add message
      notifyController.addMessage(
        TestUtils.generateUserMessage(text: 'Test notification'),
      );
      expect(changeCount, 1);

      // Update message
      final message = notifyController.messages.first;
      final updatedMessage = message.copyWith(text: 'Updated notification');
      notifyController.updateMessage(updatedMessage);
      expect(changeCount, 2);

      // Remove message by clearing and re-adding
      notifyController.clearMessages();
      expect(changeCount, 3);

      // Add multiple messages
      notifyController.addMessages([
        TestUtils.generateUserMessage(text: 'Test 1'),
        TestUtils.generateUserMessage(text: 'Test 2'),
      ]);
      expect(changeCount, 4);

      // Clear messages
      notifyController.clearMessages();
      expect(changeCount, 5);
    });
  });
}
