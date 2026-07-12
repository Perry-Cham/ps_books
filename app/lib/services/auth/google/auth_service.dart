// services/auth/auth_factory.dart
import 'abstract.dart';
import 'desktop.dart';

AuthService createAuthService() {
  /*if (Platform.isAndroid || Platform.isIOS) {
    return MobileAuthService();
  }*/
  return DesktopAuthService();
}

