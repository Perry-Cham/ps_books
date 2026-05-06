// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/google/auth_service.dart';
import '../services/auth/google/abstract.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../state/google_auth.dart';

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


final driveBooksProvider = FutureProvider<List<drive.File>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  
  // 1. Get the Drive API instance
  final driveApi = await authService.getDriveApi();
  if (driveApi == null) throw Exception('Failed to authenticate with Google Drive');

  // 2. Get the Folder ID (This method already handles creation if missing)
  final folderId = await authService.folderId;
  if (folderId == null) throw Exception('Could not locate or create app folder');

  // 3. Fetch the metadata for files inside that folder
  final String query = "'$folderId' in parents and trashed = false";
  final fileList = await driveApi.files.list(
    q: query,
    $fields: "files(id, name, mimeType, size, modifiedTime, thumbnailLink)",
  );

  return fileList.files ?? [];
});