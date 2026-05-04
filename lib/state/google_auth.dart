// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/google/auth_service.dart';
import '../services/auth/google/abstract.dart';

// single instance shared across the app
final authServiceProvider = Provider<AuthService>((ref) {
  return createAuthService();
});

// whether the user is currently signed in
final isSignedInProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authServiceProvider).isSignedIn;
});

// the user's display name
final displayNameProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authServiceProvider).displayName;
});