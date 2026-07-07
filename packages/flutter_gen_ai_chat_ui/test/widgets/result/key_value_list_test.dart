import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  testWidgets('KeyValueList renders pairs from data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KeyValueList(items: {'Status': 'OK', 'Count': '42'}),
        ),
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Count'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });
}
