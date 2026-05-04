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

  /// Sign the user out and clear stored credentials
  Future<void> signOut();
}