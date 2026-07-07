import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  group('VoiceSendButton', () {
    testWidgets('renders correct icon by state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoiceSendButton(
              mode: VoiceSendMode.pushToTalk,
              state: VoiceState.idle,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('push-to-talk triggers hold callbacks', (tester) async {
      bool started = false;
      bool ended = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceSendButton(
              mode: VoiceSendMode.pushToTalk,
              state: VoiceState.idle,
              onHoldStart: () => started = true,
              onHoldEnd: () => ended = true,
            ),
          ),
        ),
      );

      final button = find.byType(VoiceSendButton);
      final center = tester.getCenter(button);
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(started, isTrue);
      expect(ended, isTrue);
    });

    testWidgets('toggle mode toggles active and calls onToggle', (
      tester,
    ) async {
      bool? last;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return VoiceSendButton(
                  mode: VoiceSendMode.toggle,
                  state: VoiceState.listening,
                  onToggle: (v) => last = v,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VoiceSendButton));
      await tester.pumpAndSettle();

      expect(last, isNotNull);
    });
  });
}
