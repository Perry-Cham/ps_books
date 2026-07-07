import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AiSuggestionsBar integrates and emits selections', (
    tester,
  ) async {
    String lastSelected = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AiSuggestionsBar(
                key: const Key('suggestions_bar'),
                suggestions: const ['Draft reply', 'Explain code', 'Add tests'],
                onSelect: (s) => lastSelected = s,
                onRefresh: () {},
                refreshTooltip: 'Refresh',
              ),
              Text('Selected: $lastSelected', key: const Key('selected_text')),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('suggestions_bar')), findsOneWidget);
    expect(find.text('Draft reply'), findsOneWidget);

    // Select a suggestion
    await tester.tap(find.text('Add tests'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Selected: Add tests'), findsOneWidget);

    // Refresh icon is present and tappable
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
  });
}
