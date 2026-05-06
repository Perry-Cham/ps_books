// services/auth/auth_factory.dart
import 'dart:io';
import 'abstract.dart';
import 'mobile.dart';
import 'desktop.dart';

AuthService createAuthService() {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileAuthService();
  }
  return DesktopAuthService();
}

