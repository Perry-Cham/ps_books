// services/auth/auth_service.dart
import 'package:googleapis/drive/v3.dart' as drive;

abstract class AuthService {
  /// Returns an authenticated DriveApi instance or null if auth failed
  Future<drive.DriveApi?> getDriveApi();

  /// True if the user is currently signed in
  Future<bool> get isSignedIn;

  /// The signed in user's display name if available
  Future<String?> get displayName;

  /// The signed in user's email if available  
  Future<String?> get email;

  /// The Drive folder ID for the app's storage folder, if available.
  Future<String?> get folderId;

  /// Sign the user out and clear stored credentials
  Future<void> signOut();
}

Future<String> getOrCreateAppFolder(drive.DriveApi driveApi) async {
  // 1. Search for the directory by name
  final String query = "name = 'P's Books' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
  final folderList = await driveApi.files.list(q: query);

  if (folderList.files != null && folderList.files!.isNotEmpty) {
    // 2. Folder exists! Return the ID
    return folderList.files!.first.id!;
  } else {
    // 3. Folder doesn't exist! Create it now
    var folderMetadata = drive.File()
      ..name = "P's Books"
      ..mimeType = 'application/vnd.google-apps.folder';
    
    var folder = await driveApi.files.create(folderMetadata);
    return folder.id!;
  }
}