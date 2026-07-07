import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Welcome Message and Example Questions Tests', () {
    late ChatMessagesController controller;
    late List<ChatMessage> sentMessages;

    setUp(() {
      controller = TestUtils.createController();
      sentMessages = [];
    });

    testWidgets('Should display welcome message when configured',
        (WidgetTester tester) async {
      // Act: Render the chat widget with welcome message
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          welcomeMessageConfig: TestUtils.createWelcomeMessageConfig(),
        ),
      );

      // Allow welcome message to appear
      await tester.pumpAndSettle();

      // Assert: Welcome message should be displayed
      expect(find.text('Welcome to the chat'), findsOneWidget);
    });

    testWidgets('Should display example questions',
        (WidgetTester tester) async {
      // Arrange: Create example questions
      final exampleQuestions = [
        const ExampleQuestion(question: 'What is your name?'),
        const ExampleQuestion(question: 'How can you help me?'),
        const ExampleQuestion(question: 'Tell me a joke'),
      ];

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          exampleQuestions: exampleQuestions,
          welcomeMessageConfig: TestUtils.createWelcomeMessageConfig(),
          onSendMessage: (message) {
            sentMessages.add(message);
          },
        ),
      );

      // Allow welcome message and questions to appear
      await tester.pumpAndSettle();

      // Assert: Example questions should be displayed
      expect(
          TestUtils.findExampleQuestion('What is your name?'), findsOneWidget);
      expect(TestUtils.findExampleQuestion('How can you help me?'),
          findsOneWidget);
      expect(TestUtils.findExampleQuestion('Tell me a joke'), findsOneWidget);
    });

    testWidgets('Should send message when example question is tapped',
        (WidgetTester tester) async {
      // Arrange: Create example questions
      final exampleQuestions = [
        const ExampleQuestion(question: 'What is your name?'),
      ];

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          exampleQuestions: exampleQuestions,
          welcomeMessageConfig: TestUtils.createWelcomeMessageConfig(),
          onSendMessage: (message) {
            sentMessages.add(message);
            // Simulate AI response
            controller.addMessage(
              TestUtils.generateAiMessage(text: 'Response to: ${message.text}'),
            );
          },
        ),
      );

      // Allow welcome message and questions to appear
      await tester.pumpAndSettle();

      // Tap on the example question
      await tester.tap(TestUtils.findExampleQuestion('What is your name?'));
      await tester.pumpAndSettle();

      // Assert: The example question should be sent as a message
      expect(sentMessages.length, 1);
      expect(sentMessages.first.text, 'What is your name?');

      // The message should be displayed in the chat
      expect(
          TestUtils.findMessageWithText('What is your name?'), findsOneWidget);
      expect(TestUtils.findMessageWithText('Response to: What is your name?'),
          findsOneWidget);
    });

    testWidgets('Should hide welcome message after sending a message',
        (WidgetTester tester) async {
      // Arrange: Create example questions
      final exampleQuestions = [
        const ExampleQuestion(question: 'Question 1'),
        const ExampleQuestion(question: 'Question 2'),
      ];

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          welcomeMessageConfig: TestUtils.createWelcomeMessageConfig(),
          exampleQuestions: exampleQuestions,
          onSendMessage: (message) {
            sentMessages.add(message);
            // Add AI response
            controller.addMessage(
              TestUtils.generateAiMessage(text: 'Response to your message'),
            );
          },
        ),
      );

      // Allow welcome message to appear
      await tester.pumpAndSettle();

      // Verify welcome message is shown
      expect(find.text('Welcome to the chat'), findsOneWidget);

      // Send a message
      await TestUtils.sendMessage(tester, 'Hello there');

      // Allow time for UI to update
      await tester.pumpAndSettle();

      // Assert: Welcome message should be hidden
      expect(find.text('Welcome to the chat'), findsNothing);
    });

    testWidgets(
        'Should maintain example questions when configured as persistent',
        (WidgetTester tester) async {
      // Arrange: Create example questions
      final exampleQuestions = [
        const ExampleQuestion(question: 'Persistent question'),
      ];

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          welcomeMessageConfig: TestUtils.createWelcomeMessageConfig(),
          exampleQuestions: exampleQuestions,
          persistentExampleQuestions: true,
          onSendMessage: (message) {
            sentMessages.add(message);
            controller.addMessage(
              TestUtils.generateAiMessage(text: 'Response to your message'),
            );
          },
        ),
      );

      // Allow welcome message to appear
      await tester.pumpAndSettle();

      // Verify example question is shown
      expect(
          TestUtils.findExampleQuestion('Persistent question'), findsOneWidget);

      // Send a message
      await TestUtils.sendMessage(tester, 'Hello there');

      // Allow time for UI to update
      await tester.pumpAndSettle();

      // Assert: Example question should still be visible
      expect(
          TestUtils.findExampleQuestion('Persistent question'), findsOneWidget);
    });
  });
}
