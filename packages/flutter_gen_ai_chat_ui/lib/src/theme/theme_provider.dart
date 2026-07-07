import 'package:flutter/material.dart';
import 'custom_theme_extension.dart';

/// Provider class for theme-related functionality
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeData get theme => _isDark ? darkTheme : lightTheme;

  static ThemeData get lightTheme =>
      ThemeData.light(useMaterial3: true).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          const CustomThemeExtension(
            chatBackground: Color(0xFFF7F9FC),
            messageBubbleColor: Colors.white,
            userBubbleColor: Color(0xFFEDF6FF),
            messageTextColor: Color(0xFF262A30),
            inputBackgroundColor: Colors.white,
            inputBorderColor: Color(0xFFE6EAF0),
            inputTextColor: Color(0xFF262A30),
            hintTextColor: Color(0xFF8E97A5),
            backToBottomButtonColor: Color(0xFF0A84FF),
            sendButtonColor: Color(0xFF0A84FF),
            sendButtonIconColor: Colors.white,
          ),
        ],
      );

  static ThemeData get darkTheme => ThemeData.dark(useMaterial3: true).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          const CustomThemeExtension(
            chatBackground: Color(0xFF0C0D10),
            messageBubbleColor: Color(0xFF1E2026),
            userBubbleColor: Color(0xFF0E3054),
            messageTextColor: Color(0xFFE8ECF4),
            inputBackgroundColor: Color(0xFF1E2026),
            inputBorderColor: Color(0xFF32353D),
            inputTextColor: Color(0xFFE8ECF4),
            hintTextColor: Color(0xFF8E97A5),
            backToBottomButtonColor: Color(0xFF0A84FF),
            sendButtonColor: Color(0xFF0A84FF),
            sendButtonIconColor: Colors.white,
          ),
        ],
      );

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
