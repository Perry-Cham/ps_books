import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  testWidgets('VoiceStatusBar shows states and latency', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VoiceStatusBar(
            duplexState: DuplexState.listening,
            latencyMs: 120,
            packetLoss: 0.02,
          ),
        ),
      ),
    );

    expect(find.textContaining('Listening'), findsOneWidget);
    expect(find.textContaining('120ms'), findsOneWidget);
  });
}
