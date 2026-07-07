import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  testWidgets('TranscriptChip displays partial and promote action', (
    tester,
  ) async {
    bool promoted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TranscriptChip(
            text: 'partial text',
            isFinal: false,
            onPromote: () => promoted = true,
          ),
        ),
      ),
    );

    expect(find.text('partial text'), findsOneWidget);
    await tester.tap(find.text('Promote'));
    await tester.pumpAndSettle();
    expect(promoted, isTrue);
  });
}
