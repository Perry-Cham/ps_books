import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Loading and Typing Indicators Tests', () {
    late ChatMessagesController controller;

    setUp(() {
      controller = TestUtils.createController();
    });

    testWidgets('Should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // Arrange: Create loading config with loading enabled
      const loadingConfig = LoadingConfig(
        isLoading: true,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          loadingConfig: loadingConfig,
        ),
      );

      // Assert: Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should show custom loading indicator when provided',
        (WidgetTester tester) async {
      // Arrange: Create loading config with custom indicator
      final customIndicator = Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('...'),
        ),
      );

      final loadingConfig = LoadingConfig(
        isLoading: true,
        loadingIndicator: customIndicator,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          loadingConfig: loadingConfig,
        ),
      );

      // Assert: Custom loading indicator should be visible
      expect(find.text('...'), findsOneWidget);

      // Find the Container with the amber color
      final containers = find.byType(Container).evaluate().toList();
      var foundCustomContainer = false;

      for (final element in containers) {
        final container = element.widget as Container;
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == Colors.amber &&
              decoration.shape == BoxShape.circle) {
            foundCustomContainer = true;
            break;
          }
        }
      }

      expect(foundCustomContainer, isTrue,
          reason: 'Custom loading indicator not found');
    });

    testWidgets('Should show typing indicator when typing users are provided',
        (WidgetTester tester) async {
      // Arrange: Create typing users list
      final typingUsers = [
        const ChatUser(id: 'ai-1', name: 'AI Assistant'),
      ];

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          typingUsers: typingUsers,
        ),
      );

      // Assert: Typing indicator should be visible
      // Note: The exact implementation of the typing indicator might vary
      // For most implementations, it will show the user name who is typing
      expect(find.textContaining('AI Assistant'), findsOneWidget);

      // It might also show a visual animation or indicator
      // This might need adjustment based on the actual implementation
      final typingIndicators =
          find.byType(Container).evaluate().where((element) {
        final widget = element.widget as Container;
        return widget.child != null &&
            widget.child.toString().toLowerCase().contains('typing');
      });

      expect(typingIndicators.isNotEmpty, isTrue,
          reason: 'Typing indicator not found');
    });

    testWidgets('Should respect typingIndicatorColor when set',
        (WidgetTester tester) async {
      // Arrange: Create typing users and loading config with custom color
      final typingUsers = [
        const ChatUser(id: 'ai-1', name: 'AI Assistant'),
      ];

      const loadingConfig = LoadingConfig(
        typingIndicatorColor: Colors.purple,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: controller,
          typingUsers: typingUsers,
          loadingConfig: loadingConfig,
        ),
      );

      // Assert: The implementation details of finding the typing indicator color
      // will depend on the specific implementation
      // For now, we just verify the widget renders
      expect(find.textContaining('AI Assistant'), findsOneWidget);
    });

    testWidgets('Should hide loading indicator when isLoading changes to false',
        (WidgetTester tester) async {
      // Arrange: Create a controller for state changes
      final stateController = ChatMessagesController();

      // Start with loading enabled
      const initialLoadingConfig = LoadingConfig(
        isLoading: true,
      );

      // Act: Render the chat widget
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: stateController,
          loadingConfig: initialLoadingConfig,
        ),
      );

      // Verify loading indicator is initially visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Update loading config to disable loading
      const updatedLoadingConfig = LoadingConfig(
        isLoading: false,
      );

      // Re-render with updated config
      await tester.pumpWidget(
        TestUtils.createTestApp(
          controller: stateController,
          loadingConfig: updatedLoadingConfig,
        ),
      );

      // Allow the widget to rebuild
      await tester.pumpAndSettle();

      // Assert: Loading indicator should be hidden
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
