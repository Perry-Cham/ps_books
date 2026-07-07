import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  group('InlineAutocompleteTextField', () {
    testWidgets('shows ghost text when caret at end', (tester) async {
      final controller = TextEditingController(text: 'Hello');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: InlineAutocompleteTextField(
                controller: controller,
                ghostText: ', world',
                forceShowGhost: true, // simplify visibility in test env
                decoration: const InputDecoration(),
              ),
            ),
          ),
        ),
      );

      // The ghost text should be visible
      expect(find.text(', world'), findsOneWidget);
    });

    testWidgets('accepts ghost text on Tab', (tester) async {
      final controller = TextEditingController(text: 'Hi');
      bool accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: InlineAutocompleteTextField(
                controller: controller,
                ghostText: ' there',
                onAcceptGhost: () => accepted = true,
                decoration: const InputDecoration(),
              ),
            ),
          ),
        ),
      );

      // Focus the field
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Send Tab key
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(accepted, isTrue);
      expect(controller.text, 'Hi there');
      expect(find.text(' there'), findsNothing); // ghost consumed
    });

    testWidgets('does not show ghost when caret is not at end', (tester) async {
      final controller = TextEditingController(text: 'Test');
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: InlineAutocompleteTextField(
                controller: controller,
                ghostText: 'ing',
                decoration: const InputDecoration(),
              ),
            ),
          ),
        ),
      );

      // Caret is inside text, ghost should not render
      expect(find.text('ing'), findsNothing);
    });
  });
}
