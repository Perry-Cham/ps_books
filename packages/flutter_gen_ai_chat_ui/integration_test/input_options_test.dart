import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_gen_ai_chat_ui/src/utils/color_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Input Field Customization Tests', () {
    late ChatMessagesController controller;

    setUp(() {
      controller = TestUtils.createController();
    });

    testWidgets('Should apply custom input decoration',
        (WidgetTester tester) async {
      // Arrange: Create input options with custom decoration
      const inputOptions = InputOptions(
        decoration: InputDecoration(
          hintText: 'Custom hint text',
          border: OutlineInputBorder(),
          fillColor: Colors.grey,
          filled: true,
        ),
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Assert: Custom hint text should be visible
      expect(find.text('Custom hint text'), findsOneWidget);

      // Find the TextField and verify its decoration
      final textField =
          tester.widget<TextField>(TestUtils.findChatInputField());
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
      expect(textField.decoration?.fillColor, Colors.grey);
      expect(textField.decoration?.filled, true);
    });

    testWidgets('Should apply custom text style', (WidgetTester tester) async {
      // Arrange: Create input options with custom text style
      const inputOptions = InputOptions(
        textStyle: TextStyle(
          color: Colors.red,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Find the TextField and verify its text style
      final textField =
          tester.widget<TextField>(TestUtils.findChatInputField());
      expect(textField.style?.color, Colors.red);
      expect(textField.style?.fontSize, 18);
      expect(textField.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('Should use custom send button builder',
        (WidgetTester tester) async {
      // Arrange: Create input options with custom send button
      final inputOptions = InputOptions(
        sendButtonBuilder: (onSend) => IconButton(
          icon: const Icon(Icons.send_rounded, color: Colors.green),
          onPressed: onSend,
        ),
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Enter text to make sure send button is visible
      await tester.enterText(TestUtils.findChatInputField(), 'Test message');
      await tester.pump();

      // Assert: Custom send button should be visible
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);

      // Find the IconButton and verify its color
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.icon, isA<Icon>());

      final icon = iconButton.icon as Icon;
      expect(icon.color, Colors.green);
    });

    testWidgets('Should respect max lines setting',
        (WidgetTester tester) async {
      // Arrange: Create input options with custom max lines
      const inputOptions = InputOptions(
        maxLines: 3,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Find the TextField and verify maxLines
      final textField =
          tester.widget<TextField>(TestUtils.findChatInputField());
      expect(textField.maxLines, 3);
    });

    testWidgets('Should apply custom container decoration',
        (WidgetTester tester) async {
      // Arrange: Create input options with custom container decoration
      final inputOptions = InputOptions(
        containerDecoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacityCompat(25 / 255),
              blurRadius: 10,
            ),
          ],
        ),
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Find containers and verify decoration
      final containers = find.byType(Container).evaluate().toList();

      var foundMatchingContainer = false;
      for (final containerElement in containers) {
        final container = containerElement.widget as Container;
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == Colors.blue.shade100 &&
              decoration.borderRadius is BorderRadius) {
            foundMatchingContainer = true;
            break;
          }
        }
      }

      expect(foundMatchingContainer, isTrue,
          reason: 'Container with custom decoration not found');
    });

    testWidgets('Should use factory-created InputOptions',
        (WidgetTester tester) async {
      // Arrange: Create input options with glassmorphic effect
      final inputOptions = InputOptions.glassmorphic(
        colors: [
          Colors.blue.withOpacityCompat(51 / 255),
          Colors.purple.withOpacityCompat(51 / 255)
        ],
        borderRadius: 25.0,
        blurStrength: 5.0,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          inputOptions: inputOptions,
        ),
      );

      // Assert: Specific verification depends on implementation
      // For now, we'll just check that the widget renders without errors
      expect(find.byType(TextField), findsOneWidget);

      // Additionally, we can check for BackdropFilter which is used for the glassmorphic effect
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
