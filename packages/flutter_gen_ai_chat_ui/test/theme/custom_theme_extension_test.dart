import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  group('CustomThemeExtension presets', () {
    test('modern preset maps from ColorScheme', () {
      final scheme = const ColorScheme.light();
      final ext = CustomThemeExtension.modern(scheme);

      expect(ext.chatBackground, scheme.surface);
      expect(ext.messageBubbleColor, scheme.surfaceContainerLow);
      expect(ext.userBubbleColor, scheme.primaryContainer);
      expect(ext.messageTextColor, scheme.onSurface);
      expect(ext.inputBackgroundColor, scheme.surfaceContainerHighest);
      expect(ext.inputBorderColor, scheme.outlineVariant);
      expect(ext.sendButtonColor, scheme.primary);
      expect(ext.sendButtonIconColor, scheme.onPrimary);
    });

    test('minimal preset maps from ColorScheme', () {
      final scheme = const ColorScheme.dark();
      final ext = CustomThemeExtension.minimal(scheme);

      expect(ext.chatBackground, scheme.surface);
      expect(ext.messageBubbleColor, scheme.surface);
      expect(ext.userBubbleColor, scheme.surface);
      expect(ext.messageTextColor, scheme.onSurface);
      expect(ext.inputBackgroundColor, scheme.surface);
      expect(ext.inputBorderColor, scheme.outlineVariant);
    });

    test('withCustomTheme merges into single extension instance', () {
      final base = ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          const CustomThemeExtension(chatBackground: Colors.red),
        ],
      );

      final merged = CustomThemeExtension.withCustomTheme(
        base,
        const CustomThemeExtension(messageBubbleColor: Colors.blue),
      );

      final ext = merged.extension<CustomThemeExtension>();
      expect(ext, isNotNull);
      expect(ext!.chatBackground, Colors.red);
      expect(ext.messageBubbleColor, Colors.blue);
    });
  });
}
