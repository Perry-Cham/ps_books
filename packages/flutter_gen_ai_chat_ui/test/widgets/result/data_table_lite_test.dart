import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  testWidgets('DataTableLite renders headings and rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DataTableLite(
            columns: ['Name', 'Age'],
            rows: [
              ['Alice', '30'],
              ['Bob', '25'],
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
  });
}
