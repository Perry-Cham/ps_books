import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  testWidgets('Callout renders title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Callout(
            title: 'Heads up',
            message: 'This is an informational callout.',
            type: CalloutType.info,
          ),
        ),
      ),
    );

    expect(find.text('Heads up'), findsOneWidget);
    expect(find.text('This is an informational callout.'), findsOneWidget);
  });
}
