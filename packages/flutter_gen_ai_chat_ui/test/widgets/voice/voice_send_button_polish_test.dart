import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  group('VoiceSendButton polish', () {
    testWidgets('long-press triggers hold start/end in PTT mode', (
      tester,
    ) async {
      bool started = false;
      bool ended = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceSendButton(
                mode: VoiceSendMode.pushToTalk,
                state: VoiceState.idle,
                onHoldStart: () => started = true,
                onHoldEnd: () => ended = true,
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(VoiceSendButton));
      await tester.pumpAndSettle();
      expect(started, isTrue);
      expect(ended, isTrue);
    });

    testWidgets('diameter controls visual size; min tap target enforced', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceSendButton(
                mode: VoiceSendMode.toggle,
                state: VoiceState.idle,
                diameter: 40,
                minTapTarget: 48,
              ),
            ),
          ),
        ),
      );

      final rect = tester.getRect(find.byType(VoiceSendButton));
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
    });
  });
}
