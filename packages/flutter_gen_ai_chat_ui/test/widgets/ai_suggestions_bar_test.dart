import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  group('AiSuggestionsBar', () {
    testWidgets('renders suggestion chips and triggers onSelect', (
      tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiSuggestionsBar(
              suggestions: const ['Summarize', 'Explain', 'Create tests'],
              onSelect: (s) => selected = s,
            ),
          ),
        ),
      );

      // Chips render
      expect(find.text('Summarize'), findsOneWidget);
      expect(find.text('Explain'), findsOneWidget);
      expect(find.text('Create tests'), findsOneWidget);

      // Tap a chip
      await tester.tap(find.text('Explain'));
      await tester.pumpAndSettle();
      expect(selected, 'Explain');
    });

    testWidgets('renders refresh button and triggers onRefresh', (
      tester,
    ) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiSuggestionsBar(
              suggestions: const ['A', 'B'],
              onRefresh: () => refreshed = true,
              refreshTooltip: 'Reload',
            ),
          ),
        ),
      );

      // Find by tooltip
      final refreshFinder = find.byTooltip('Reload');
      expect(refreshFinder, findsOneWidget);

      await tester.tap(refreshFinder);
      await tester.pumpAndSettle();
      expect(refreshed, isTrue);
    });

    testWidgets('renders nothing when suggestions are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AiSuggestionsBar(suggestions: [])),
        ),
      );

      // No chips
      expect(find.byType(Chip), findsNothing);
      // The bar collapses to nothing
      expect(find.byType(AiSuggestionsBar), findsOneWidget);
    });
  });
}
