// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/google/auth_service.dart';
import '../services/auth/google/abstract.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

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

class GoogleUser {
  final String? name;
  final String? email;
  final bool isSignedIn;

  GoogleUser({this.name, this.email, this.isSignedIn = false});

  GoogleUser copyWith({String? name, String? email, bool isSignedIn = false}) {
    return GoogleUser(
      name: name ?? this.name,
      email: email ?? this.email,
      isSignedIn: isSignedIn,
    );
  }
}

class GoogleUserNotifier extends AsyncNotifier<GoogleUser> {
  @override
  Future<GoogleUser> build() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('given_name');
    final email = prefs.getString('google_email');
    final isSignedIn = prefs.getBool('google_signed_in') ?? false;

    return GoogleUser(name: name, email: email, isSignedIn: isSignedIn);
  }

  Future<void> updateState(String name, String email, bool isSignedIn) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('given_name', name);
    await prefs.setString('google_email', email);
    await prefs.setBool('google_signed_in', isSignedIn);

    state = AsyncData(
      GoogleUser(name: name, email: email, isSignedIn: isSignedIn),
    );
  }
}

final GoogleUserProvider =
    AsyncNotifierProvider<GoogleUserNotifier, GoogleUser>(
      GoogleUserNotifier.new,
    );

final driveBooksProvider = FutureProvider<List<drive.File>>((ref) async {
  final authService = ref.watch(authServiceProvider);

  // 1. Get the Drive API instance
  final driveApi = await authService.getDriveApi();
  if (driveApi == null)
    throw Exception('Failed to authenticate with Google Drive');

  // 2. Get the Folder ID (This method already handles creation if missing)
  final folderId = await authService.folderId;
  if (folderId == null) {
    throw Exception('Could not locate or create app folder');
  }

  // 3. Fetch the metadata for files inside that folder
  final String query = "'$folderId' in parents and trashed = false";
  final  fileList = await driveApi.files.list(
    q: query,
    $fields: "files(id, name, mimeType, size, modifiedTime, thumbnailLink)",
  );

  return fileList.files ?? [];
});
